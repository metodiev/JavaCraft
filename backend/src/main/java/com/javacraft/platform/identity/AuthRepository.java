package com.javacraft.platform.identity;

import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AuthRepository {
    private final JdbcTemplate jdbc;

    public AuthRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Learner createLearner(String email, String passwordHash, String displayName) {
        UUID id = jdbc.queryForObject(
                """
                INSERT INTO app_user (email, password_hash, display_name)
                VALUES (?, ?, ?)
                RETURNING id
                """,
                UUID.class,
                email,
                passwordHash,
                displayName);
        if (id == null) {
            throw new IllegalStateException("Database did not return the new learner identifier");
        }
        jdbc.update(
                """
                INSERT INTO user_role (user_id, role_id)
                SELECT ?, id FROM app_role WHERE name = 'ROLE_USER'
                """,
                id);
        jdbc.update(
                """
                INSERT INTO user_skill (user_id, skill_id)
                SELECT ?, id FROM skill
                """,
                id);
        return new Learner(id, email, displayName);
    }

    public Optional<Credentials> findCredentialsByEmail(String email) {
        return jdbc.query(
                        """
                        SELECT id, email, display_name, password_hash
                        FROM app_user
                        WHERE email = ?
                        """,
                        (rs, rowNum) -> new Credentials(
                                new Learner(
                                        rs.getObject("id", UUID.class),
                                        rs.getString("email"),
                                        rs.getString("display_name")),
                                rs.getString("password_hash")),
                        email)
                .stream()
                .findFirst();
    }

    public Optional<Learner> findLearnerById(UUID id) {
        return jdbc.query(
                        """
                        SELECT id, email, display_name
                        FROM app_user
                        WHERE id = ?
                        """,
                        (rs, rowNum) -> new Learner(
                                rs.getObject("id", UUID.class),
                                rs.getString("email"),
                                rs.getString("display_name")),
                        id)
                .stream()
                .findFirst();
    }

    public Optional<Learner> findLearnerBySessionTokenHash(byte[] tokenHash) {
        return jdbc.query(
                        """
                        SELECT u.id, u.email, u.display_name
                        FROM user_session s
                        JOIN app_user u ON u.id = s.user_id
                        WHERE s.token_hash = ?
                          AND s.revoked_at IS NULL
                          AND s.expires_at > now()
                        """,
                        (rs, rowNum) -> new Learner(
                                rs.getObject("id", UUID.class),
                                rs.getString("email"),
                                rs.getString("display_name")),
                        tokenHash)
                .stream()
                .findFirst();
    }

    public void createSession(UUID userId, byte[] tokenHash) {
        jdbc.update(
                """
                INSERT INTO user_session (user_id, token_hash, expires_at)
                VALUES (?, ?, now() + interval '30 days')
                """,
                userId,
                tokenHash);
    }

    public void revokeSession(byte[] tokenHash) {
        jdbc.update(
                """
                UPDATE user_session
                SET revoked_at = now()
                WHERE token_hash = ? AND revoked_at IS NULL
                """,
                tokenHash);
    }

    public record Credentials(Learner learner, String passwordHash) {}
}
