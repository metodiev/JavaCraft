import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static final long MILLI = 1_000_000L;

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no hops leaves the remaining budget unchanged", () -> Main.remainingMillis(500 * MILLI, 100 * MILLI, 0) == 400);
        t.put("each hop reserves ten milliseconds", () -> Main.remainingMillis(500 * MILLI, 100 * MILLI, 3) == 370);
        t.put("a missing deadline returns zero", () -> Main.remainingMillis(Long.MAX_VALUE, 0, 3) == 0);
        t.put("an expired deadline returns zero", () -> Main.remainingMillis(100 * MILLI, 500 * MILLI, 2) == 0);
        t.put("a deadline exactly now returns zero", () -> Main.remainingMillis(100 * MILLI, 100 * MILLI, 0) == 0);
        t.put("the reserve can exhaust a small budget", () -> Main.remainingMillis(30 * MILLI, 0, 5) == 0);
        t.put("negative hops are treated as no reserve", () -> Main.remainingMillis(500 * MILLI, 100 * MILLI, -4) == 400);
        t.put("partial milliseconds round down", () -> Main.remainingMillis(1_999_999L, 1_000_000L, 0) == 0);
        return t;
    }
}
