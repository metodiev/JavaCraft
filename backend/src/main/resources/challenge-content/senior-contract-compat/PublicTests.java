import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("matching contracts report no violations", () ->
                Main.violations(Map.of("id", "string", "amount", "decimal"),
                        Map.of("id", "string", "amount", "decimal")).isEmpty());
        t.put("missing fields are reported", () ->
                Main.violations(Map.of("id", "string"),
                                Map.of("id", "string", "amount", "decimal", "currency", "string"))
                        .equals(List.of("missing:amount", "missing:currency")));
        t.put("type mismatches are reported", () ->
                Main.violations(Map.of("amount", "int"), Map.of("amount", "decimal"))
                        .equals(List.of("type:amount")));
        t.put("violations are sorted", () ->
                Main.violations(Map.of("z", "int"), Map.of("a", "string", "z", "string"))
                        .equals(List.of("missing:a", "type:z")));
        t.put("extra provided fields are allowed", () ->
                Main.violations(Map.of("id", "string", "trace", "string"), Map.of("id", "string")).isEmpty());
        t.put("null maps are handled", () ->
                Main.violations(null, Map.of("id", "string")).equals(List.of("missing:id"))
                        && Main.violations(Map.of("id", "string"), null).isEmpty());
        t.put("a null provided field counts as missing", () -> {
            Map<String, String> provided = new HashMap<>();
            provided.put("id", null);
            return Main.violations(provided, Map.of("id", "string")).equals(List.of("missing:id"));
        });
        t.put("field names are case sensitive", () ->
                Main.violations(Map.of("ID", "string"), Map.of("id", "string")).equals(List.of("missing:id")));
        return t;
    }
}
