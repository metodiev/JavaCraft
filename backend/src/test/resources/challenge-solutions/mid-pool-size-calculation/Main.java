public class Main {
    public static int poolSize(double targetUtilisation, double waitTime, double serviceTime, int cores) {
        if (targetUtilisation <= 0 || targetUtilisation > 1) {
            throw new IllegalArgumentException("targetUtilisation must be in (0, 1]");
        }
        if (waitTime < 0) {
            throw new IllegalArgumentException("waitTime must not be negative");
        }
        if (serviceTime <= 0) {
            throw new IllegalArgumentException("serviceTime must be positive");
        }
        if (cores < 1) {
            throw new IllegalArgumentException("cores must be at least 1");
        }
        double raw = cores * targetUtilisation * (1 + waitTime / serviceTime);
        int size = (int) Math.ceil(raw);
        if (size < 1) {
            size = 1;
        }
        if (size > 200) {
            size = 200;
        }
        return size;
    }
}
