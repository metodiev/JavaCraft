import java.util.*;

public class Main {
    public static List<String> headers(String origin, String method, Set<String> allowedOrigins, boolean credentials) {
        if (origin == null || origin.isBlank() || method == null || allowedOrigins == null) {
            throw new IllegalArgumentException("origin, method and allow list are required");
        }
        List<String> headers = new ArrayList<>();
        boolean wildcard = allowedOrigins.contains("*");
        if (!wildcard && !allowedOrigins.contains(origin)) {
            return headers;
        }
        if (wildcard && credentials) {
            return headers;
        }
        if (credentials) {
            headers.add("Access-Control-Allow-Credentials: true");
        }
        headers.add("Access-Control-Allow-Origin: " + (wildcard ? "*" : origin));
        headers.add("Access-Control-Allow-Methods: " + method);
        if (!wildcard) {
            headers.add("Vary: Origin");
        }
        return headers;
    }
}
