import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("without overrides the base is returned as is", () ->
                Main.effective(new LinkedHashMap<>(Map.of("app.port", "8080")), List.of()).equals(Map.of("app.port", "8080")));
        t.put("a later profile overrides an earlier one", () -> {
            Map<String, String> base = new LinkedHashMap<>(Map.of("app.port", "8080"));
            List<Map<String, String>> overrides = List.of(
                    new LinkedHashMap<>(Map.of("app.port", "9090")),
                    new LinkedHashMap<>(Map.of("app.port", "7070")));
            return Main.effective(base, overrides).equals(Map.of("app.port", "7070"));
        });
        t.put("base keys are preserved when no profile overrides them", () -> {
            Map<String, String> base = new LinkedHashMap<>(Map.of("app.name", "orders", "app.port", "8080"));
            return Main.effective(base, List.of(Map.of("app.port", "9090"))).equals(new LinkedHashMap<>(Map.of("app.name", "orders", "app.port", "9090")));
        });
        t.put("keys from different profiles accumulate", () -> {
            Map<String, String> base = new LinkedHashMap<>();
            base.put("host", "localhost");
            List<Map<String, String>> overrides = List.of(
                    new LinkedHashMap<>(Map.of("a", "1")),
                    new LinkedHashMap<>(Map.of("b", "2")));
            return Main.effective(base, overrides).equals(new LinkedHashMap<>(Map.of("host", "localhost", "a", "1", "b", "2")));
        });
        t.put("a null base is an empty map", () ->
                Main.effective(null, List.of(Map.of("a", "1"))).equals(Map.of("a", "1")));
        t.put("null or empty overrides are ignored", () -> {
            Map<String, String> base = new LinkedHashMap<>(Map.of("a", "1"));
            return Main.effective(base, null).equals(Map.of("a", "1"))
                    && Main.effective(base, List.of()).equals(Map.of("a", "1"))
                    && Main.effective(base, Arrays.asList(null, Map.of())).equals(Map.of("a", "1"));
        });
        t.put("the base map is not modified", () -> {
            Map<String, String> base = new LinkedHashMap<>(Map.of("app.port", "8080"));
            Map<String, String> result = Main.effective(base, List.of(Map.of("app.port", "9090")));
            return base.get("app.port").equals("8080") && result.get("app.port").equals("9090");
        });
        t.put("a null value in a profile overrides an earlier value", () -> {
            Map<String, String> base = new LinkedHashMap<>(Map.of("app.port", "8080"));
            Map<String, String> override = new LinkedHashMap<>();
            override.put("app.port", null);
            Map<String, String> result = Main.effective(base, List.of(override));
            return result.containsKey("app.port") && result.get("app.port") == null;
        });
        t.put("an empty profile map changes nothing", () -> {
            Map<String, String> base = new LinkedHashMap<>(Map.of("app.port", "8080"));
            return Main.effective(base, List.of(new LinkedHashMap<>())).equals(Map.of("app.port", "8080"));
        });
        return t;
    }
}
