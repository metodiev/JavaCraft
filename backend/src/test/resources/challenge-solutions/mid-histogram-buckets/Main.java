import java.util.ArrayList;
import java.util.List;

public class Main {
    private static final double[] MULTIPLIERS =
            {0.5, 0.75, 0.9, 0.95, 1.0, 1.05, 1.1, 1.25, 1.5, 2.0, 4.0};

    public static List<Double> buckets(double sloMillis) {
        if (!Double.isFinite(sloMillis) || sloMillis <= 0) {
            throw new IllegalArgumentException("sloMillis must be positive and finite");
        }
        List<Double> buckets = new ArrayList<>();
        for (double multiplier : MULTIPLIERS) {
            buckets.add(sloMillis * multiplier);
        }
        return buckets;
    }
}
