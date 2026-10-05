import java.util.function.IntUnaryOperator;

public class Main {
    public static int casAttempts(int initial, int target, IntUnaryOperator observed) {
        if (observed == null) {
            throw new IllegalArgumentException("observed operator is required");
        }
        if (initial == target) {
            return 0;
        }
        int value = initial;
        for (int attempts = 1; attempts <= 1000; attempts++) {
            value = observed.applyAsInt(value);
            if (value == target) {
                return attempts;
            }
        }
        return 1000;
    }
}
