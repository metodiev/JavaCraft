import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("returns a stored value", () -> {
            Main.LruCache<Integer, String> cache = new Main.LruCache<>(2);
            cache.put(1, "one");
            return "one".equals(cache.get(1));
        });
        t.put("missing keys return null", () -> {
            Main.LruCache<Integer, String> cache = new Main.LruCache<>(2);
            cache.put(1, "one");
            return cache.get(99) == null;
        });
        t.put("evicts the least recently used entry", () -> {
            Main.LruCache<Integer, String> cache = new Main.LruCache<>(2);
            cache.put(1, "one");
            cache.put(2, "two");
            cache.put(3, "three");
            return cache.get(1) == null && "two".equals(cache.get(2)) && "three".equals(cache.get(3));
        });
        t.put("reading an entry protects it from eviction", () -> {
            Main.LruCache<Integer, String> cache = new Main.LruCache<>(2);
            cache.put(1, "one");
            cache.put(2, "two");
            cache.get(1);
            cache.put(3, "three");
            return "one".equals(cache.get(1)) && cache.get(2) == null && "three".equals(cache.get(3));
        });
        t.put("updating a key refreshes its recency", () -> {
            Main.LruCache<Integer, String> cache = new Main.LruCache<>(2);
            cache.put(1, "one");
            cache.put(2, "two");
            cache.put(1, "ONE");
            cache.put(3, "three");
            return "ONE".equals(cache.get(1)) && cache.get(2) == null;
        });
        t.put("size reflects distinct live entries", () -> {
            Main.LruCache<Integer, String> cache = new Main.LruCache<>(3);
            cache.put(1, "a");
            cache.put(2, "b");
            cache.put(2, "B");
            return cache.size() == 2;
        });
        t.put("rejects a non-positive capacity", () -> {
            try {
                new Main.LruCache<Integer, String>(0);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("never holds more than capacity entries", () -> {
            Main.LruCache<Integer, Integer> cache = new Main.LruCache<>(3);
            for (int i = 0; i < 10; i++) {
                cache.put(i, i);
            }
            return cache.size() == 3;
        });
        return t;
    }
}
