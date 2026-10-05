public class Main {
    public static int nextValue(int current, int limit) {
        if (current < 0) {
            throw new IllegalArgumentException("current must not be negative");
        }
        if (limit < 0) {
            throw new IllegalArgumentException("limit must not be negative");
        }
        if (current >= limit) {
            return 0;
        }
        return current + 1;
    }
}
