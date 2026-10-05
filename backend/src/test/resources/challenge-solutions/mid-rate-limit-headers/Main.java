import java.util.*;

public class Main {
    public static Map<String, String> headers(int limit, int remaining, long resetEpochSeconds) {
        if (limit < 0) {
            throw new IllegalArgumentException("limit must not be negative");
        }
        if (resetEpochSeconds < 0) {
            throw new IllegalArgumentException("reset must not be negative");
        }
        int clamped = Math.max(0, Math.min(remaining, limit));
        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("RateLimit-Limit", Integer.toString(limit));
        headers.put("RateLimit-Remaining", Integer.toString(clamped));
        headers.put("RateLimit-Reset", Long.toString(resetEpochSeconds));
        headers.put("RateLimit-Policy", limit + ";w=60");
        return headers;
    }
}
