import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a null or empty switch has no handlers", () ->
                Main.extract(null).isEmpty() && Main.extract(Map.of()).isEmpty());
        t.put("a case key becomes a camel case handler name", () ->
                Main.extract(new LinkedHashMap<>(Map.of("STANDARD", "ship standard"))).entrySet().stream()
                        .findFirst().map(e -> e.getKey().equals("STANDARD") && e.getValue().equals("shipStandard"))
                        .orElse(false));
        t.put("handler names use the case key, never the branch text", () ->
                Main.extract(new LinkedHashMap<>(Map.of("PLATINUM", "if (tier == PLATINUM) doSomething();")))
                        .equals(Map.of("PLATINUM", "shipPlatinum")));
        t.put("multi word keys become camel case", () ->
                Main.extract(new LinkedHashMap<>(Map.of("EXPRESS_SHIPPING", "do the express thing")))
                        .equals(Map.of("EXPRESS_SHIPPING", "shipExpressShipping")));
        t.put("every case key is handled", () ->
                Main.extract(Map.of("A", "x", "B", "y", "C", "z")).size() == 3
                        && Main.extract(Map.of("A", "x", "B", "y", "C", "z")).values().containsAll(
                                List.of("shipA", "shipB", "shipC")));
        t.put("blank and null keys are skipped", () -> {
            Map<String, String> cases = new LinkedHashMap<>();
            cases.put(null, "x");
            cases.put("   ", "y");
            cases.put("OK", "z");
            return Main.extract(cases).equals(Map.of("OK", "shipOk"));
        });
        t.put("keys that already read as identifiers are lower cased in the method name", () ->
                Main.extract(new LinkedHashMap<>(Map.of("ALREADY", "text"))).equals(Map.of("ALREADY", "shipAlready")));
        t.put("all handler names start with the ship verb", () ->
                Main.extract(Map.of("ONE", "a", "TWO", "b")).values().stream()
                        .allMatch(name -> name.startsWith("ship")));
        return t;
    }
}
