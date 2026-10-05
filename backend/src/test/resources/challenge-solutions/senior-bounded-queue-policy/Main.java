public class Main {
    public static String rejectionPolicy(int latencyBudgetMillis, boolean lossTolerant, int queueDepth) {
        if (lossTolerant || (latencyBudgetMillis < 200 && queueDepth > 200)) {
            return "shed";
        }
        if (queueDepth > 200) {
            return "evict-oldest";
        }
        return "block";
    }
}
