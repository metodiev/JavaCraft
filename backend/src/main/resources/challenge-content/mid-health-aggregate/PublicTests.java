import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a single up indicator aggregates to up", () -> "UP".equals(Main.aggregate(List.of("UP"))));
        t.put("down beats out of service", () -> "DOWN".equals(Main.aggregate(List.of("OUT_OF_SERVICE", "DOWN"))));
        t.put("out of service beats up", () -> "OUT_OF_SERVICE".equals(Main.aggregate(List.of("UP", "OUT_OF_SERVICE"))));
        t.put("up beats unknown", () -> "UP".equals(Main.aggregate(List.of("UNKNOWN", "UP"))));
        t.put("out of service beats unknown", () -> "OUT_OF_SERVICE".equals(Main.aggregate(List.of("UNKNOWN", "OUT_OF_SERVICE"))));
        t.put("no indicators aggregate to unknown", () -> "UNKNOWN".equals(Main.aggregate(List.of())));
        t.put("a null indicator list aggregates to unknown", () -> "UNKNOWN".equals(Main.aggregate(null)));
        t.put("an unrecognized status is ignored when a known one is present", () ->
                "UP".equals(Main.aggregate(List.of("UP", "BROKEN"))));
        return t;
    }
}
