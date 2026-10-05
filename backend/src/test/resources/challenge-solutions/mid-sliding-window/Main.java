public class Main {
    public static int maxWindowSum(int[] values, int window) {
        if (values == null || window <= 0 || window > values.length) {
            return 0;
        }
        int sum = 0;
        for (int i = 0; i < window; i++) {
            sum += values[i];
        }
        int best = sum;
        for (int i = window; i < values.length; i++) {
            sum += values[i] - values[i - window];
            best = Math.max(best, sum);
        }
        return best;
    }
}
