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
        t.put("the discriminator is added under the type key", () -> {
            Map<String, Object> result = Main.envelope("card", map("id", "1"));
            return "card".equals(result.get("type"));
        });
        t.put("every body entry is preserved", () -> {
            Map<String, Object> result = Main.envelope("card", map("id", "1", "name", "ada"));
            return result.size() == 3 && "1".equals(result.get("id")) && "ada".equals(result.get("name"));
        });
        t.put("the discriminator comes first", () -> {
            Map<String, Object> result = Main.envelope("card", map("id", "1", "name", "ada"));
            return new ArrayList<>(result.keySet()).equals(List.of("type", "id", "name"));
        });
        t.put("the input body is not mutated", () -> {
            Map<String, Object> body = map("id", "1");
            Main.envelope("card", body);
            return body.size() == 1 && !body.containsKey("type");
        });
        t.put("a copied envelope keeps the discriminator", () -> {
            Map<String, Object> copy = new LinkedHashMap<>(Main.envelope("card", map("id", "1")));
            return "card".equals(copy.get("type")) && "1".equals(copy.get("id"));
        });
        t.put("an empty body still carries the discriminator", () -> {
            Map<String, Object> result = Main.envelope("empty", Map.of());
            return result.size() == 1 && "empty".equals(result.get("type"));
        });
        t.put("a body that already has a type key is rejected", () -> {
            try { Main.envelope("card", map("type", "other")); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        t.put("a null type or body is rejected", () -> {
            try { Main.envelope(null, Map.of()); return false; } catch (IllegalArgumentException e) { }
            try { Main.envelope("card", null); return false; } catch (IllegalArgumentException e) { }
            return true;
        });
        return t;
    }
}
