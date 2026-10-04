import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("first delivery is true, repeat is false", () -> {
            Main d = new Main(10);
            return d.firstDelivery("a") && !d.firstDelivery("a");
        });
        t.put("different ids are independent", () -> {
            Main d = new Main(10);
            return d.firstDelivery("a") && d.firstDelivery("b");
        });
        t.put("oldest id is evicted at capacity", () -> {
            Main d = new Main(2);
            d.firstDelivery("a"); d.firstDelivery("b"); d.firstDelivery("c");
            return d.firstDelivery("a") && !d.firstDelivery("c");
        });
        t.put("invalid arguments are rejected", () -> {
            try { new Main(0); return false; } catch (IllegalArgumentException e) { }
            try { new Main(1).firstDelivery(null); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("concurrent duplicates are accepted once", () -> {
            Main d = new Main(100);
            java.util.concurrent.atomic.AtomicInteger firsts = new java.util.concurrent.atomic.AtomicInteger();
            ExecutorService pool = Executors.newFixedThreadPool(8);
            List<Future<?>> fs = new ArrayList<>();
            for (int i = 0; i < 8; i++) {
                fs.add(pool.submit(() -> { for (int j = 0; j < 50; j++) if (d.firstDelivery("e" + j)) firsts.incrementAndGet(); }));
            }
            for (Future<?> f : fs) f.get(5, TimeUnit.SECONDS);
            pool.shutdownNow();
            return firsts.get() == 50;
        });
        return t;
    }
}
