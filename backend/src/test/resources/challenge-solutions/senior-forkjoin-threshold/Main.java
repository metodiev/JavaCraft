public class Main {
    private static final int MIN = 1000;
    private static final int MAX = 100000;

    public static int threshold(int elements, int cores, int perElementCostMicros) {
        if (elements <= 0 || cores <= 0 || perElementCostMicros <= 0) {
            return MIN;
        }
        long chunk = (long) elements * perElementCostMicros / ((long) cores * 100);
        if (chunk < MIN) {
            return MIN;
        }
        if (chunk > MAX) {
            return MAX;
        }
        return (int) chunk;
    }
}
