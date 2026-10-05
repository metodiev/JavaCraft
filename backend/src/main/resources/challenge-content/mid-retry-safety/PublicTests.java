import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("safe methods retry on a service unavailable", () -> Main.retryable("GET", 503, false)
                && Main.retryable("HEAD", 503, false) && Main.retryable("OPTIONS", 503, false));
        t.put("an unsafe method retries when it carries an idempotency key", () -> Main.retryable("POST", 503, true)
                && Main.retryable("PATCH", 500, true));
        t.put("an unsafe method without a key does not retry", () -> !Main.retryable("POST", 503, false)
                && !Main.retryable("DELETE", 500, false));
        t.put("only 429 500 502 503 504 are retryable statuses", () -> Main.retryable("GET", 429, false)
                && Main.retryable("GET", 500, false) && Main.retryable("GET", 502, false)
                && Main.retryable("GET", 504, false) && Main.retryable("DELETE", 502, true));
        t.put("success and client mistakes never retry", () -> !Main.retryable("GET", 200, false)
                && !Main.retryable("GET", 404, false) && !Main.retryable("GET", 409, false)
                && !Main.retryable("GET", 422, false) && !Main.retryable("GET", 403, false)
                && !Main.retryable("GET", 401, false) && !Main.retryable("GET", 400, false));
        t.put("method matching is case-insensitive and trimmed", () -> Main.retryable(" get ", 503, false)
                && Main.retryable("Post", 503, true));
        t.put("unknown or null methods are rejected", () -> {
            try {
                Main.retryable("FROB", 503, false);
                return false;
            } catch (IllegalArgumentException e) {
                // fall through
            }
            try {
                Main.retryable(null, 503, false);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("unknown statuses are rejected", () -> {
            try {
                Main.retryable("GET", 600, false);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
