import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("emits the standard header names", () -> {
            Map<String, String> h = Main.headers(100, 42, 1700000000L);
            return "100".equals(h.get("RateLimit-Limit")) && "42".equals(h.get("RateLimit-Remaining"))
                    && "1700000000".equals(h.get("RateLimit-Reset"));
        });
        t.put("keys are exactly the four standard headers", () -> Main.headers(1, 1, 1).keySet()
                .equals(new HashSet<>(Set.of("RateLimit-Limit", "RateLimit-Remaining", "RateLimit-Reset", "RateLimit-Policy"))));
        t.put("the policy describes a sixty second window", () -> "100;w=60".equals(Main.headers(100, 5, 1).get("RateLimit-Policy")));
        t.put("negative remaining is clamped to zero", () -> "0".equals(Main.headers(10, -3, 1).get("RateLimit-Remaining")));
        t.put("remaining above the limit is clamped to the limit", () -> "10".equals(Main.headers(10, 99, 1).get("RateLimit-Remaining")));
        t.put("a zero limit allows zero remaining", () -> "0".equals(Main.headers(0, 7, 1).get("RateLimit-Remaining")));
        t.put("large reset values are kept", () -> "1893456000".equals(Main.headers(1, 0, 1893456000L).get("RateLimit-Reset")));
        t.put("a negative limit is rejected", () -> {
            try {
                Main.headers(-1, 0, 1);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("a negative reset is rejected", () -> {
            try {
                Main.headers(1, 0, -1);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
