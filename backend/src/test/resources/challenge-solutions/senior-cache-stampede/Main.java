import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Supplier;

public class Main {
    public static CompletableFuture<String> refresh(ConcurrentHashMap<String, CompletableFuture<String>> inFlight,
                                                    String key, Supplier<CompletableFuture<String>> loader) {
        CompletableFuture<String> future = inFlight.computeIfAbsent(key, k -> loader.get());
        future.whenComplete((value, error) -> inFlight.remove(key, future));
        return future;
    }
}
