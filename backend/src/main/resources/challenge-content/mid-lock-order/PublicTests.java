import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("tables are returned in ascending name order", () -> Main.lockOrder(List.of("users", "orders", "accounts"))
                .equals(List.of("accounts", "orders", "users")));
        t.put("already sorted input is unchanged", () -> Main.lockOrder(List.of("accounts", "orders"))
                .equals(List.of("accounts", "orders")));
        t.put("input order does not change the result", () -> {
            List<String> a = Main.lockOrder(List.of("orders", "accounts", "users"));
            List<String> b = Main.lockOrder(List.of("users", "orders", "accounts"));
            return a.equals(b) && a.equals(List.of("accounts", "orders", "users"));
        });
        t.put("a single table is its own order", () -> Main.lockOrder(List.of("orders")).equals(List.of("orders")));
        t.put("empty input stays empty", () -> Main.lockOrder(List.of()).isEmpty());
        t.put("null input is rejected", () -> rejects(null));
        t.put("null table name is rejected", () -> rejects(Arrays.asList("orders", null)));
        t.put("input list is not modified", () -> {
            List<String> tables = new ArrayList<>(List.of("users", "orders"));
            Main.lockOrder(tables);
            return tables.equals(List.of("users", "orders"));
        });
        return t;
    }

    private static boolean rejects(List<String> tables) {
        try { Main.lockOrder(tables); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
