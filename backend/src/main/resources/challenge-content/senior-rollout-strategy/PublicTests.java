import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a plain release rolls out gradually", () -> "ROLLING".equals(Main.strategy(false, false, 3)));
        t.put("a breaking api change uses blue-green", () ->
                "BLUE_GREEN".equals(Main.strategy(false, true, 3)));
        t.put("a schema change without a breaking api uses canary", () ->
                "CANARY".equals(Main.strategy(true, false, 3)));
        t.put("a breaking api change beats a schema change", () ->
                "BLUE_GREEN".equals(Main.strategy(true, true, 3)));
        t.put("a single replica cannot spare a canary and uses blue-green", () ->
                "BLUE_GREEN".equals(Main.strategy(true, false, 1)));
        t.put("two replicas still cannot canary safely", () ->
                "BLUE_GREEN".equals(Main.strategy(true, false, 2)));
        t.put("a schema change with three replicas canaries", () ->
                "CANARY".equals(Main.strategy(true, false, 3))
                && "CANARY".equals(Main.strategy(true, false, 8)));
        t.put("a non-positive replica count is rejected", () -> {
            try { Main.strategy(false, false, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
