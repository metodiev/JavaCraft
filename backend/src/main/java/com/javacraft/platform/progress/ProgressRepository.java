package com.javacraft.platform.progress;

import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ProgressRepository {
    private final JdbcTemplate jdbc;

    public ProgressRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<TutorialProgress> findTutorialProgress(UUID userId) {
        return jdbc.query(
                """
                SELECT t.slug, COALESCE(p.status, 'NOT_STARTED') AS status
                FROM learning_path_tutorial lpt
                JOIN learning_path lp ON lp.id = lpt.learning_path_id
                JOIN tutorial t ON t.id = lpt.tutorial_id
                LEFT JOIN progress p
                    ON p.user_id = ?
                    AND p.learning_path_id = lp.id
                    AND p.tutorial_id = t.id
                WHERE lp.published = true AND t.published = true
                ORDER BY CASE lp.slug
                    WHEN 'junior-java-developer' THEN 1
                    WHEN 'mid-java-engineer' THEN 2
                    WHEN 'senior-java-engineer' THEN 3
                    WHEN 'lead-java-engineer' THEN 4
                    WHEN 'principal-java-engineer' THEN 5
                    ELSE 6
                END, lpt.sort_order
                """,
                (rs, rowNum) -> new TutorialProgress(
                        rs.getString("slug"),
                        ProgressStatus.valueOf(rs.getString("status"))),
                userId);
    }

    public List<SkillProgress> findSkillProgress(UUID userId) {
        return jdbc.query(
                """
                SELECT s.slug, s.name, us.proficiency
                FROM user_skill us
                JOIN skill s ON s.id = us.skill_id
                WHERE us.user_id = ?
                ORDER BY s.name
                """,
                (rs, rowNum) -> new SkillProgress(
                        rs.getString("slug"),
                        rs.getString("name"),
                        rs.getInt("proficiency")),
                userId);
    }

    public PathProgress findPathProgress(UUID userId) {
        return jdbc.queryForObject(
                """
                SELECT 'JavaCraft Engineering Tracks' AS title,
                       count(DISTINCT t.id)::integer AS total_count,
                       count(DISTINCT t.id) FILTER (WHERE p.status = 'COMPLETED')::integer AS completed_count
                FROM learning_path lp
                JOIN learning_path_tutorial lpt ON lpt.learning_path_id = lp.id
                JOIN tutorial t ON t.id = lpt.tutorial_id
                LEFT JOIN progress p
                    ON p.user_id = ?
                    AND p.learning_path_id = lp.id
                    AND p.tutorial_id = t.id
                WHERE lp.published = true
                """,
                (rs, rowNum) -> new PathProgress(
                        rs.getString("title"),
                        rs.getInt("completed_count"),
                        rs.getInt("total_count")),
                userId);
    }

    public boolean updateTutorialProgress(UUID userId, String slug, ProgressStatus status) {
        int updated = jdbc.update(
                """
                INSERT INTO progress (user_id, learning_path_id, tutorial_id, status, completed_at)
                SELECT ?, lp.id, t.id, ?, CASE WHEN ? = 'COMPLETED' THEN now() END
                FROM learning_path lp
                JOIN learning_path_tutorial lpt ON lpt.learning_path_id = lp.id
                JOIN tutorial t ON t.id = lpt.tutorial_id
                WHERE lp.published = true
                  AND t.slug = ?
                  AND t.published = true
                ON CONFLICT (user_id, learning_path_id, tutorial_id)
                DO UPDATE SET
                    status = CASE
                        WHEN progress.status = 'COMPLETED' THEN progress.status
                        ELSE EXCLUDED.status
                    END,
                    completed_at = CASE
                        WHEN progress.status = 'COMPLETED' THEN progress.completed_at
                        WHEN EXCLUDED.status = 'COMPLETED' THEN now()
                        ELSE NULL
                    END,
                    updated_at = now()
                """,
                userId,
                status.name(),
                status.name(),
                slug);
        return updated > 0;
    }

    public enum ProgressStatus {
        NOT_STARTED,
        IN_PROGRESS,
        COMPLETED
    }

    public record TutorialProgress(String slug, ProgressStatus status) {}

    public record SkillProgress(String slug, String name, int proficiency) {}

    public record PathProgress(String title, int completedCount, int totalCount) {
        public int percent() {
            if (totalCount == 0) {
                return 0;
            }
            return completedCount * 100 / totalCount;
        }
    }
}
