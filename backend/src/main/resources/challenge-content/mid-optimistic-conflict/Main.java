public class Main {
    public static String action(String exceptionType, int attempts, int maxAttempts, boolean replaysSafe) {
        // TODO: retry only safe and replayable optimistic-lock conflicts that
        // still have an attempt left; otherwise surface the error.
        return "SURFACE";
    }
}
