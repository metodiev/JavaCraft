import java.util.concurrent.CompletableFuture;

public class Main {
    public static String valueOr(CompletableFuture<String> future, String fallback) {
        // TODO: fall back for a null, failed, incomplete, or null-valued future
        return future.getNow(fallback);
    }
}
