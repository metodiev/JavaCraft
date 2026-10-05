public class Main {
    public static int graceSeconds(int longestRequestSeconds, int drainSeconds, int terminationGraceSeconds) {
        if (longestRequestSeconds < 0 || drainSeconds < 0) {
            throw new IllegalArgumentException("durations must not be negative");
        }
        if (terminationGraceSeconds <= 0) {
            throw new IllegalArgumentException("terminationGraceSeconds must be positive");
        }
        long needed = (long) longestRequestSeconds + (long) drainSeconds;
        if (needed > Integer.MAX_VALUE) {
            throw new IllegalArgumentException("grace calculation overflows");
        }
        return (int) Math.min(needed, terminationGraceSeconds);
    }
}
