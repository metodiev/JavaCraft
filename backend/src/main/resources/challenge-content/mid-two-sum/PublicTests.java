import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("finds the first matching pair", () -> Arrays.equals(Main.twoSum(new int[]{2, 7, 11, 15}, 9), new int[]{0, 1}));
        t.put("uses the smallest second index when several pairs match", () ->
                Arrays.equals(Main.twoSum(new int[]{1, 2, 3, 4}, 5), new int[]{1, 2}));
        t.put("handles negative values", () -> Arrays.equals(Main.twoSum(new int[]{-3, 4, 3, 90}, 0), new int[]{0, 2}));
        t.put("a value cannot pair with itself", () -> Main.twoSum(new int[]{4, 1, 2}, 8).length == 0);
        t.put("returns empty when no pair exists", () -> Main.twoSum(new int[]{1, 2, 3}, 100).length == 0);
        t.put("duplicates can form a pair", () -> Arrays.equals(Main.twoSum(new int[]{3, 3}, 6), new int[]{0, 1}));
        t.put("null and short input yield empty", () -> Main.twoSum(null, 5).length == 0 && Main.twoSum(new int[]{1}, 1).length == 0);
        t.put("supports large values without overflow", () ->
                Arrays.equals(Main.twoSum(new int[]{Integer.MAX_VALUE, 1, -1}, 0), new int[]{1, 2}));
        return t;
    }
}
