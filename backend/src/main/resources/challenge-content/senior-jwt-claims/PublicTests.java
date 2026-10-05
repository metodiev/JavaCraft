import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a valid token reports nothing", () -> Main.violations(
                Map.of("sub", "user-1", "exp", 2000L, "aud", "orders"), 1000L, "orders").isEmpty());
        t.put("a missing subject is reported", () -> Main.violations(
                Map.of("exp", 2000L, "aud", "orders"), 1000L, "orders").equals(List.of("missing sub")));
        t.put("a missing expiry is reported", () -> Main.violations(
                Map.of("sub", "user-1", "aud", "orders"), 1000L, "orders").equals(List.of("missing exp")));
        t.put("an expiry at or before now is expired", () -> Main.violations(
                Map.of("sub", "user-1", "exp", 1000L, "aud", "orders"), 1000L, "orders").equals(List.of("expired"))
                && Main.violations(Map.of("sub", "user-1", "exp", 999L, "aud", "orders"), 1000L, "orders")
                        .equals(List.of("expired")));
        t.put("an expiry in the future is fine", () -> Main.violations(
                Map.of("sub", "user-1", "exp", 1001L, "aud", "orders"), 1000L, "orders").isEmpty());
        t.put("a wrong audience is reported", () -> Main.violations(
                Map.of("sub", "user-1", "exp", 2000L, "aud", "billing"), 1000L, "orders")
                .equals(List.of("audience mismatch")));
        t.put("a null or empty expected audience skips the audience check", () -> Main.violations(
                Map.of("sub", "user-1", "exp", 2000L, "aud", "anything"), 1000L, "").isEmpty()
                && Main.violations(Map.of("sub", "user-1", "exp", 2000L, "aud", "anything"), 1000L, null).isEmpty()
                && !Main.violations(Map.of("sub", "user-1", "exp", 2000L, "aud", "anything"), 1000L, "")
                        .contains("audience mismatch"));
        t.put("missing claims are reported in sub, exp, aud order before content problems", () -> Main.violations(
                Map.of(), 1000L, "orders").equals(List.of("missing sub", "missing exp", "missing aud")));
        t.put("a null claim map reports every claim as missing", () -> Main.violations(null, 1000L, "orders")
                .equals(List.of("missing sub", "missing exp", "missing aud")));
        return t;
    }
}
