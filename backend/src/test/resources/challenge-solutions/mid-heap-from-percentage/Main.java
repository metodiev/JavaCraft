public class Main {
    public static long maxHeapBytes(long containerBytes, int percentage) {
        if (containerBytes <= 0) {
            return 0L;
        }
        int clamped = Math.max(1, Math.min(100, percentage));
        return (containerBytes / 100) * clamped + (containerBytes % 100) * clamped / 100;
    }
}
