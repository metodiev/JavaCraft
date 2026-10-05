import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("reverses an odd length array", () -> {
            int[] values = {1, 2, 3, 4, 5};
            Main.reverse(values);
            return Arrays.equals(values, new int[]{5, 4, 3, 2, 1});
        });
        t.put("reverses an even length array", () -> {
            int[] values = {1, 2, 3, 4};
            Main.reverse(values);
            return Arrays.equals(values, new int[]{4, 3, 2, 1});
        });
        t.put("keeps a single element in place", () -> {
            int[] values = {7};
            Main.reverse(values);
            return Arrays.equals(values, new int[]{7});
        });
        t.put("leaves an empty array empty", () -> {
            int[] values = {};
            Main.reverse(values);
            return values.length == 0;
        });
        t.put("null is untouched", () -> {
            Main.reverse(null);
            return true;
        });
        t.put("reverses duplicate values", () -> {
            int[] values = {5, 5, 1, 1};
            Main.reverse(values);
            return Arrays.equals(values, new int[]{1, 1, 5, 5});
        });
        t.put("applying it twice restores the order", () -> {
            int[] values = {9, 8, 7, 6};
            Main.reverse(values);
            Main.reverse(values);
            return Arrays.equals(values, new int[]{9, 8, 7, 6});
        });
        return t;
    }
}
