import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a transient failure below the cap is retried", () ->
                "RETRY".equals(Main.route(1, 3, false)));
        t.put("a transient failure at or beyond the cap is dead-lettered", () ->
                "DLQ".equals(Main.route(3, 3, false)) && "DLQ".equals(Main.route(4, 3, false)));
        t.put("a permanent failure is dead-lettered immediately", () ->
                "DLQ".equals(Main.route(1, 3, true)));
        t.put("a permanent failure fails closed before any attempt", () ->
                "DLQ".equals(Main.route(0, 3, true)));
        t.put("invalid bookkeeping is checked before permanence", () ->
                "DISCARD".equals(Main.route(-1, 3, false)) && "DISCARD".equals(Main.route(-1, 3, true)));
        t.put("a disabled retry budget discards the message", () ->
                "DISCARD".equals(Main.route(2, 0, false)) && "DISCARD".equals(Main.route(0, -5, true)));
        t.put("the first attempt is allowed when the cap is one", () ->
                "RETRY".equals(Main.route(0, 1, false)));
        return t;
    }
}
