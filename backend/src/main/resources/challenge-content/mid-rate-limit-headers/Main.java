import java.util.*;

public class Main {
    public static Map<String, String> headers(int limit, int remaining, long resetEpochSeconds) {
        // TODO: build the standard rate limit headers and clamp remaining
        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("RateLimit-Limit", String.valueOf(limit));
        headers.put("RateLimit-Remaining", String.valueOf(remaining));
        headers.put("RateLimit-Reset", String.valueOf(resetEpochSeconds));
        return headers;
    }
}
