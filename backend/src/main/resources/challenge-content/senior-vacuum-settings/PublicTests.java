import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a quiet table keeps the stock settings", () -> {
            Map<String, Double> s = Main.autovacuumSettings(1_000_000, 0.0);
            return close(s.get("vacuum_scale_factor"), 0.2) && close(s.get("vacuum_threshold"), 50)
                    && close(s.get("vacuum_trigger_rows"), 200_050);
        });
        t.put("half churn halves the scale factor", () -> {
            Map<String, Double> s = Main.autovacuumSettings(1_000_000, 0.5);
            return close(s.get("vacuum_scale_factor"), 0.1) && close(s.get("vacuum_threshold"), 35)
                    && close(s.get("vacuum_trigger_rows"), 100_035);
        });
        t.put("full churn hits the aggressive floor", () -> {
            Map<String, Double> s = Main.autovacuumSettings(1_000_000, 1.0);
            return close(s.get("vacuum_scale_factor"), 0.01) && close(s.get("vacuum_threshold"), 20)
                    && close(s.get("vacuum_trigger_rows"), 10_020);
        });
        t.put("trigger rows grow with table size", () -> {
            Map<String, Double> empty = Main.autovacuumSettings(0, 0.0);
            Map<String, Double> small = Main.autovacuumSettings(1_000, 0.0);
            return close(empty.get("vacuum_trigger_rows"), 50) && close(small.get("vacuum_trigger_rows"), 250);
        });
        t.put("a hot table vacuums sooner than the default", () -> Main.autovacuumSettings(1_000_000, 0.9)
                .get("vacuum_trigger_rows") < Main.autovacuumSettings(1_000_000, 0.0).get("vacuum_trigger_rows"));
        t.put("the analyze factor scales and keeps a floor", () -> {
            Map<String, Double> hot = Main.autovacuumSettings(500, 0.9);
            Map<String, Double> hottest = Main.autovacuumSettings(500, 1.0);
            return close(hot.get("analyze_scale_factor"), 0.01) && close(hottest.get("analyze_scale_factor"), 0.005);
        });
        t.put("update ratios outside zero to one are rejected", () -> rejects(100, -0.01) && rejects(100, 1.01)
                && rejects(100, Double.NaN));
        t.put("a negative table size is rejected", () -> rejects(-1, 0.5));
        return t;
    }

    private static boolean close(double actual, double expected) { return Math.abs(actual - expected) < 1e-9; }

    private static boolean rejects(long tableRows, double updateRatio) {
        try { Main.autovacuumSettings(tableRows, updateRatio); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
