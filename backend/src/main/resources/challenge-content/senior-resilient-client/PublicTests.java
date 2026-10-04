import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("delay doubles each attempt", () -> Main.nextDelayMillis(1, 100, 10_000) == 100
                && Main.nextDelayMillis(2, 100, 10_000) == 200 && Main.nextDelayMillis(4, 100, 10_000) == 800);
        t.put("delay is capped", () -> Main.nextDelayMillis(10, 100, 1_000) == 1_000);
        t.put("huge attempt numbers do not overflow", () -> Main.nextDelayMillis(200, 100, 5_000) == 5_000
                && Main.nextDelayMillis(63, Long.MAX_VALUE / 2, Long.MAX_VALUE) == Long.MAX_VALUE);
        t.put("invalid delay arguments are rejected", () -> {
            try { Main.nextDelayMillis(0, 100, 1000); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("transient failure within budget retries", () -> Main.shouldRetry(1, 3, true,
                Duration.ofSeconds(1), Duration.ofSeconds(10)));
        t.put("permanent failure never retries", () -> !Main.shouldRetry(1, 3, false,
                Duration.ofSeconds(1), Duration.ofSeconds(10)));
        t.put("attempt budget is respected", () -> !Main.shouldRetry(3, 3, true,
                Duration.ofSeconds(1), Duration.ofSeconds(10)));
        t.put("deadline is respected", () -> !Main.shouldRetry(1, 3, true,
                Duration.ofSeconds(10), Duration.ofSeconds(10)));
        return t;
    }
}
