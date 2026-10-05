public class Main {
    public static String route(int attempts, int maxAttempts, boolean permanentFailure) {
        if (attempts < 0 || maxAttempts < 1) {
            return "DISCARD";
        }
        if (permanentFailure) {
            return "DLQ";
        }
        return attempts < maxAttempts ? "RETRY" : "DLQ";
    }
}
