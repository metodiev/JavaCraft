import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("reservation reduces stock", () -> { Main m = new Main(); return m.reserve(3) && m.available() == 7; });
        t.put("reserving everything is allowed", () -> { Main m = new Main(); return m.reserve(10) && m.available() == 0; });
        t.put("oversell is refused and changes nothing", () -> {
            Main m = new Main();
            return !m.reserve(11) && m.available() == 10;
        });
        t.put("non-positive quantity is rejected", () -> {
            try { new Main().reserve(0); return false; } catch (IllegalArgumentException e) { }
            try { new Main().reserve(-5); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("concurrent reservations never oversell", () -> {
            Main m = new Main();
            java.util.concurrent.atomic.AtomicInteger ok = new java.util.concurrent.atomic.AtomicInteger();
            ExecutorService pool = Executors.newFixedThreadPool(8);
            CountDownLatch go = new CountDownLatch(1);
            List<Future<?>> fs = new ArrayList<>();
            for (int i = 0; i < 8; i++) {
                fs.add(pool.submit(() -> { go.await(); for (int j = 0; j < 50; j++) if (m.reserve(1)) ok.incrementAndGet(); return null; }));
            }
            go.countDown();
            for (Future<?> f : fs) f.get(5, TimeUnit.SECONDS);
            pool.shutdownNow();
            return ok.get() == 10 && m.available() == 0;
        });
        return t;
    }
}
