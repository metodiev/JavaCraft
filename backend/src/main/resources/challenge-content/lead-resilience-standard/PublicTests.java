import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("remote dependencies require timeout, circuit breaker and bulkhead", () ->
                Main.mandatoryPatterns(true, false, false)
                        .equals(List.of("timeout", "circuit-breaker", "bulkhead")));
        t.put("writing data requires an idempotency key", () ->
                Main.mandatoryPatterns(false, true, false).equals(List.of("idempotency-key")));
        t.put("user-facing services require graceful degradation", () ->
                Main.mandatoryPatterns(false, false, true).equals(List.of("graceful-degradation")));
        t.put("all flags together keep the canonical order", () ->
                Main.mandatoryPatterns(true, true, true)
                        .equals(List.of("timeout", "circuit-breaker", "bulkhead", "idempotency-key", "graceful-degradation")));
        t.put("remote writes order idempotency after the remote patterns", () ->
                Main.mandatoryPatterns(true, true, false)
                        .equals(List.of("timeout", "circuit-breaker", "bulkhead", "idempotency-key")));
        t.put("a purely internal service has no mandatory patterns", () ->
                Main.mandatoryPatterns(false, false, false).isEmpty());
        t.put("timeout always comes before the other remote patterns", () -> {
            List<String> patterns = Main.mandatoryPatterns(true, false, true);
            return patterns.indexOf("timeout") == 0
                    && patterns.indexOf("circuit-breaker") < patterns.indexOf("graceful-degradation");
        });
        t.put("the standard never repeats a pattern", () -> {
            List<String> patterns = Main.mandatoryPatterns(true, true, true);
            return new HashSet<>(patterns).size() == patterns.size();
        });
        return t;
    }
}
