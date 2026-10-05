public class Main {
    public static String target(boolean userFacing, boolean batch, double p99BudgetMillis) {
        if (!Double.isFinite(p99BudgetMillis) || p99BudgetMillis <= 0) {
            throw new IllegalArgumentException("p99BudgetMillis must be positive and finite");
        }
        if (!userFacing && batch && p99BudgetMillis > 1000) {
            return "THROUGHPUT";
        }
        return "LATENCY";
    }
}
