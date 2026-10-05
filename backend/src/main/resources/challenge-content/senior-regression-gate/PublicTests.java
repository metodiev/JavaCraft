import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an improvement passes and reports the drop",
                () -> Main.verdict(100, 90, 0.05).equals("PASS -10.0%"));
        t.put("an unchanged candidate passes",
                () -> Main.verdict(100, 100, 0.05).equals("PASS +0.0%"));
        t.put("a change within tolerance passes",
                () -> Main.verdict(100, 105, 0.05).equals("PASS +5.0%"));
        t.put("a change beyond tolerance warns",
                () -> Main.verdict(100, 107, 0.05).equals("WARN +7.0%"));
        t.put("exactly twice the tolerance still warns",
                () -> Main.verdict(100, 110, 0.05).equals("WARN +10.0%"));
        t.put("beyond twice the tolerance fails",
                () -> Main.verdict(100, 112.5, 0.05).equals("FAIL +12.5%"));
        t.put("tolerance scales with the baseline",
                () -> Main.verdict(200, 220, 0.2).equals("PASS +10.0%"));
        t.put("invalid inputs are rejected",
                () -> rejects(0, 100, 0.05) && rejects(100, -1, 0.05) && rejects(100, 100, -0.01)
                        && rejects(100, 100, Double.NaN) && rejects(100, Double.NaN, 0.05));
        return t;
    }

    private static boolean rejects(double baseline, double candidate, double tolerance) {
        try {
            Main.verdict(baseline, candidate, tolerance);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
