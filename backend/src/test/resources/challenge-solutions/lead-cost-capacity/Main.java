import java.util.ArrayList;
import java.util.List;

public class Main {
    private static final double SCALE_OUT_THRESHOLD = 0.80;
    private static final double CONSOLIDATE_THRESHOLD = 0.30;
    private static final double LATENCY_TARGET_MILLIS = 300.0;

    public static List<String> recommendations(double utilisation, double p99Millis, double budgetUtilisation) {
        requireValid(utilisation, "utilisation");
        requireValid(p99Millis, "p99Millis");
        requireValid(budgetUtilisation, "budgetUtilisation");
        List<String> actions = new ArrayList<>();
        if (utilisation > SCALE_OUT_THRESHOLD) {
            actions.add("scale-out");
        }
        if (utilisation < CONSOLIDATE_THRESHOLD) {
            actions.add("consolidate");
        }
        if (p99Millis > LATENCY_TARGET_MILLIS) {
            actions.add("optimise-latency");
        }
        if (budgetUtilisation >= 1.0) {
            actions.add("reduce-spend");
        }
        return actions;
    }

    private static void requireValid(double value, String name) {
        if (Double.isNaN(value) || Double.isInfinite(value) || value < 0.0) {
            throw new IllegalArgumentException(name + " must be finite and non-negative");
        }
    }
}
