import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a single aspect enters and exits", () -> {
            Map<String, Integer> aspects = new LinkedHashMap<>();
            aspects.put("Timing", 1);
            return Main.executionOrder(aspects).equals(List.of("Timing in", "Timing out"));
        });
        t.put("lower order values enter first and leave last", () -> {
            Map<String, Integer> aspects = new LinkedHashMap<>();
            aspects.put("Security", 10);
            aspects.put("Timing", 20);
            return Main.executionOrder(aspects).equals(List.of("Security in", "Timing in", "Timing out", "Security out"));
        });
        t.put("the map iteration order does not matter", () -> {
            Map<String, Integer> reversed = new LinkedHashMap<>();
            reversed.put("Timing", 20);
            reversed.put("Security", 10);
            return Main.executionOrder(reversed).equals(List.of("Security in", "Timing in", "Timing out", "Security out"));
        });
        t.put("equal order values are broken by name", () -> {
            Map<String, Integer> aspects = new LinkedHashMap<>();
            aspects.put("Beta", 5);
            aspects.put("Alpha", 5);
            return Main.executionOrder(aspects).equals(List.of("Alpha in", "Beta in", "Beta out", "Alpha out"));
        });
        t.put("three aspects nest correctly", () -> {
            Map<String, Integer> aspects = new LinkedHashMap<>();
            aspects.put("Third", 30);
            aspects.put("First", 10);
            aspects.put("Second", 20);
            return Main.executionOrder(aspects).equals(List.of(
                    "First in", "Second in", "Third in", "Third out", "Second out", "First out"));
        });
        t.put("an empty aspect map produces no callbacks", () -> Main.executionOrder(new LinkedHashMap<>()).isEmpty());
        t.put("a null aspect map produces no callbacks", () -> Main.executionOrder(null).isEmpty());
        t.put("negative order values still run first", () -> {
            Map<String, Integer> aspects = new LinkedHashMap<>();
            aspects.put("Later", 0);
            aspects.put("Earlier", -10);
            return Main.executionOrder(aspects).equals(List.of("Earlier in", "Later in", "Later out", "Earlier out"));
        });
        t.put("null aspect names are skipped", () -> {
            Map<String, Integer> aspects = new LinkedHashMap<>();
            aspects.put(null, 1);
            aspects.put("Timing", 2);
            return Main.executionOrder(aspects).equals(List.of("Timing in", "Timing out"));
        });
        return t;
    }
}
