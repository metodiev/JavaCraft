import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null inputs translate to an empty model", () ->
                Main.translate(null, null).isEmpty()
                        && Main.translate(Map.of("a", 1), null).isEmpty()
                        && Main.translate(null, Map.of("a", "x")).isEmpty());
        t.put("a mapped field is renamed", () ->
                Main.translate(Map.of("order_id", 7L), Map.of("order_id", "orderId"))
                        .equals(Map.of("orderId", 7L)));
        t.put("unmapped external fields are dropped", () ->
                Main.translate(Map.of("a", 1, "b", 2), Map.of("a", "x"))
                        .equals(Map.of("x", 1)));
        t.put("missing external fields are skipped", () ->
                Main.translate(Map.of("a", 1), Map.of("a", "x", "b", "y"))
                        .equals(Map.of("x", 1)));
        t.put("null and blank names are skipped", () -> {
            Map<String, String> fieldMap = new LinkedHashMap<>();
            fieldMap.put(null, "x");
            fieldMap.put("a", null);
            fieldMap.put("b", "  ");
            fieldMap.put("c", "z");
            return Main.translate(Map.of("a", 1, "b", 2, "c", 3), fieldMap).equals(Map.of("z", 3));
        });
        t.put("the first mapping wins for a shared internal name", () -> {
            Map<String, String> fieldMap = new LinkedHashMap<>();
            fieldMap.put("a", "x");
            fieldMap.put("b", "x");
            return Main.translate(new LinkedHashMap<>(Map.of("a", 1, "b", 2)), fieldMap)
                    .equals(Map.of("x", 1));
        });
        t.put("null values are carried across", () -> {
            Map<String, Object> result = Main.translate(
                    Collections.singletonMap("a", null), Map.of("a", "x"));
            return result.containsKey("x") && result.get("x") == null && result.size() == 1;
        });
        t.put("the internal order follows the field map", () -> {
            Map<String, String> fieldMap = new LinkedHashMap<>();
            fieldMap.put("b", "y");
            fieldMap.put("a", "x");
            return new ArrayList<>(Main.translate(Map.of("a", 1, "b", 2), fieldMap).keySet())
                    .equals(List.of("y", "x"));
        });
        return t;
    }
}
