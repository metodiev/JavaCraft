public class Main {
    private static final String RETRY = "RETRY";
    private static final String SURFACE = "SURFACE";

    public static String action(String exceptionType, int attempts, int maxAttempts, boolean replaysSafe) {
        if (!replaysSafe || exceptionType == null || !isConflict(exceptionType)) {
            return SURFACE;
        }
        if (attempts < 0 || attempts >= maxAttempts) {
            return SURFACE;
        }
        return RETRY;
    }

    private static boolean isConflict(String exceptionType) {
        return exceptionType.contains("OptimisticLockingFailure") || exceptionType.contains("StaleObjectState");
    }
}
