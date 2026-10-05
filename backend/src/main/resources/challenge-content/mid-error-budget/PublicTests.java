import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("half the budget consumed is reported", () -> {
            Map<String, Object> b = Main.budget(0.99, 1000, 5);
            return near((Double) b.get("allowedFraction"), 0.01)
                    && near((Double) b.get("consumedFraction"), 0.5)
                    && near((Double) b.get("remainingFraction"), 0.5)
                    && Boolean.FALSE.equals(b.get("exhausted"));
        });
        t.put("the budget is exhausted exactly at the limit", () -> {
            Map<String, Object> b = Main.budget(0.99, 1000, 10);
            return near((Double) b.get("consumedFraction"), 1.0)
                    && near((Double) b.get("remainingFraction"), 0.0)
                    && Boolean.TRUE.equals(b.get("exhausted"));
        });
        t.put("overspending is clamped", () -> {
            Map<String, Object> b = Main.budget(0.99, 1000, 50);
            return near((Double) b.get("consumedFraction"), 1.0)
                    && near((Double) b.get("remainingFraction"), 0.0)
                    && Boolean.TRUE.equals(b.get("exhausted"));
        });
        t.put("a clean run keeps the full budget", () -> {
            Map<String, Object> b = Main.budget(0.999, 1000, 0);
            return near((Double) b.get("allowedFraction"), 0.001)
                    && near((Double) b.get("consumedFraction"), 0.0)
                    && near((Double) b.get("remainingFraction"), 1.0)
                    && Boolean.FALSE.equals(b.get("exhausted"));
        });
        t.put("no traffic consumes nothing", () -> {
            Map<String, Object> b = Main.budget(0.9, 0, 0);
            return near((Double) b.get("consumedFraction"), 0.0)
                    && near((Double) b.get("remainingFraction"), 1.0)
                    && Boolean.FALSE.equals(b.get("exhausted"));
        });
        t.put("any failure exhausts a zero-failure budget", () -> {
            Map<String, Object> b = Main.budget(0.9999, 1000, 1);
            return near((Double) b.get("consumedFraction"), 1.0)
                    && Boolean.TRUE.equals(b.get("exhausted"));
        });
        t.put("invalid inputs are rejected", () -> {
            try { Main.budget(1.0, 10, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.budget(0.0, 10, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.budget(Double.NaN, 10, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.budget(0.9, -1, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.budget(0.9, 10, 11); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }

    private static boolean near(double actual, double expected) {
        return Math.abs(actual - expected) < 0.0001;
    }
}
