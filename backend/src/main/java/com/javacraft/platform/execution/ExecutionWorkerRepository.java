package com.javacraft.platform.execution;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

@Repository
public class ExecutionWorkerRepository {
    private final JdbcTemplate jdbc;
    private final TransactionTemplate transactions;

    public ExecutionWorkerRepository(JdbcTemplate jdbc, PlatformTransactionManager transactionManager) {
        this.jdbc = jdbc;
        this.transactions = new TransactionTemplate(transactionManager);
    }

    public Optional<ExecutionJob> claimNext() {
        return transactions.execute(status -> jdbc.query(
                        """
                        UPDATE execution e
                        SET state = 'RUNNING', started_at = now()
                        FROM submission s, challenge c
                        WHERE e.id = (
                            SELECT queued.id
                            FROM execution queued
                            WHERE queued.state = 'QUEUED'
                            ORDER BY queued.queued_at
                            FOR UPDATE SKIP LOCKED
                            LIMIT 1
                        )
                          AND s.id = e.submission_id
                          AND c.id = s.challenge_id
                        RETURNING e.id, c.slug, s.source_bundle, c.id AS challenge_id,
                                  (SELECT k FROM jsonb_object_keys(c.starter_repository) AS k LIMIT 1) AS source_file
                        """,
                        (rs, rowNum) -> new ExecutionJob(
                                rs.getObject("id", UUID.class),
                                rs.getString("slug"),
                                new String(rs.getBytes("source_bundle"), StandardCharsets.UTF_8),
                                rs.getObject("challenge_id", UUID.class),
                                rs.getString("source_file") == null
                                        ? "PaymentService.java"
                                        : rs.getString("source_file")))
                .stream()
                .findFirst());
    }

    public Optional<String> publicTestPlan(UUID challengeId) {
        List<String> plans = jdbc.query(
                """
                SELECT convert_from(source_bundle, 'UTF8')
                FROM challenge_test
                WHERE challenge_id = ? AND visibility = 'PUBLIC'
                ORDER BY sort_order
                """,
                (rs, rowNum) -> rs.getString(1),
                challengeId);
        return plans.stream().findFirst();
    }

    public void heartbeat(String workerName) {
        jdbc.update(
                """
                INSERT INTO execution_worker_heartbeat (worker_name, last_seen_at)
                VALUES (?, now())
                ON CONFLICT (worker_name) DO UPDATE SET last_seen_at = EXCLUDED.last_seen_at
                """,
                workerName);
    }

    public void recoverInterruptedRuns() {
        jdbc.update(
                """
                WITH interrupted AS (
                    UPDATE execution
                    SET state = 'INFRASTRUCTURE_ERROR',
                        completed_at = now(),
                        duration_ms = GREATEST(
                            0, EXTRACT(EPOCH FROM (now() - started_at)) * 1000)::bigint
                    WHERE state = 'RUNNING'
                      AND started_at < now() - interval '1 minute'
                    RETURNING id
                )
                INSERT INTO execution_result (
                    execution_id, visibility, passed_count, total_count, sanitized_summary)
                SELECT id,
                       'PUBLIC',
                       0,
                       0,
                       'The previous isolated worker stopped before completing this run.'
                FROM interrupted
                ON CONFLICT (execution_id, visibility) DO NOTHING
                """);
    }

    public void complete(
            UUID executionId,
            String state,
            long durationMs,
            Integer passed,
            Integer total,
            String summary,
            boolean outputTruncated) {
        transactions.executeWithoutResult(status -> {
            jdbc.update(
                    """
                    UPDATE execution
                    SET state = ?, completed_at = now(), duration_ms = ?, output_truncated = ?
                    WHERE id = ? AND state = 'RUNNING'
                    """,
                    state,
                    durationMs,
                    outputTruncated,
                    executionId);
            if (passed != null && total != null) {
                jdbc.update(
                        """
                        INSERT INTO execution_result (
                            execution_id, visibility, passed_count, total_count, sanitized_summary)
                        VALUES (?, 'PUBLIC', ?, ?, ?)
                        ON CONFLICT (execution_id, visibility) DO UPDATE SET
                            passed_count = EXCLUDED.passed_count,
                            total_count = EXCLUDED.total_count,
                            sanitized_summary = EXCLUDED.sanitized_summary
                        """,
                        executionId,
                        passed,
                        total,
                        summary);
            }
        });
    }

    public static String encode(String value) {
        return Base64.getEncoder().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    public record ExecutionJob(
            UUID id, String challengeSlug, String source, UUID challengeId, String sourceFileName) {}
}
