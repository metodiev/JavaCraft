public class Main {
    public static long delayMillis(int attempt, long initial, double multiplier, long max) {
        if (initial <= 0) {
            return 0L;
        }
        int steps = Math.max(attempt, 1) - 1;
        double delay = initial;
        for (int i = 0; i < steps && delay < max; i++) {
            delay *= multiplier;
        }
        long capped = delay >= max ? max : (long) delay;
        return Math.max(0L, Math.min(capped, max));
    }
}
