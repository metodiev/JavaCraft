import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equals builds a placeholder clause", () -> Main.whereFor("email", "=", 1).equals("email = ?"));
        t.put("inequality builds a placeholder clause", () -> Main.whereFor("status", "<>", 2).equals("status <> ?"));
        t.put("parameter index one is written into the clause", () -> Main.whereFor("id", ">=", 7).equals("id >= ?"));
        t.put("range operator is accepted", () -> Main.whereFor("created_at", "<", 3).equals("created_at < ?"));
        t.put("value is never interpolated into the clause", () -> !Main.whereFor("email", "=", 1).contains("'")
                && Main.whereFor("email", "=", 1).endsWith("?"));
        t.put("unknown column is rejected", () -> rejects("password", "=", 1)
                && rejects("email; DROP TABLE users", "=", 1));
        t.put("unknown operator is rejected", () -> rejects("email", "LIKE", 1)
                && rejects("email", "OR 1=1", 1));
        t.put("non-positive parameter index is rejected", () -> rejects("email", "=", 0) && rejects("email", "=", -3));
        t.put("null column or operator is rejected", () -> {
            try { Main.whereFor(null, "=", 1); return false; } catch (IllegalArgumentException e) {
                try { Main.whereFor("email", null, 1); return false; } catch (IllegalArgumentException e2) { return true; }
            }
        });
        return t;
    }

    private static boolean rejects(String column, String operator, int parameterIndex) {
        try { Main.whereFor(column, operator, parameterIndex); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
