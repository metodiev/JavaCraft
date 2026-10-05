import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("fresh cache entries are used", () -> Main.action(500, 1000, true).equals("USE_CACHE"));
        t.put("an entry exactly at the ttl is still usable", () ->
                Main.action(1000, 1000, false).equals("USE_CACHE"));
        t.put("staleness is measured strictly past the ttl", () ->
                Main.action(1001, 1000, true).equals("REFRESH"));
        t.put("a stale entry refreshes from a reachable registry", () ->
                Main.action(50000, 1000, true).equals("REFRESH"));
        t.put("a stale entry fails fast when the registry is down", () ->
                Main.action(1001, 1000, false).equals("FAIL_FAST"));
        t.put("fresh cache is used even when the registry is down", () ->
                Main.action(0, 1000, false).equals("USE_CACHE"));
        t.put("negative ages or ttls are rejected", () -> {
            try { Main.action(-1, 1000, true); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.action(1, -1, true); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
