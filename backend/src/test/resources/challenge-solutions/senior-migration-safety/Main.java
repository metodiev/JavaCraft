import java.util.Locale;

public class Main {
    public static String classify(String statement, boolean largeTable) {
        if (statement == null || statement.isBlank()) {
            throw new IllegalArgumentException("statement is required");
        }
        String normalized = statement.trim().toUpperCase(Locale.ROOT);
        if (normalized.contains("CONCURRENTLY") || !largeTable) {
            return "SAFE";
        }
        if (normalized.startsWith("CREATE INDEX")) {
            return "REQUIRES_LOCK";
        }
        boolean addsColumnWithDefault = normalized.contains("ADD COLUMN") && normalized.contains("DEFAULT");
        boolean changesType = normalized.contains("ALTER COLUMN") && normalized.contains(" TYPE ");
        boolean setsNotNull = normalized.contains("SET NOT NULL");
        if (normalized.startsWith("ALTER TABLE") && (addsColumnWithDefault || changesType || setsNotNull)) {
            return "REQUIRES_BACKFILL";
        }
        return "SAFE";
    }
}
