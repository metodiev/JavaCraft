import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("buckets sit at the documented multiples of the slo",
                () -> near(Main.buckets(500), 250, 375, 450, 475, 500, 525, 550, 625, 750, 1000, 2000));
        t.put("the slo itself is a boundary", () -> contains(Main.buckets(200), 200));
        t.put("buckets are strictly ascending", () -> ascending(Main.buckets(500)) && ascending(Main.buckets(1)));
        t.put("boundaries resolve the slo region finely",
                () -> countBetween(Main.buckets(1000), 900, 1100) >= 5);
        t.put("the set is bounded with a coarse tail", () -> {
            List<Double> b = Main.buckets(1000);
            return b.size() == 11 && near(b.get(0), 500) && near(b.get(10), 4000);
        });
        t.put("a tiny slo still yields positive buckets", () -> Main.buckets(1).get(0) > 0);
        t.put("invalid slo values are rejected",
                () -> rejects(0) && rejects(-5) && rejects(Double.NaN) && rejects(Double.POSITIVE_INFINITY));
        return t;
    }

    private static boolean near(List<Double> got, double... expected) {
        if (got.size() != expected.length) {
            return false;
        }
        for (int i = 0; i < expected.length; i++) {
            if (Math.abs(got.get(i) - expected[i]) >= 0.0001) {
                return false;
            }
        }
        return true;
    }

    private static boolean near(double a, double b) {
        return Math.abs(a - b) < 0.0001;
    }

    private static boolean contains(List<Double> values, double target) {
        for (double v : values) {
            if (near(v, target)) {
                return true;
            }
        }
        return false;
    }

    private static boolean ascending(List<Double> values) {
        for (int i = 1; i < values.size(); i++) {
            if (!(values.get(i) > values.get(i - 1))) {
                return false;
            }
        }
        return true;
    }

    private static int countBetween(List<Double> values, double lo, double hi) {
        int count = 0;
        for (double v : values) {
            if (v >= lo - 0.0001 && v <= hi + 0.0001) {
                count++;
            }
        }
        return count;
    }

    private static boolean rejects(double slo) {
        try {
            Main.buckets(slo);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
