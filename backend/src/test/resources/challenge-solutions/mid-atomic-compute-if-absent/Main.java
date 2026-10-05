import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Supplier;

public class Main {
    public static String computeOnce(ConcurrentHashMap<String, String> cache, String key, Supplier<String> loader) {
        if (cache == null) {
            throw new IllegalArgumentException("cache is required");
        }
        if (key == null) {
            throw new IllegalArgumentException("key is required");
        }
        if (loader == null) {
            throw new IllegalArgumentException("loader is required");
        }
        return cache.computeIfAbsent(key, k -> loader.get());
    }
}
