import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an allowed origin is echoed back with a vary header", () -> {
            List<String> h = Main.headers("https://app.example.com", "GET",
                    Set.of("https://app.example.com", "https://admin.example.com"), false);
            return h.contains("Access-Control-Allow-Origin: https://app.example.com")
                    && h.contains("Access-Control-Allow-Methods: GET")
                    && h.contains("Vary: Origin");
        });
        t.put("an origin outside the allow list is rejected", () -> Main.headers("https://evil.example.com", "GET",
                Set.of("https://app.example.com"), false).isEmpty());
        t.put("a wildcard allow list returns a star without vary", () -> {
            List<String> h = Main.headers("https://any.example.com", "POST", Set.of("*"), false);
            return h.contains("Access-Control-Allow-Origin: *") && h.contains("Access-Control-Allow-Methods: POST")
                    && !h.contains("Vary: Origin");
        });
        t.put("credentials require a concrete origin", () -> {
            List<String> h = Main.headers("https://app.example.com", "GET", Set.of("https://app.example.com"), true);
            return h.contains("Access-Control-Allow-Credentials: true");
        });
        t.put("a wildcard with credentials is refused", () -> Main.headers("https://app.example.com", "GET",
                Set.of("*"), true).isEmpty());
        t.put("the requested method is echoed", () -> Main.headers("https://a.test", "DELETE", Set.of("https://a.test"), false)
                .contains("Access-Control-Allow-Methods: DELETE"));
        t.put("the allow list match is exact", () -> Main.headers("https://app.example.com.evil.test", "GET",
                Set.of("https://app.example.com"), false).isEmpty());
        t.put("an empty allow list rejects every origin", () -> Main.headers("https://a.test", "GET", Set.of(), false).isEmpty());
        t.put("null arguments are rejected", () -> {
            try {
                Main.headers(null, "GET", Set.of("https://a.test"), false);
                return false;
            } catch (IllegalArgumentException e) {
                // fall through to the second check
            }
            try {
                Main.headers("https://a.test", "GET", null, false);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
