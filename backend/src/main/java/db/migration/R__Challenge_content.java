package db.migration;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.zip.CRC32;
import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

/**
 * Keeps runnable challenge content (starter code, requirements, public tests) in sync with the
 * files under classpath:challenge-content/&lt;slug&gt;/. It re-runs whenever any of them change.
 */
public class R__Challenge_content extends BaseJavaMigration {
    private static final String PATTERN = "classpath*:challenge-content/*/PublicTests.java";
    private static final String[] FILES = {"Main.java", "PublicTests.java", "requirements.txt"};

    public record ChallengeContent(String slug, String starter, String tests, List<String> requirements) {}

    @Override
    public Integer getChecksum() {
        CRC32 crc = new CRC32();
        try {
            for (ChallengeContent content : load()) {
                crc.update(content.slug().getBytes(StandardCharsets.UTF_8));
                crc.update(content.starter().getBytes(StandardCharsets.UTF_8));
                crc.update(content.tests().getBytes(StandardCharsets.UTF_8));
                crc.update(String.join("\n", content.requirements()).getBytes(StandardCharsets.UTF_8));
            }
        } catch (IOException ex) {
            throw new IllegalStateException("Cannot read challenge content", ex);
        }
        return (int) crc.getValue();
    }

    @Override
    public void migrate(Context context) throws Exception {
        for (ChallengeContent content : load()) {
            apply(context, content);
        }
    }

    private void apply(Context context, ChallengeContent content) throws SQLException {
        var connection = context.getConnection();
        String challengeId = null;
        try (PreparedStatement select = connection.prepareStatement("SELECT id::text FROM challenge WHERE slug = ?")) {
            select.setString(1, content.slug());
            try (var rs = select.executeQuery()) {
                if (rs.next()) {
                    challengeId = rs.getString(1);
                }
            }
        }
        if (challengeId == null) {
            throw new IllegalStateException("Unknown challenge slug: " + content.slug());
        }
        try (PreparedStatement update = connection.prepareStatement(
                "UPDATE challenge SET starter_repository = jsonb_build_object('Main.java', ?::text) WHERE id = ?::uuid")) {
            update.setString(1, content.starter());
            update.setString(2, challengeId);
            update.executeUpdate();
        }
        try (PreparedStatement delete = connection.prepareStatement(
                "DELETE FROM challenge_requirement WHERE challenge_id = ?::uuid")) {
            delete.setString(1, challengeId);
            delete.executeUpdate();
        }
        int order = 1;
        for (String requirement : content.requirements()) {
            try (PreparedStatement insert = connection.prepareStatement(
                    "INSERT INTO challenge_requirement (challenge_id, description, sort_order) VALUES (?::uuid, ?, ?)")) {
                insert.setString(1, challengeId);
                insert.setString(2, requirement);
                insert.setInt(3, order++);
                insert.executeUpdate();
            }
        }
        try (PreparedStatement upsert = connection.prepareStatement(
                """
                INSERT INTO challenge_test (challenge_id, visibility, source_bundle, sort_order)
                VALUES (?::uuid, 'PUBLIC', ?, 1)
                ON CONFLICT (challenge_id, visibility, sort_order)
                DO UPDATE SET source_bundle = EXCLUDED.source_bundle
                """)) {
            upsert.setString(1, challengeId);
            upsert.setBytes(2, content.tests().getBytes(StandardCharsets.UTF_8));
            upsert.executeUpdate();
        }
    }

    static List<ChallengeContent> load() throws IOException {
        var resolver = new PathMatchingResourcePatternResolver(R__Challenge_content.class.getClassLoader());
        List<ChallengeContent> result = new ArrayList<>();
        for (Resource tests : resolver.getResources(PATTERN)) {
            String url = tests.getURL().toString();
            String base = url.substring(0, url.length() - "PublicTests.java".length());
            String slug = base.substring(base.lastIndexOf('/', base.length() - 2) + 1, base.length() - 1);
            String starter = read(resolver, base + FILES[0]);
            List<String> requirements = read(resolver, base + FILES[2]).lines()
                    .map(String::trim).filter(line -> !line.isEmpty()).toList();
            result.add(new ChallengeContent(slug, starter, read(resolver, url), requirements));
        }
        result.sort(Comparator.comparing(ChallengeContent::slug));
        return result;
    }

    private static String read(PathMatchingResourcePatternResolver resolver, String location) throws IOException {
        try (var in = resolver.getResource(location).getInputStream()) {
            return new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}
