import java.util.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Supplier;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the loader runs once per key", () -> {
            ConcurrentHashMap<String, String> cache = new ConcurrentHashMap<>();
            AtomicInteger loads = new AtomicInteger();
            Supplier<String> loader = () -> "v" + loads.incrementAndGet();
            String first = Main.computeOnce(cache, "k", loader);
            String second = Main.computeOnce(cache, "k", loader);
            return "v1".equals(first) && "v1".equals(second) && loads.get() == 1;
        });
        t.put("an existing mapping skips the loader", () -> {
            ConcurrentHashMap<String, String> cache = new ConcurrentHashMap<>();
            cache.put("k", "cached");
            AtomicInteger loads = new AtomicInteger();
            String value = Main.computeOnce(cache, "k", () -> {
                loads.incrementAndGet();
                return "loaded";
            });
            return "cached".equals(value) && loads.get() == 0;
        });
        t.put("different keys load independently", () -> {
            ConcurrentHashMap<String, String> cache = new ConcurrentHashMap<>();
            AtomicInteger loads = new AtomicInteger();
            Supplier<String> loader = () -> "v" + loads.incrementAndGet();
            return "v1".equals(Main.computeOnce(cache, "a", loader))
                    && "v2".equals(Main.computeOnce(cache, "b", loader))
                    && loads.get() == 2;
        });
        t.put("a null loader result is not cached", () -> {
            ConcurrentHashMap<String, String> cache = new ConcurrentHashMap<>();
            AtomicInteger loads = new AtomicInteger();
            Supplier<String> loader = () -> {
                loads.incrementAndGet();
                return null;
            };
            String first = Main.computeOnce(cache, "k", loader);
            String second = Main.computeOnce(cache, "k", loader);
            return first == null && second == null && loads.get() == 2 && !cache.containsKey("k");
        });
        t.put("a null cache is rejected", () -> {
            try {
                Main.computeOnce(null, "k", () -> "v");
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("a null key is rejected", () -> {
            try {
                Main.computeOnce(new ConcurrentHashMap<>(), null, () -> "v");
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("a null loader is rejected", () -> {
            try {
                Main.computeOnce(new ConcurrentHashMap<>(), "k", null);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
