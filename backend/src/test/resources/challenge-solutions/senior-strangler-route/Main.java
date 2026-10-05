public class Main {
    public static String target(int rolloutPercent, String userId, boolean legacyHealthy) {
        if (rolloutPercent < 0 || rolloutPercent > 100) {
            throw new IllegalArgumentException("rolloutPercent must be 0..100");
        }
        if (userId == null || userId.isBlank()) {
            throw new IllegalArgumentException("userId is required");
        }
        int bucket = Math.floorMod(userId.hashCode(), 100);
        if (bucket < rolloutPercent) {
            return "NEW";
        }
        return legacyHealthy ? "LEGACY" : "NEW";
    }
}
