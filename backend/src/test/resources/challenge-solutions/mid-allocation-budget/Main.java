public class Main {
    public static boolean withinBudget(long allocatedBytes, long budgetBytes, double tolerance) {
        if (allocatedBytes < 0 || budgetBytes < 0 || tolerance < 0 || Double.isNaN(tolerance)) {
            return false;
        }
        double limit = budgetBytes + budgetBytes * tolerance;
        return allocatedBytes <= limit;
    }
}
