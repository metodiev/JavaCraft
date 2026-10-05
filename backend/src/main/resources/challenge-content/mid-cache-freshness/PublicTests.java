import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a fresh entry is usable", () -> Main.usable(10, 60, false) && Main.usable(0, 1, false));
        t.put("one second before expiry is still usable", () -> Main.usable(59, 60, false));
        t.put("an entry at max age is stale", () -> !Main.usable(60, 60, false));
        t.put("an entry past max age is stale", () -> !Main.usable(61, 60, false));
        t.put("a zero max age never serves from cache", () -> !Main.usable(0, 0, false));
        t.put("must-revalidate blocks even a fresh entry", () -> !Main.usable(0, 3600, true) && !Main.usable(1, 60, true));
        t.put("huge ages do not overflow", () -> Main.usable(Long.MAX_VALUE - 1, Long.MAX_VALUE, false));
        t.put("negative inputs are rejected", () -> {
            try {
                Main.usable(-1, 60, false);
                return false;
            } catch (IllegalArgumentException e) {
                // fall through to the second check
            }
            try {
                Main.usable(1, -60, false);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
