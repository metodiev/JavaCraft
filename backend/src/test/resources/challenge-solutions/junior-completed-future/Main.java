import java.util.concurrent.CompletableFuture;

public class Main {
    public static String valueOr(CompletableFuture<String> future, String fallback) {
        if (future == null || future.isCompletedExceptionally()) {
            return fallback;
        }
        String value = future.getNow(null);
        return value != null ? value : fallback;
    }
}
