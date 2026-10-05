import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("keeps all errors plus half the baseline", () -> Main.sampleCount(1000, 100, 1.0, 0.5) == 550);
        t.put("samples the errors when the rate says so", () -> Main.sampleCount(200, 80, 0.5, 1.0) == 160);
        t.put("a partial baseline sample rounds up", () -> Main.sampleCount(3, 0, 1.0, 0.5) == 2);
        t.put("a zero baseline rate keeps only errors", () -> Main.sampleCount(100, 10, 1.0, 0.0) == 10);
        t.put("a zero error rate keeps only the baseline", () -> Main.sampleCount(100, 40, 0.0, 0.25) == 15);
        t.put("the result never exceeds the trace count",
                () -> Main.sampleCount(10, 10, 1.0, 1.0) == 10 && Main.sampleCount(5, 0, 1.0, 1.0) == 5);
        t.put("no traces means nothing kept", () -> Main.sampleCount(0, 0, 1.0, 0.5) == 0);
        t.put("invalid counts and rates are rejected",
                () -> rejects(10, 11, 1.0, 0.5) && rejects(-1, 0, 1.0, 0.5)
                        && rejects(10, 0, 1.5, 0.5) && rejects(10, 0, 1.0, Double.NaN));
        return t;
    }

    private static boolean rejects(int traces, int errors, double errorRate, double baselineRate) {
        try {
            Main.sampleCount(traces, errors, errorRate, baselineRate);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
