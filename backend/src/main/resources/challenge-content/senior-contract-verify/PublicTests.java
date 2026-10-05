import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static Map<String, Object> contract() {
        Map<String, Object> c = new LinkedHashMap<>();
        c.put("id", "number");
        c.put("name", "string");
        c.put("active", "boolean");
        return c;
    }

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a fully matching payload has no violations", () ->
                Main.violations(contract(),
                        Map.of("id", 7, "name", "Ada", "active", true)).isEmpty());
        t.put("the number type accepts longs", () ->
                Main.violations(contract(),
                        Map.of("id", 9007199254740993L, "name", "Ada", "active", true)).isEmpty());
        t.put("extra payload keys are allowed", () ->
                Main.violations(contract(),
                        Map.of("id", 7, "name", "Ada", "active", true, "nickname", "A")).isEmpty());
        t.put("a missing key is reported", () ->
                Main.violations(contract(), Map.of("id", 7, "active", true))
                        .equals(List.of("missing: name")));
        t.put("several missing keys are sorted together", () ->
                Main.violations(contract(), Map.of())
                        .equals(List.of("missing: active", "missing: id", "missing: name")));
        t.put("a type mismatch reports both types", () ->
                Main.violations(contract(), Map.of("id", "seven", "name", "Ada", "active", true))
                        .equals(List.of("type: id expected number but was string")));
        t.put("a missing key is never also a type mismatch", () ->
                Main.violations(contract(), Map.of("name", 4))
                        .equals(List.of("missing: active", "missing: id", "type: name expected string but was number")));
        t.put("null and empty inputs are handled", () ->
                Main.violations(null, Map.of("id", 7)).isEmpty()
                        && Main.violations(Map.of(), Map.of("extra", 1)).isEmpty());
        t.put("boolean and string mismatches are detected", () ->
                Main.violations(contract(), Map.of("id", 1, "name", 2, "active", "yes"))
                        .equals(List.of("type: active expected boolean but was string",
                                "type: name expected string but was number")));
        return t;
    }
}
