import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an unowned row is claimable whatever the stale lease", () ->
                Main.claim("w1", null, Long.MAX_VALUE, 0L));
        t.put("an expired lease is claimable by another worker", () ->
                Main.claim("w1", "w2", 100L, 200L));
        t.put("a lease expiring exactly at now is expired", () ->
                Main.claim("w1", "w2", 200L, 200L));
        t.put("a live lease owned by another worker is refused", () ->
                !Main.claim("w1", "w2", 300L, 200L));
        t.put("a worker may re-claim its own row while the lease is live", () ->
                Main.claim("w1", "w1", Long.MAX_VALUE, 0L));
        t.put("a worker may renew its own expired lease", () ->
                Main.claim("w1", "w1", 100L, 500L));
        t.put("a missing or blank worker cannot claim", () ->
                !Main.claim(null, null, 0L, 1L) && !Main.claim("  ", null, 0L, 1L));
        return t;
    }
}
