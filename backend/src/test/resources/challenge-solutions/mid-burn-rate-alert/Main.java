public class Main {
    public static boolean alert(double errorBudgetConsumedFraction, double timeWindowFraction, double factor) {
        if (!Double.isFinite(errorBudgetConsumedFraction) || errorBudgetConsumedFraction < 0) {
            throw new IllegalArgumentException("consumed fraction must be finite and not negative");
        }
        if (!Double.isFinite(timeWindowFraction) || timeWindowFraction <= 0 || timeWindowFraction > 1) {
            throw new IllegalArgumentException("window fraction must be in (0, 1]");
        }
        if (!Double.isFinite(factor) || factor <= 0) {
            throw new IllegalArgumentException("factor must be positive and finite");
        }
        return errorBudgetConsumedFraction / timeWindowFraction > factor;
    }
}
