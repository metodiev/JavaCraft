import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a backlogged queue scales on queue backlog", () ->
                "QUEUE_BACKLOG".equals(Main.signal(true, false, false)));
        t.put("a latency sensitive service scales on request latency", () ->
                "REQUEST_LATENCY".equals(Main.signal(false, false, true)));
        t.put("a cpu bound service scales on cpu utilization", () ->
                "CPU_UTILIZATION".equals(Main.signal(false, true, false)));
        t.put("a plain service scales on concurrency", () ->
                "CONCURRENCY".equals(Main.signal(false, false, false)));
        t.put("queue backlog beats latency and cpu", () ->
                "QUEUE_BACKLOG".equals(Main.signal(true, true, true)));
        t.put("latency beats cpu", () -> "REQUEST_LATENCY".equals(Main.signal(false, true, true)));
        t.put("latency beats cpu when both are reported", () ->
                "REQUEST_LATENCY".equals(Main.signal(false, true, true))
                        && "CPU_UTILIZATION".equals(Main.signal(false, true, false)));
        t.put("every combination returns a documented signal", () -> {
            for (int mask = 0; mask < 8; mask++) {
                String signal = Main.signal((mask & 1) != 0, (mask & 2) != 0, (mask & 4) != 0);
                if (!List.of("QUEUE_BACKLOG", "REQUEST_LATENCY", "CPU_UTILIZATION", "CONCURRENCY").contains(signal)) {
                    return false;
                }
            }
            return true;
        });
        return t;
    }
}
