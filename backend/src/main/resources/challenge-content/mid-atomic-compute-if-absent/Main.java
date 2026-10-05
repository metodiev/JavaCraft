import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Supplier;

public class Main {
    public static String computeOnce(ConcurrentHashMap<String, String> cache, String key, Supplier<String> loader) {
        // TODO: replace the check-then-put with one atomic operation
        if (cache.get(key) == null) {
            cache.put(key, loader.get());
        }
        return cache.get(key);
    }
}
