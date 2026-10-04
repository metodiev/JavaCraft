import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Supplier;

public class Main {
    public static CompletableFuture<String> refresh(ConcurrentHashMap<String, CompletableFuture<String>> inFlight,
                                                    String key, Supplier<CompletableFuture<String>> loader) {
        // TODO: share one in-flight load per key and clean up when it finishes
        return loader.get();
    }
}
