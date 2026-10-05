public class Main {
    public static int exitCode(boolean success, boolean retryable) {
        if (success) {
            return 0;
        }
        return retryable ? 75 : 1;
    }
}
