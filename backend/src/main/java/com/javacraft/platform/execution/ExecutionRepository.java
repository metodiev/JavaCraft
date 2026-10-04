package com.javacraft.platform.execution;

import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ExecutionRepository {
    private final JdbcTemplate jdbc;

    public ExecutionRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public boolean hasAvailableWorker() {
        Integer count = jdbc.queryForObject(
                """
                SELECT count(*)
                FROM execution_worker_heartbeat
                WHERE last_seen_at > now() - interval '30 seconds'
                """,
                Integer.class);
        return count != null && count > 0;
    }

    public Optional<ExecutionView> findById(UUID executionId, UUID learnerId) {
        return jdbc.query(
                """
                SELECT e.id, e.state, e.duration_ms, e.output_truncated,
                       r.passed_count, r.total_count, r.sanitized_summary
                FROM execution e
                JOIN submission s ON s.id = e.submission_id
                LEFT JOIN execution_result r
                    ON r.execution_id = e.id AND r.visibility = 'PUBLIC'
                WHERE e.id = ? AND s.user_id = ?
                """,
                (rs, rowNum) -> new ExecutionView(
                        rs.getObject("id", UUID.class),
                        rs.getString("state"),
                        rs.getObject("duration_ms", Long.class),
                        rs.getObject("passed_count", Integer.class),
                        rs.getObject("total_count", Integer.class),
                        rs.getString("sanitized_summary"),
                        rs.getBoolean("output_truncated")),
                executionId,
                learnerId).stream().findFirst();
    }

    public Optional<UUID> findExistingExecution(UUID learnerId, String idempotencyKey) {
        return jdbc.query(
                """
                SELECT e.id
                FROM submission s
                JOIN execution e ON e.submission_id = s.id
                WHERE s.user_id = ? AND s.idempotency_key = ?
                """,
                (rs, rowNum) -> rs.getObject("id", UUID.class),
                learnerId,
                idempotencyKey).stream().findFirst();
    }

    public boolean withinSubmissionLimits(UUID learnerId) {
        Integer active = jdbc.queryForObject(
                """
                SELECT count(*)
                FROM submission s
                JOIN execution e ON e.submission_id = s.id
                WHERE s.user_id = ? AND e.state IN ('QUEUED', 'RUNNING')
                """,
                Integer.class,
                learnerId);
        Integer recent = jdbc.queryForObject(
                """
                SELECT count(*)
                FROM submission
                WHERE user_id = ? AND created_at > now() - interval '1 hour'
                """,
                Integer.class,
                learnerId);
        Integer queued = jdbc.queryForObject(
                """
                SELECT count(*)
                FROM execution
                WHERE state IN ('QUEUED', 'RUNNING')
                """,
                Integer.class);
        return active != null
                && active < 3
                && recent != null
                && recent < 20
                && queued != null
                && queued < 20;
    }

    public UUID create(UUID learnerId, String slug, String source, String idempotencyKey) {
        var submissionIds = jdbc.query(
                """
                INSERT INTO submission (
                    user_id, challenge_id, challenge_version, source_bundle, idempotency_key)
                SELECT ?, c.id, c.version, ?, ?
                FROM challenge c
                WHERE c.slug = ? AND c.slug = 'payment-race-condition' AND c.published = true
                ON CONFLICT (user_id, idempotency_key) DO NOTHING
                RETURNING id
                """,
                (rs, rowNum) -> rs.getObject("id", UUID.class),
                learnerId,
                source.getBytes(StandardCharsets.UTF_8),
                idempotencyKey,
                slug);
        if (submissionIds.isEmpty()) {
            return findExistingExecution(learnerId, idempotencyKey)
                    .orElseThrow(() -> new org.springframework.dao.EmptyResultDataAccessException(1));
        }
        UUID submissionId = submissionIds.getFirst();
        return jdbc.queryForObject(
                "INSERT INTO execution (submission_id, state) VALUES (?, 'QUEUED') RETURNING id",
                UUID.class,
                submissionId);
    }

    public record ExecutionView(
            UUID id,
            String state,
            Long durationMs,
            Integer passed,
            Integer total,
            String summary,
            boolean outputTruncated) {}
}
