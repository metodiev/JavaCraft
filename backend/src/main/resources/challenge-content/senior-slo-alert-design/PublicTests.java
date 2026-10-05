import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a one hour tier uses the fast burn rate factor",
                () -> check(Main.alert("checkout.availability", 0.999, 5, 60),
                        "checkout.availability", 0.001, 300, 3600, 14.4,
                        "burnRate > 14.4 over 5m and 60m"));
        t.put("a six hour tier uses the medium burn rate factor",
                () -> check(Main.alert("search.latency", 0.99, 30, 360),
                        "search.latency", 0.01, 1800, 21600, 6.0,
                        "burnRate > 6.0 over 30m and 360m"));
        t.put("a multi-day tier uses the slow burn rate factor",
                () -> check(Main.alert("api.availability", 0.995, 360, 4320),
                        "api.availability", 0.005, 21600, 259200, 1.0,
                        "burnRate > 1.0 over 360m and 4320m"));
        t.put("the one hour cutoff is inclusive",
                () -> num(Main.alert("api.availability", 0.999, 5, 60).get("burnRateFactor"), 14.4));
        t.put("both a short and a long window are required",
                () -> {
                    Map<String, Object> a = Main.alert("api.availability", 0.999, 5, 60);
                    String condition = String.valueOf(a.get("condition"));
                    return condition.contains("5m") && condition.contains("60m") && condition.contains("14.4");
                });
        t.put("the error budget is one minus the target", () ->
                num(Main.alert("api.latency", 0.9, 5, 60).get("budget"), 0.1));
        t.put("invalid definitions are rejected",
                () -> rejects("api.availability", 1.0, 5, 60)
                        && rejects("api.availability", 0.999, 60, 60)
                        && rejects("api.availability", 0.999, 0, 60)
                        && rejects(" ", 0.999, 5, 60)
                        && rejects("api.availability", Double.NaN, 5, 60));
        return t;
    }

    private static boolean check(Map<String, Object> a, String sli, double budget,
                                 int fastSeconds, int slowSeconds, double factor, String condition) {
        return sli.equals(a.get("sli"))
                && num(a.get("budget"), budget)
                && num(a.get("fastWindowSeconds"), fastSeconds)
                && num(a.get("slowWindowSeconds"), slowSeconds)
                && num(a.get("burnRateFactor"), factor)
                && condition.equals(a.get("condition"));
    }

    private static boolean num(Object value, double expected) {
        return value instanceof Number n && Math.abs(n.doubleValue() - expected) < 0.0001;
    }

    private static boolean rejects(String sli, double target, int fast, int slow) {
        try {
            Main.alert(sli, target, fast, slow);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
