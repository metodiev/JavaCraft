import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("transient failure with budget retries", () -> Main.shouldRetry(1, 3, Duration.ofMillis(500), true));
        t.put("non-transient failure does not retry", () -> !Main.shouldRetry(1, 3, Duration.ofMillis(500), false));
        t.put("last attempt does not retry", () -> !Main.shouldRetry(3, 3, Duration.ofMillis(500), true));
        t.put("exhausted time budget does not retry", () -> !Main.shouldRetry(1, 3, Duration.ZERO, true)
                && !Main.shouldRetry(1, 3, Duration.ofMillis(-5), true));
        t.put("null remaining time is rejected", () -> {
            try { Main.shouldRetry(1, 3, null, true); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("invalid attempts are rejected", () -> {
            try { Main.shouldRetry(0, 3, Duration.ofSeconds(1), true); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
