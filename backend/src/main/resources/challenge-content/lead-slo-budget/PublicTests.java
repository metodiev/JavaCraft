import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no failures leaves the full budget", () -> close(Main.remainingBudget(0.999, 0.0), 1.0));
        t.put("half of the allowed failures leaves half", () -> close(Main.remainingBudget(0.99, 0.005), 0.5));
        t.put("exactly spent budget is zero", () -> close(Main.remainingBudget(0.99, 0.01), 0.0));
        t.put("overspent budget is clamped to zero", () -> close(Main.remainingBudget(0.99, 0.5), 0.0));
        t.put("invalid targets are rejected", () -> rejects(1.0, 0.0) && rejects(0.0, 0.0) && rejects(Double.NaN, 0.0));
        t.put("invalid failure ratios are rejected", () -> rejects(0.99, -0.1) && rejects(0.99, 1.1)
                && rejects(0.99, Double.NaN));
        return t;
    }

    private static boolean close(double a, double b) { return Math.abs(a - b) < 1e-9; }

    private static boolean rejects(double target, double failures) {
        try { Main.remainingBudget(target, failures); return false; } catch (IllegalArgumentException e) { return true; }
    }
}
