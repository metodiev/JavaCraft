import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a fresh replica takes the read", () -> Main.route(10, 1000, false).equals("REPLICA"));
        t.put("a stale replica sends the read to the primary", () -> Main.route(1500, 1000, false).equals("PRIMARY"));
        t.put("the lag limit is inclusive", () -> Main.route(1000, 1000, false).equals("REPLICA"));
        t.put("one millisecond over the limit is too stale", () -> Main.route(1001, 1000, false).equals("PRIMARY"));
        t.put("a zero lag limit forces the primary", () -> Main.route(0, 0, false).equals("PRIMARY"));
        t.put("read-your-writes bypasses the replica", () -> Main.route(10, 1000, true).equals("PRIMARY"));
        t.put("read-your-writes ignores the lag entirely", () -> Main.route(0, 1000, true).equals("PRIMARY"));
        t.put("negative lag values are rejected", () -> rejects(-1, 1000, false) && rejects(10, -1, true));
        return t;
    }

    private static boolean rejects(long lagMillis, long maxLagMillis, boolean readYourWrites) {
        try { Main.route(lagMillis, maxLagMillis, readYourWrites); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
