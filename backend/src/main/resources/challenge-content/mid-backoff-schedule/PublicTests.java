import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("each attempt doubles the previous delay", () -> Main.backoffMillis(4, 100, 10_000).equals(List.of(100L, 200L, 400L, 800L)));
        t.put("delays are clamped at the cap", () -> Main.backoffMillis(5, 100, 400).equals(List.of(100L, 200L, 400L, 400L, 400L)));
        t.put("a cap below the base clamps the first delay", () -> Main.backoffMillis(2, 100, 50).equals(List.of(50L, 50L)));
        t.put("zero attempts produce an empty schedule", () -> Main.backoffMillis(0, 100, 1_000).isEmpty());
        t.put("negative attempts produce an empty schedule", () -> Main.backoffMillis(-3, 100, 1_000).isEmpty());
        t.put("doubling never overflows the cap", () -> Main.backoffMillis(3, 1L << 62, Long.MAX_VALUE).equals(List.of(1L << 62, Long.MAX_VALUE, Long.MAX_VALUE)));
        t.put("a non-positive base is rejected", () -> {
            try {
                Main.backoffMillis(3, 0, 100);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("a non-positive cap is rejected", () -> {
            try {
                Main.backoffMillis(3, 100, 0);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
