import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a cpu bound service scales on cpu utilization", () ->
                "CPU_UTILIZATION".equals(Main.metric(true, false, false)));
        t.put("a queue consumer scales on queue depth", () ->
                "QUEUE_DEPTH".equals(Main.metric(false, true, false)));
        t.put("a latency sensitive service scales on p95 latency", () ->
                "P95_LATENCY".equals(Main.metric(false, false, true)));
        t.put("a plain service scales on requests per second", () ->
                "REQUESTS_PER_SECOND".equals(Main.metric(false, false, false)));
        t.put("queue depth beats latency and cpu", () ->
                "QUEUE_DEPTH".equals(Main.metric(true, true, true)));
        t.put("latency beats cpu", () -> "P95_LATENCY".equals(Main.metric(true, false, true)));
        t.put("every combination returns a documented metric", () -> {
            for (int mask = 0; mask < 8; mask++) {
                String metric = Main.metric((mask & 1) != 0, (mask & 2) != 0, (mask & 4) != 0);
                if (!List.of("CPU_UTILIZATION", "QUEUE_DEPTH", "P95_LATENCY", "REQUESTS_PER_SECOND")
                        .contains(metric)) {
                    return false;
                }
            }
            return true;
        });
        return t;
    }
}
