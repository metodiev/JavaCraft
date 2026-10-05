import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("multiplies the tag cardinalities", () -> Main.cardinality(List.of(3, 4, 5)) == 60);
        t.put("a single tag keeps its size", () -> Main.cardinality(List.of(7)) == 7);
        t.put("an empty tag list is one series", () -> Main.cardinality(List.of()) == 1);
        t.put("a zero-cardinality tag yields zero", () -> Main.cardinality(List.of(5, 0, 9)) == 0);
        t.put("a large product that still fits the long range is exact",
                () -> Main.cardinality(List.of(Integer.MAX_VALUE, Integer.MAX_VALUE)) == 4611686014132420609L);
        t.put("an overflowing product clamps at Long.MAX_VALUE",
                () -> Main.cardinality(List.of(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE))
                        == Long.MAX_VALUE);
        t.put("an already clamped product stays clamped",
                () -> Main.cardinality(List.of(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE, 2))
                        == Long.MAX_VALUE);
        t.put("risky is true above the limit and false at it",
                () -> !Main.risky(List.of(10_000)) && Main.risky(List.of(10_001)) && Main.risky(List.of(100, 200)));
        t.put("null tags or negative sizes are rejected",
                () -> rejects(null) && rejects(List.of(3, -1)) && rejects(Arrays.asList(3, null)));
        return t;
    }

    private static boolean rejects(List<Integer> tagSizes) {
        try {
            Main.cardinality(tagSizes);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
