import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the kill switch disables everyone", () -> !Main.enabled("user12", 100, true, Set.of("user12")));
        t.put("an allowlisted user is enabled at zero percent", () ->
                Main.enabled("user12", 0, false, Set.of("user12")));
        t.put("zero percent disables a regular user", () -> !Main.enabled("user12", 0, false, Set.of()));
        t.put("one hundred percent enables a regular user", () ->
                Main.enabled("user11", 100, false, Set.of()));
        t.put("buckets below the percentage are enabled", () -> Main.enabled("user93", 50, false, Set.of())
                && Main.enabled("user12", 1, false, Set.of()));
        t.put("buckets at or above the percentage are disabled", () -> !Main.enabled("user94", 50, false, Set.of())
                && !Main.enabled("user11", 99, false, Set.of()));
        t.put("a null user is disabled", () -> !Main.enabled(null, 100, false, Set.of()));
        t.put("a null allowlist is ignored", () -> !Main.enabled("user94", 49, false, null)
                && Main.enabled("user12", 1, false, null));
        t.put("a user absent from the allowlist still needs the rollout", () ->
                Main.enabled("user12", 60, false, Set.of("user94"))
                        && !Main.enabled("user94", 49, false, Set.of("user12")));
        return t;
    }
}
