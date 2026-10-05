import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("valid token has no violations", () -> Main.violations(header("HS256"), claims("alice", 1060L), 1000L).isEmpty());
        t.put("alg none is rejected", () -> Main.violations(header("none"), claims("alice", 1060L), 1000L)
                .equals(List.of("alg none is not allowed")));
        t.put("missing alg is rejected", () -> Main.violations(Map.of(), claims("alice", 1060L), 1000L)
                .equals(List.of("alg none is not allowed")));
        t.put("expiry boundary is expired", () -> Main.violations(header("RS256"), claims("alice", 1000L), 1000L)
                .equals(List.of("token is expired")));
        t.put("missing or non numeric exp is reported", () -> Main.violations(header("RS256"), claims("alice", null), 1000L)
                .equals(List.of("exp is required"))
                && Main.violations(header("RS256"), Map.of("sub", "alice", "exp", "1060"), 1000L)
                .equals(List.of("exp is required")));
        t.put("missing subject is reported", () -> Main.violations(header("RS256"), claims(null, 1060L), 1000L)
                .equals(List.of("sub is required")));
        t.put("violations are reported in a fixed order", () -> Main.violations(header("none"), claims(null, 900L), 1000L)
                .equals(List.of("alg none is not allowed", "token is expired", "sub is required")));
        t.put("null maps report every violation", () -> Main.violations(null, null, 1000L)
                .equals(List.of("alg none is not allowed", "exp is required", "sub is required")));
        return t;
    }

    private static Map<String, Object> header(String alg) {
        Map<String, Object> h = new LinkedHashMap<>();
        h.put("alg", alg);
        return h;
    }

    private static Map<String, Object> claims(String sub, Long exp) {
        Map<String, Object> c = new LinkedHashMap<>();
        if (sub != null) {
            c.put("sub", sub);
        }
        if (exp != null) {
            c.put("exp", exp);
        }
        return c;
    }
}
