import java.util.*;

public class Main {
    private static final Set<String> SAFE = Set.of("GET", "HEAD", "PUT", "OPTIONS", "TRACE");
    private static final Set<String> KNOWN = Set.of("GET", "HEAD", "PUT", "POST", "PATCH", "DELETE", "OPTIONS", "TRACE");
    private static final Set<Integer> RETRYABLE_STATUSES = Set.of(429, 500, 502, 503, 504);

    public static boolean retryable(String method, int status, boolean idempotencyKeyPresent) {
        if (method == null) {
            throw new IllegalArgumentException("method is required");
        }
        String normalised = method.trim().toUpperCase(Locale.ROOT);
        if (!KNOWN.contains(normalised)) {
            throw new IllegalArgumentException("unknown method: " + method);
        }
        if (status < 100 || status > 599) {
            throw new IllegalArgumentException("status out of range: " + status);
        }
        return RETRYABLE_STATUSES.contains(status) && (SAFE.contains(normalised) || idempotencyKeyPresent);
    }
}
