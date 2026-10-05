public class Main {
    private static final int MIN_BATCH = 1;
    private static final int MAX_BATCH = 1000;

    public static int batchSize(int rowWidthBytes, int memoryBudgetKb) {
        if (rowWidthBytes <= 0 || memoryBudgetKb <= 0) {
            return MIN_BATCH;
        }
        long budgetBytes = (long) memoryBudgetKb * 1024L;
        long estimate = budgetBytes / rowWidthBytes;
        if (estimate > MAX_BATCH) {
            return MAX_BATCH;
        }
        return (int) Math.max(MIN_BATCH, estimate);
    }
}
