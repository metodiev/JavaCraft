import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("picks the most valuable combination", () ->
                Main.maxValue(new int[]{1, 3, 4, 5}, new int[]{1, 4, 5, 7}, 7) == 9);
        t.put("an item heavier than the capacity is skipped", () ->
                Main.maxValue(new int[]{10, 2}, new int[]{100, 3}, 5) == 3);
        t.put("zero capacity allows nothing", () ->
                Main.maxValue(new int[]{1, 2}, new int[]{5, 6}, 0) == 0);
        t.put("each item can be taken at most once", () ->
                Main.maxValue(new int[]{3, 3}, new int[]{5, 5}, 5) == 5);
        t.put("mismatched arrays are rejected with zero", () ->
                Main.maxValue(new int[]{1, 2}, new int[]{5}, 5) == 0
                        && Main.maxValue(null, new int[]{5}, 5) == 0
                        && Main.maxValue(new int[]{1}, null, 5) == 0);
        t.put("non-positive capacity is rejected with zero", () ->
                Main.maxValue(new int[]{1}, new int[]{5}, -3) == 0);
        t.put("empty item list yields zero", () -> Main.maxValue(new int[0], new int[0], 10) == 0);
        t.put("handles a modest instance within the budget", () -> {
            int[] weights = new int[100];
            int[] values = new int[100];
            for (int i = 0; i < 100; i++) {
                weights[i] = (i % 10) + 1;
                values[i] = (i % 7) + 1;
            }
            return Main.maxValue(weights, values, 50) == 120;
        });
        return t;
    }
}
