public class Main {
    public static String route(int attempts, int maxAttempts, boolean permanentFailure) {
        // TODO: apply the documented retry and dead-letter rules
        return permanentFailure ? "DISCARD" : "RETRY";
    }
}
