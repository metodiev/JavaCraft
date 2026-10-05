import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("user-facing work targets latency", () -> Main.target(true, false, 5000).equals("LATENCY"));
        t.put("a user-facing batch still targets latency", () -> Main.target(true, true, 10000).equals("LATENCY"));
        t.put("a batch with a loose tail targets throughput",
                () -> Main.target(false, true, 5000).equals("THROUGHPUT"));
        t.put("the one second cutoff is exclusive", () -> Main.target(false, true, 1000).equals("LATENCY"));
        t.put("just above the cutoff the batch targets throughput",
                () -> Main.target(false, true, 1000.001).equals("THROUGHPUT"));
        t.put("a tight budget keeps a batch on latency", () -> Main.target(false, true, 250).equals("LATENCY"));
        t.put("work that is neither user-facing nor a batch targets latency",
                () -> Main.target(false, false, 5000).equals("LATENCY"));
        t.put("invalid budgets are rejected",
                () -> rejects(0) && rejects(-100) && rejects(Double.NaN) && rejects(Double.POSITIVE_INFINITY));
        return t;
    }

    private static boolean rejects(double budget) {
        try {
            Main.target(false, true, budget);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
