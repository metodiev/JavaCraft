import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a large population starts at ten percent", () -> Main.percent(1_000_000, 1_000, false) == 10);
        t.put("a high risk rollout halves the percentage", () -> Main.percent(1_000_000, 1_000, true) == 5);
        t.put("a small population is raised to hit the minimum sample", () ->
                Main.percent(2_000, 1_000, false) == 50);
        t.put("the minimum winning percentage is at least one", () ->
                Main.percent(50_000, 1, false) == 10);
        t.put("the result never exceeds one hundred", () -> {
            for (int total : new int[] {1, 10, 100, 1_000_000}) {
                if (Main.percent(total, 10_000, false) > 100) {
                    return false;
                }
            }
            return true;
        });
        t.put("an exact ten percent population keeps ten percent", () -> Main.percent(10_000, 1_000, false) == 10);
        t.put("a non-positive population is rejected", () -> {
            try { Main.percent(0, 1, false); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("a non-positive minimum sample is rejected", () -> {
            try { Main.percent(100, 0, false); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("a high risk rollout on a tiny population is never zero", () -> {
            int value = Main.percent(1, 100, true);
            return value >= 1 && value <= 100;
        });
        return t;
    }
}
