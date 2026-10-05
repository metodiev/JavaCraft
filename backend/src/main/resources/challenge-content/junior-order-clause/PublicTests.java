import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("single column defaults to ascending", () -> Main.orderBy(List.of("email"), false).equals("email ASC"));
        t.put("single column can be descending", () -> Main.orderBy(List.of("created_at"), true).equals("created_at DESC"));
        t.put("multiple columns keep their order", () -> Main.orderBy(List.of("status", "id"), false).equals("status ASC, id ASC"));
        t.put("direction applies to every column", () -> Main.orderBy(List.of("status", "id"), true)
                .equals("status DESC, id DESC"));
        t.put("empty column list is rejected", () -> rejects(List.of(), true));
        t.put("unknown column is rejected", () -> rejects(List.of("email", "password"), false)
                && rejects(List.of("email; DROP TABLE users"), false));
        t.put("null list or null column is rejected", () -> {
            try { Main.orderBy(null, false); return false; } catch (IllegalArgumentException e) {
                try { Main.orderBy(Arrays.asList("id", null), true); return false; }
                catch (IllegalArgumentException e2) { return true; }
            }
        });
        return t;
    }

    private static boolean rejects(List<String> columns, boolean descending) {
        try { Main.orderBy(columns, descending); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
