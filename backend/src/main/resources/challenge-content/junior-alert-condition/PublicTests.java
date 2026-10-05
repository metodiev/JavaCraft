import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("builds an error-ratio condition",
                () -> Main.condition("http.server.error.ratio", 0.05, "5m")
                        .equals("http.server.error.ratio > 0.05 for 5m"));
        t.put("renders whole-number thresholds via Double.toString",
                () -> Main.condition("checkout.latency.p99", 250, "10m")
                        .equals("checkout.latency.p99 > 250.0 for 10m"));
        t.put("trims the metric and window",
                () -> Main.condition("  api.availability ", 0.99, "  30m ")
                        .equals("api.availability > 0.99 for 30m"));
        t.put("rejects cpu cause metrics", () -> rejects("node.cpu.usage", 90, "5m"));
        t.put("rejects memory and heap cause metrics", () -> rejects("jvm.heap.used", 0.8, "10m"));
        t.put("cause detection ignores case", () -> rejects("JVM.Thread.Count", 500, "5m"));
        t.put("blank inputs are rejected",
                () -> rejects(" ", 1, "5m") && rejects("api.latency", 1, " ") && rejects(null, 1, "5m"));
        t.put("a non-finite threshold is rejected",
                () -> rejects("api.latency", Double.NaN, "5m")
                        && rejects("api.latency", Double.POSITIVE_INFINITY, "5m"));
        return t;
    }

    private static boolean rejects(String metric, double threshold, String window) {
        try {
            Main.condition(metric, threshold, window);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
