package com.javacraft.platform.catalog;

import java.util.List;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class CatalogService {
    private final JdbcTemplate jdbc;

    public CatalogService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public CatalogResponse getCatalog() {
        return new CatalogResponse(
                listTutorials(),
                findChallenge("payment-race-condition")
                        .orElseThrow(() -> new IllegalStateException("Seed challenge is missing")));
    }

    public List<TutorialSummary> listTutorials() {
        return jdbc.query(
                """
                SELECT t.slug, t.title, t.description, t.level, t.duration_minutes,
                       c.slug AS category_slug, c.name AS category_name,
                       COALESCE(c.sort_order, 999) AS category_sort
                FROM tutorial t
                LEFT JOIN tutorial_category c ON c.id = t.category_id
                WHERE t.published = true
                ORDER BY COALESCE(c.sort_order, 999), c.name,
                    CASE t.level
                        WHEN 'Junior' THEN 1
                        WHEN 'Mid' THEN 2
                        WHEN 'Senior' THEN 3
                        WHEN 'Lead' THEN 4
                        WHEN 'Principal' THEN 5
                        ELSE 6
                    END, t.title
                """,
                (rs, rowNum) -> new TutorialSummary(
                        rs.getString("slug"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("level"),
                        rs.getInt("duration_minutes"),
                        rs.getString("category_slug"),
                        rs.getString("category_name")));
    }

    public List<TutorialCategory> listCategories() {
        return jdbc.query(
                """
                SELECT c.slug, c.name, c.description, count(t.id) AS tutorial_count
                FROM tutorial_category c
                LEFT JOIN tutorial t ON t.category_id = c.id AND t.published = true
                GROUP BY c.id, c.slug, c.name, c.description, c.sort_order
                HAVING count(t.id) > 0
                ORDER BY c.sort_order
                """,
                (rs, rowNum) -> new TutorialCategory(
                        rs.getString("slug"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getInt("tutorial_count")));
    }

    public List<ChallengeSummary> listChallenges() {
        return jdbc.query(
                """
                SELECT slug, title, description, level, category
                FROM challenge
                WHERE published = true
                ORDER BY CASE level
                    WHEN 'Junior' THEN 1
                    WHEN 'Mid' THEN 2
                    WHEN 'Senior' THEN 3
                    WHEN 'Lead' THEN 4
                    WHEN 'Principal' THEN 5
                    ELSE 6
                END, title
                """,
                (rs, rowNum) -> new ChallengeSummary(
                        rs.getString("slug"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("level"),
                        rs.getString("category")));
    }

    public Optional<Tutorial> findTutorial(String slug) {
        List<TutorialSummary> summaries = jdbc.query(
                """
                SELECT t.slug, t.title, t.description, t.level, t.duration_minutes,
                       c.slug AS category_slug, c.name AS category_name
                FROM tutorial t
                LEFT JOIN tutorial_category c ON c.id = t.category_id
                WHERE t.slug = ? AND t.published = true
                """,
                (rs, rowNum) -> new TutorialSummary(
                        rs.getString("slug"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("level"),
                        rs.getInt("duration_minutes"),
                        rs.getString("category_slug"),
                        rs.getString("category_name")),
                slug);
        if (summaries.isEmpty()) {
            return Optional.empty();
        }
        TutorialSummary summary = summaries.getFirst();
        List<TutorialSection> sections = jdbc.query(
                """
                SELECT title, body_markdown, starter_code
                FROM tutorial_section
                WHERE tutorial_id = (SELECT id FROM tutorial WHERE slug = ?)
                ORDER BY sort_order
                """,
                (rs, rowNum) -> new TutorialSection(
                        rs.getString("title"),
                        rs.getString("body_markdown"),
                        rs.getString("starter_code")),
                slug);
        return Optional.of(new Tutorial(
                summary.slug(),
                summary.title(),
                summary.description(),
                summary.level(),
                summary.durationMinutes(),
                summary.categorySlug(),
                summary.categoryName(),
                sections));
    }

    public Optional<Challenge> findChallenge(String slug) {
        List<ChallengeBase> challenges = jdbc.query(
                """
                SELECT id, slug, title, level, category, description,
                       starter_repository ->> (
                           SELECT jsonb_object_keys(challenge.starter_repository) LIMIT 1
                       ) AS starter_code,
                       EXISTS (SELECT 1 FROM challenge_test t
                               WHERE t.challenge_id = challenge.id AND t.visibility = 'PUBLIC') AS runnable
                FROM challenge
                WHERE slug = ? AND published = true
                """,
                (rs, rowNum) -> new ChallengeBase(
                        rs.getObject("id", java.util.UUID.class),
                        rs.getString("slug"),
                        rs.getString("title"),
                        rs.getString("level"),
                        rs.getString("category"),
                        rs.getString("description"),
                        rs.getString("starter_code"),
                        rs.getBoolean("runnable")),
                slug);
        if (challenges.isEmpty()) {
            return Optional.empty();
        }
        ChallengeBase base = challenges.getFirst();
        List<String> requirements = jdbc.query(
                """
                SELECT description
                FROM challenge_requirement
                WHERE challenge_id = ?
                ORDER BY sort_order
                """,
                (rs, rowNum) -> rs.getString("description"),
                base.id());
        List<String> skills = jdbc.query(
                """
                SELECT s.name
                FROM challenge_skill cs
                JOIN skill s ON s.id = cs.skill_id
                WHERE cs.challenge_id = ?
                ORDER BY s.name
                """,
                (rs, rowNum) -> rs.getString("name"),
                base.id());
        return Optional.of(new Challenge(
                base.slug(),
                base.title(),
                base.level(),
                base.category(),
                base.description(),
                requirements,
                base.starterCode(),
                skills,
                base.runnable()));
    }

    public record CatalogResponse(List<TutorialSummary> tutorials, Challenge challenge) {}

    public record TutorialSummary(
            String slug,
            String title,
            String description,
            String level,
            int durationMinutes,
            String categorySlug,
            String categoryName) {}

    public record TutorialCategory(
            String slug,
            String name,
            String description,
            int tutorialCount) {}

    public record ChallengeSummary(
            String slug,
            String title,
            String description,
            String level,
            String category) {}

    public record Tutorial(
            String slug,
            String title,
            String description,
            String level,
            int durationMinutes,
            String categorySlug,
            String categoryName,
            List<TutorialSection> sections) {}

    public record TutorialSection(String title, String body, String exampleCode) {}

    public record Challenge(
            String slug,
            String title,
            String level,
            String category,
            String description,
            List<String> requirements,
            String starterCode,
            List<String> skills,
            boolean runnable) {}

    private record ChallengeBase(
            java.util.UUID id,
            String slug,
            String title,
            String level,
            String category,
            String description,
            String starterCode,
            boolean runnable) {}
}
