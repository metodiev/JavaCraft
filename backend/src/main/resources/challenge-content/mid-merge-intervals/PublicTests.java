import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("merges overlapping intervals", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{1, 3}, new int[]{2, 6}, new int[]{8, 10}));
            return merged.size() == 2
                    && Arrays.equals(merged.get(0), new int[]{1, 6})
                    && Arrays.equals(merged.get(1), new int[]{8, 10});
        });
        t.put("touching intervals merge", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{1, 4}, new int[]{4, 5}));
            return merged.size() == 1 && Arrays.equals(merged.get(0), new int[]{1, 5});
        });
        t.put("unsorted input is sorted first", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{8, 10}, new int[]{1, 3}, new int[]{2, 6}));
            return Arrays.equals(merged.get(0), new int[]{1, 6}) && Arrays.equals(merged.get(1), new int[]{8, 10});
        });
        t.put("nested intervals collapse", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{1, 10}, new int[]{2, 3}));
            return merged.size() == 1 && Arrays.equals(merged.get(0), new int[]{1, 10});
        });
        t.put("disjoint intervals stay separate", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{1, 2}, new int[]{5, 6}));
            return merged.size() == 2;
        });
        t.put("empty and null input yield an empty list", () ->
                Main.merge(List.of()).isEmpty() && Main.merge(null).isEmpty());
        t.put("single interval is returned as is", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{7, 9}));
            return merged.size() == 1 && Arrays.equals(merged.get(0), new int[]{7, 9});
        });
        t.put("duplicate intervals merge once", () -> {
            List<int[]> merged = Main.merge(List.of(new int[]{2, 4}, new int[]{2, 4}));
            return merged.size() == 1 && Arrays.equals(merged.get(0), new int[]{2, 4});
        });
        return t;
    }
}
