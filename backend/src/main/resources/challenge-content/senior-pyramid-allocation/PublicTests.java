import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a balanced suite splits sixty thirty ten", () ->
                Main.allocate(100, false, false).equals(Map.of("unit", 60, "integration", 30, "endToEnd", 10)));
        t.put("logic heavy suites weight the unit level", () ->
                Main.allocate(100, true, false).equals(Map.of("unit", 70, "integration", 20, "endToEnd", 10)));
        t.put("io heavy suites weight the integration level", () ->
                Main.allocate(100, false, true).equals(Map.of("unit", 50, "integration", 40, "endToEnd", 10)));
        t.put("logic and io heavy keep the balanced split", () ->
                Main.allocate(100, true, true).equals(Map.of("unit", 60, "integration", 30, "endToEnd", 10)));
        t.put("parts always add up to the total", () -> {
            Map<String, Integer> split = Main.allocate(25, true, false);
            return split.get("unit") + split.get("integration") + split.get("endToEnd") == 25;
        });
        t.put("rounding uses the largest remainder so parts sum to the total", () ->
                Main.allocate(5, false, false).equals(Map.of("unit", 3, "integration", 2, "endToEnd", 0)));
        t.put("a tiny suite gives the unit level the first slot", () ->
                Main.allocate(1, false, true).equals(Map.of("unit", 1, "integration", 0, "endToEnd", 0))
                        && Main.allocate(1, true, false).equals(Map.of("unit", 1, "integration", 0, "endToEnd", 0)));
        t.put("non-positive totals and null keys are handled", () -> {
            Map<String, Integer> zero = Main.allocate(0, true, true);
            return zero.size() == 3 && zero.values().stream().allMatch(v -> v == 0)
                    && Main.allocate(-5, false, false).get("unit") == 0
                    && Main.allocate(100, true, true).keySet().stream().noneMatch(Objects::isNull);
        });
        return t;
    }
}
