import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("complete event has no violations", () -> Main.violations(event("alice", "login", "account:1", "2026-01-01T00:00:00Z")).isEmpty());
        t.put("missing fields are reported in order", () -> Main.violations(Map.of("action", "login", "timestamp", "t"))
                .equals(List.of("missing actor", "missing target")));
        t.put("blank values count as missing", () -> Main.violations(event("alice", " ", "account:1", "t"))
                .equals(List.of("missing action")));
        t.put("null entry misses every required field", () -> Main.violations(null)
                .equals(List.of("missing actor", "missing action", "missing target", "missing timestamp")));
        t.put("secret material is reported last", () -> {
            Map<String, Object> e = event("alice", "login", "account:1", "t");
            e.put("password", "dummy");
            return Main.violations(e).equals(List.of("secret material must not be logged"));
        });
        t.put("credential keys are detected case insensitively", () -> {
            Map<String, Object> e = event("alice", "login", "account:1", "t");
            e.put("API_KEY", "dummy");
            return Main.violations(e).equals(List.of("secret material must not be logged"));
        });
        t.put("missing fields come before the secret finding", () -> {
            Map<String, Object> e = new LinkedHashMap<>();
            e.put("token", "dummy");
            e.put("action", "login");
            return Main.violations(e).equals(List.of(
                    "missing actor", "missing target", "missing timestamp", "secret material must not be logged"));
        });
        return t;
    }

    private static Map<String, Object> event(String actor, String action, String target, String timestamp) {
        Map<String, Object> e = new LinkedHashMap<>();
        e.put("actor", actor);
        e.put("action", action);
        e.put("target", target);
        e.put("timestamp", timestamp);
        return e;
    }
}
