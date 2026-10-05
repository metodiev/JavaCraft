import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("low volume records every trace", () -> Main.strategy(5, false).equals("ALWAYS_ON"));
        t.put("the low-volume cutoff includes ten per second", () -> Main.strategy(10, true).equals("ALWAYS_ON"));
        t.put("zero traffic still records everything", () -> Main.strategy(0, false).equals("ALWAYS_ON"));
        t.put("high volume with important errors uses tail sampling",
                () -> Main.strategy(10.001, true).equals("TAIL_BASED"));
        t.put("high volume without important errors uses a ratio",
                () -> Main.strategy(5000, false).equals("PROBABILISTIC"));
        t.put("low volume beats tail sampling", () -> Main.strategy(1, true).equals("ALWAYS_ON"));
        t.put("just above the cutoff without errors uses a ratio",
                () -> Main.strategy(10.5, false).equals("PROBABILISTIC"));
        t.put("invalid rates are rejected",
                () -> rejects(-1) && rejects(Double.NaN) && rejects(Double.POSITIVE_INFINITY));
        return t;
    }

    private static boolean rejects(double rate) {
        try {
            Main.strategy(rate, false);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
