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
                SELECT slug, title, description, duration_minutes
                FROM tutorial
                WHERE published = true
                ORDER BY title
                """,
                (rs, rowNum) -> new TutorialSummary(
                        rs.getString("slug"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getInt("duration_minutes")));
    }

    public Optional<Tutorial> findTutorial(String slug) {
        List<TutorialSummary> summaries = jdbc.query(
                """
                SELECT slug, title, description, duration_minutes
                FROM tutorial
                WHERE slug = ? AND published = true
                """,
                (rs, rowNum) -> new TutorialSummary(
                        rs.getString("slug"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getInt("duration_minutes")),
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
                summary.durationMinutes(),
                sections));
    }

    public Optional<Challenge> findChallenge(String slug) {
        List<ChallengeBase> challenges = jdbc.query(
                """
                SELECT id, slug, title, level, category, description,
                       starter_repository ->> 'PaymentService.java' AS starter_code
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
                        rs.getString("starter_code")),
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
                skills));
    }

    public record CatalogResponse(List<TutorialSummary> tutorials, Challenge challenge) {}

    public record TutorialSummary(
            String slug,
            String title,
            String description,
            int durationMinutes) {}

    public record Tutorial(
            String slug,
            String title,
            String description,
            int durationMinutes,
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
            List<String> skills) {}

    private record ChallengeBase(
            java.util.UUID id,
            String slug,
            String title,
            String level,
            String category,
            String description,
            String starterCode) {}
}
