import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("compacts duplicates and reports the count", () -> {
            int[] values = {1, 1, 2, 2, 3};
            return Main.uniqueCount(values) == 3 && Arrays.equals(Arrays.copyOf(values, 3), new int[]{1, 2, 3});
        });
        t.put("keeps an already unique array unchanged", () -> {
            int[] values = {1, 2, 3};
            return Main.uniqueCount(values) == 3 && Arrays.equals(values, new int[]{1, 2, 3});
        });
        t.put("collapses a single repeated value to one", () -> {
            int[] values = {4, 4, 4, 4};
            return Main.uniqueCount(values) == 1 && values[0] == 4;
        });
        t.put("empty array has zero distinct values", () -> {
            int[] values = {};
            return Main.uniqueCount(values) == 0;
        });
        t.put("null array has zero distinct values", () -> Main.uniqueCount(null) == 0);
        t.put("single element stays put", () -> {
            int[] values = {9};
            return Main.uniqueCount(values) == 1 && values[0] == 9;
        });
        t.put("negative values are distinct", () -> {
            int[] values = {-3, -3, -1, 0, 0};
            return Main.uniqueCount(values) == 3 && Arrays.equals(Arrays.copyOf(values, 3), new int[]{-3, -1, 0});
        });
        return t;
    }
}
