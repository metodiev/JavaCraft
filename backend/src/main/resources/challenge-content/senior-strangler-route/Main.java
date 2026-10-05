public class Main {
    public static String target(int rolloutPercent, String userId, boolean legacyHealthy) {
        // TODO: route by user bucket and fall over when legacy is unhealthy
        return "LEGACY";
    }
}
