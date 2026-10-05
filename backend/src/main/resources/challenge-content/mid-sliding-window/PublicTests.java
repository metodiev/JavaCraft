import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("finds the best window in the middle", () -> Main.maxWindowSum(new int[]{1, 4, 2, 10, 23, 3, 1, 0, 20}, 4) == 39);
        t.put("window equal to the array sums everything", () -> Main.maxWindowSum(new int[]{2, 3, 5}, 3) == 10);
        t.put("window of one is the largest single value", () -> Main.maxWindowSum(new int[]{3, -1, 8, 2}, 1) == 8);
        t.put("negative values are handled", () -> Main.maxWindowSum(new int[]{-5, -2, -9, -1}, 2) == -7);
        t.put("window larger than the array is invalid", () -> Main.maxWindowSum(new int[]{1, 2}, 3) == 0);
        t.put("non-positive windows are invalid", () -> Main.maxWindowSum(new int[]{1, 2}, 0) == 0 && Main.maxWindowSum(new int[]{1, 2}, -1) == 0);
        t.put("null and empty input are invalid", () -> Main.maxWindowSum(null, 2) == 0 && Main.maxWindowSum(new int[0], 1) == 0);
        t.put("stays fast for a few hundred elements", () -> {
            int[] values = new int[500];
            for (int i = 0; i < values.length; i++) {
                values[i] = (i % 7) - 3;
            }
            return Main.maxWindowSum(values, 5) == 5;
        });
        return t;
    }
}
