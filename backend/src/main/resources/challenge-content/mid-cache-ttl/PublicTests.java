import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("slow data is capped by accepted staleness", () -> Main.ttlSeconds("slow", 300, 50) == 300);
        t.put("fast data keeps its minute when staleness allows", () -> Main.ttlSeconds("fast", 600, 20) == 60);
        t.put("static data keeps its day under a longer bound", () -> Main.ttlSeconds("static", 100000, 5) == 86400);
        t.put("a slow source raises the realtime ttl to ten times its latency",
                () -> Main.ttlSeconds("realtime", 300, 500) == 5);
        t.put("the latency floor never breaks the staleness bound",
                () -> Main.ttlSeconds("fast", 3, 1000) == 3);
        t.put("realtime data still gets a positive ttl", () -> Main.ttlSeconds("realtime", 1, 0) == 1);
        t.put("staleness zero is rejected along with unknown volatility and negative latency",
                () -> rejects("slow", 0, 10) && rejects("sometimes", 60, 10) && rejects("slow", 60, -1));
        return t;
    }

    private static boolean rejects(String volatility, int staleness, int latency) {
        try {
            Main.ttlSeconds(volatility, staleness, latency);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
