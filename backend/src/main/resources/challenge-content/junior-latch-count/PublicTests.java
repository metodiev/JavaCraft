import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts the workers that have not finished", () -> Main.latchCount(5, 2) == 3);
        t.put("no progress leaves every worker waiting", () -> Main.latchCount(4, 0) == 4);
        t.put("a completed latch is zero", () -> Main.latchCount(3, 3) == 0);
        t.put("extra completions never go negative", () -> Main.latchCount(3, 5) == 0);
        t.put("a negative progress count is treated as zero", () -> Main.latchCount(3, -2) == 3);
        t.put("an empty latch needs no workers", () -> Main.latchCount(0, 0) == 0);
        t.put("negative workers are rejected", () -> {
            try {
                Main.latchCount(-1, 0);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
