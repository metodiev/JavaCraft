public class Main {
    public static String action(long cachedAgeMillis, long ttlMillis, boolean registryAvailable) {
        if (cachedAgeMillis < 0) {
            throw new IllegalArgumentException("cachedAgeMillis must not be negative");
        }
        if (ttlMillis < 0) {
            throw new IllegalArgumentException("ttlMillis must not be negative");
        }
        if (cachedAgeMillis <= ttlMillis) {
            return "USE_CACHE";
        }
        return registryAvailable ? "REFRESH" : "FAIL_FAST";
    }
}
