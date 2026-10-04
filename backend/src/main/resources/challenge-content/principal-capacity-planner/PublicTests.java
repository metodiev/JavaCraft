import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("exact fit", () -> Main.requiredWorkers(100, 0.1, 0.5) == 20);
        t.put("fractional need rounds up", () -> Main.requiredWorkers(10, 0.25, 0.8) == 4);
        t.put("tiny load still needs one worker", () -> Main.requiredWorkers(0.001, 0.001, 0.9) == 1);
        t.put("zero load needs no workers", () -> Main.requiredWorkers(0, 0.1, 0.5) == 0);
        t.put("utilization must be in (0,1)", () -> rejects(10, 1, 0) && rejects(10, 1, 1.5) && rejects(10, 1, Double.NaN));
        t.put("negative or non-finite load is rejected", () -> rejects(-1, 1, 0.5) && rejects(Double.POSITIVE_INFINITY, 1, 0.5)
                && rejects(1, Double.NaN, 0.5));
        t.put("results beyond int range are rejected", () -> rejects(1e12, 1e12, 0.5));
        return t;
    }

    private static boolean rejects(double rps, double secs, double util) {
        try { Main.requiredWorkers(rps, secs, util); return false; } catch (IllegalArgumentException e) { return true; }
    }
}
