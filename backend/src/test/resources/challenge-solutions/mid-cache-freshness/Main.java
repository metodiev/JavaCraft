public class Main {
    public static boolean usable(long ageSeconds, long maxAgeSeconds, boolean mustRevalidate) {
        if (ageSeconds < 0 || maxAgeSeconds < 0) {
            throw new IllegalArgumentException("ages must not be negative");
        }
        return !mustRevalidate && ageSeconds < maxAgeSeconds;
    }
}
