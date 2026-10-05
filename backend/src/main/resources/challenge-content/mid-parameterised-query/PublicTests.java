import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null or blank sql has no violations", () -> Main.violations(null).isEmpty() && Main.violations("   ").isEmpty());
        t.put("parameterised query is clean", () -> Main.violations(
                "SELECT id FROM users WHERE name = ? ORDER BY id").isEmpty());
        t.put("plain order by columns are safe", () -> Main.violations(
                "SELECT id FROM users ORDER BY created_at DESC, id").isEmpty());
        t.put("concatenated value is flagged", () -> Main.violations(
                "SELECT id FROM users WHERE name = '\" + name + \"'").equals(List.of("string concatenation")));
        t.put("placeholder order by is flagged", () -> Main.violations(
                "SELECT id FROM users ORDER BY ?").equals(List.of("unsafe ORDER BY interpolation")));
        t.put("comment markers are flagged", () -> Main.violations(
                "SELECT id FROM users WHERE id = 1 -- bypass").equals(List.of("comment injection marker"))
                && Main.violations("SELECT id FROM users WHERE id = 1 /* bypass */").equals(List.of("comment injection marker")));
        t.put("order by with an expression is flagged", () -> Main.violations(
                "SELECT id FROM users ORDER BY (SELECT 1)").equals(List.of("unsafe ORDER BY interpolation")));
        t.put("violations appear in order of first occurrence", () -> Main.violations(
                "SELECT * FROM t WHERE a = '\" + a + \"' ORDER BY ? -- x").equals(List.of(
                "string concatenation", "unsafe ORDER BY interpolation", "comment injection marker")));
        return t;
    }
}
