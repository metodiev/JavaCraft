public class Main {
    public static int poolSize(int databaseCores, double serviceTimeMillis, double waitBudgetMillis) {
        if (databaseCores < 1) {
            throw new IllegalArgumentException("databaseCores must be at least 1");
        }
        if (!Double.isFinite(serviceTimeMillis) || serviceTimeMillis <= 0) {
            throw new IllegalArgumentException("serviceTimeMillis must be positive and finite");
        }
        if (!Double.isFinite(waitBudgetMillis) || waitBudgetMillis < 0) {
            throw new IllegalArgumentException("waitBudgetMillis must be finite and not negative");
        }
        double target = Math.ceil(databaseCores * (1 + waitBudgetMillis / serviceTimeMillis));
        long cap = 8L * databaseCores;
        long bounded = Math.min((long) target, cap);
        return (int) Math.max(2, bounded);
    }
}
