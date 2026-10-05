import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("one child per parent does not fan out", () -> !Main.hasFanout(Map.of("a", 1, "b", 1), Map.of("a", 1, "b", 1)));
        t.put("a parent with two children fans out", () -> Main.hasFanout(Map.of("a", 1, "b", 1), Map.of("a", 2)));
        t.put("children without a parent do not fan out", () -> !Main.hasFanout(Map.of("a", 1), Map.of("b", 5)));
        t.put("duplicate parents multiply the join", () -> Main.hasFanout(Map.of("a", 2), Map.of("a", 3)));
        t.put("matching rows are not fan-out", () -> !Main.hasFanout(Map.of("a", 1, "b", 1, "c", 1), Map.of("a", 1, "b", 1, "c", 1)));
        t.put("non-positive counts contribute no rows", () -> !Main.hasFanout(Map.of("a", 1, "b", 1), Map.of("a", 0, "b", 1)));
        t.put("empty maps do not fan out", () -> !Main.hasFanout(Map.of(), Map.of()));
        t.put("null maps are treated as empty", () -> !Main.hasFanout(null, null));
        return t;
    }
}
