public class Main {
    public static String action(long cachedAgeMillis, long ttlMillis, boolean registryAvailable) {
        // TODO: USE_CACHE while fresh, REFRESH when stale and the registry is reachable, FAIL_FAST otherwise
        return "USE_CACHE";
    }
}
