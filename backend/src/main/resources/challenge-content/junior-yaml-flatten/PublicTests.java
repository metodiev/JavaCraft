import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static Map<String, Object> map(Object... entries) {
        Map<String, Object> map = new LinkedHashMap<>();
        for (int i = 0; i < entries.length; i += 2) {
            map.put((String) entries[i], entries[i + 1]);
        }
        return map;
    }

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("flat scalars become string values", () -> {
            Map<String, String> flat = Main.flatten(map("name", "app", "port", 8080));
            return flat.size() == 2 && "app".equals(flat.get("name")) && "8080".equals(flat.get("port"));
        });
        t.put("nested maps use dot-separated keys", () -> {
            Map<String, String> flat = Main.flatten(map("server", map("port", 8080, "tls", map("enabled", true))));
            return flat.size() == 2 && "8080".equals(flat.get("server.port"))
                    && "true".equals(flat.get("server.tls.enabled"));
        });
        t.put("three levels of nesting are joined", () -> {
            Map<String, String> flat = Main.flatten(map("a", map("b", map("c", "deep"))));
            return "deep".equals(flat.get("a.b.c"));
        });
        t.put("null values contribute no entry", () -> {
            Map<String, String> flat = Main.flatten(map("a", null, "b", "x"));
            return flat.size() == 1 && !flat.containsKey("a") && "x".equals(flat.get("b"));
        });
        t.put("empty nested maps contribute no keys", () -> {
            Map<String, String> flat = Main.flatten(map("a", map(), "b", "x"));
            return flat.size() == 1 && "x".equals(flat.get("b"));
        });
        t.put("entry order follows the input map", () -> {
            Map<String, String> flat = Main.flatten(map("z", 1, "a", map("b", 2)));
            return new ArrayList<>(flat.keySet()).equals(List.of("z", "a.b"));
        });
        t.put("booleans and negative numbers are stringified", () -> {
            Map<String, String> flat = Main.flatten(map("on", false, "t", -1));
            return "false".equals(flat.get("on")) && "-1".equals(flat.get("t"));
        });
        t.put("a null map, a null key and a list value are rejected", () -> {
            try { Main.flatten(null); return false; } catch (IllegalArgumentException e) { }
            try { Main.flatten(map(null, "x")); return false; } catch (IllegalArgumentException e) { }
            try { Main.flatten(map("items", List.of("a"))); return false; } catch (IllegalArgumentException e) { }
            return true;
        });
        return t;
    }
}
