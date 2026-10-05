import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("returns a stored value", () -> {
            Main.ConcurrentLruCache<Integer, String> cache = new Main.ConcurrentLruCache<>(2);
            cache.put(1, "one");
            return "one".equals(cache.get(1));
        });
        t.put("evicts the least recently used entry", () -> {
            Main.ConcurrentLruCache<Integer, String> cache = new Main.ConcurrentLruCache<>(2);
            cache.put(1, "one");
            cache.put(2, "two");
            cache.put(3, "three");
            return cache.get(1) == null && "three".equals(cache.get(3));
        });
        t.put("reads refresh recency", () -> {
            Main.ConcurrentLruCache<Integer, String> cache = new Main.ConcurrentLruCache<>(2);
            cache.put(1, "one");
            cache.put(2, "two");
            cache.get(1);
            cache.put(3, "three");
            return "one".equals(cache.get(1)) && cache.get(2) == null;
        });
        t.put("size never exceeds the capacity", () -> {
            Main.ConcurrentLruCache<Integer, Integer> cache = new Main.ConcurrentLruCache<>(4);
            for (int i = 0; i < 200; i++) {
                cache.put(i, i);
            }
            return cache.size() == 4;
        });
        t.put("concurrent puts keep size within capacity", () -> {
            Main.ConcurrentLruCache<Integer, Integer> cache = new Main.ConcurrentLruCache<>(8);
            int workers = 4;
            int operations = 250;
            Thread[] threads = new Thread[workers];
            for (int w = 0; w < workers; w++) {
                threads[w] = new Thread(() -> {
                    for (int i = 0; i < operations; i++) {
                        cache.put(i, i);
                        cache.get(i);
                    }
                });
                threads[w].start();
            }
            try {
                for (Thread thread : threads) {
                    thread.join(1500);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return false;
            }
            for (Thread thread : threads) {
                if (thread.isAlive()) {
                    return false;
                }
            }
            return cache.size() <= 8;
        });
        t.put("concurrent reads never crash", () -> {
            Main.ConcurrentLruCache<String, Integer> cache = new Main.ConcurrentLruCache<>(4);
            cache.put("seed", 1);
            Thread reader = new Thread(() -> {
                for (int i = 0; i < 300; i++) {
                    cache.get("seed");
                }
            });
            reader.start();
            try {
                reader.join(1500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return false;
            }
            return !reader.isAlive();
        });
        t.put("rejects a non-positive capacity", () -> {
            try {
                new Main.ConcurrentLruCache<Integer, String>(0);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("a miss returns null without changing size", () -> {
            Main.ConcurrentLruCache<Integer, String> cache = new Main.ConcurrentLruCache<>(2);
            cache.put(1, "one");
            return cache.get(42) == null && cache.size() == 1;
        });
        return t;
    }
}
