import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("adding a nullable column is safe", () -> Main.classify("ALTER TABLE users ADD COLUMN nickname text", false)
                .equals("SAFE"));
        t.put("creating an index concurrently is safe", () -> Main.classify("CREATE INDEX CONCURRENTLY idx_users_email ON users (email)", true)
                .equals("SAFE"));
        t.put("a plain index build on a large table needs a lock", () -> Main.classify("CREATE INDEX idx_users_email ON users (email)", true)
                .equals("REQUIRES_LOCK"));
        t.put("the same index build is safe on a small table", () -> Main.classify("CREATE INDEX idx_users_email ON users (email)", false)
                .equals("SAFE"));
        t.put("a default value on a large table requires a backfill", () -> Main.classify("ALTER TABLE users ADD COLUMN tier int DEFAULT 1", true)
                .equals("REQUIRES_BACKFILL"));
        t.put("a type change requires a backfill", () -> Main.classify("ALTER TABLE users ALTER COLUMN age TYPE bigint", true)
                .equals("REQUIRES_BACKFILL"));
        t.put("a set not null requires a backfill", () -> Main.classify("ALTER TABLE users ALTER COLUMN email SET NOT NULL", true)
                .equals("REQUIRES_BACKFILL"));
        t.put("case and spacing do not change the class", () -> Main.classify("  alter table users add column nickname text  ", true)
                .equals("SAFE"));
        t.put("null or blank statements are rejected", () -> rejects(null, false) && rejects("   ", false));
        return t;
    }

    private static boolean rejects(String statement, boolean largeTable) {
        try { Main.classify(statement, largeTable); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
