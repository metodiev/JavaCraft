import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("demand below the remaining capacity passes through", () -> Main.requested(10, 0, 100) == 10);
        t.put("demand is clamped to the remaining capacity", () -> Main.requested(50, 90, 100) == 10);
        t.put("a full buffer requests nothing", () -> Main.requested(5, 100, 100) == 0);
        t.put("an overfull buffer requests nothing", () -> Main.requested(5, 120, 100) == 0);
        t.put("zero demand requests nothing", () -> Main.requested(0, 0, 100) == 0);
        t.put("negative demand is treated as zero", () -> Main.requested(-3, 0, 100) == 0);
        t.put("a request never exceeds the limit", () -> Main.requested(Long.MAX_VALUE, 0, 7) == 7);
        t.put("a negative buffered count is rejected", () -> rejects(-1, 100));
        t.put("a negative limit is rejected", () -> rejects(0, -100));
        return t;
    }

    private static boolean rejects(long buffered, long limit) {
        try {
            Main.requested(1, buffered, limit);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
