import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("acquire up to the limit", () -> { Main m = new Main(); return m.tryAcquire(2) && m.tryAcquire(2) && !m.tryAcquire(2) && m.active() == 2; });
        t.put("release frees a slot", () -> { Main m = new Main(); m.tryAcquire(1); m.release(); return m.active() == 0 && m.tryAcquire(1); });
        t.put("release without acquire fails", () -> {
            try { new Main().release(); return false; } catch (IllegalStateException e) { return true; }
        });
        t.put("limit below one is rejected", () -> {
            try { new Main().tryAcquire(0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("concurrent acquires respect the limit", () -> {
            Main m = new Main();
            java.util.concurrent.atomic.AtomicInteger ok = new java.util.concurrent.atomic.AtomicInteger();
            ExecutorService pool = Executors.newFixedThreadPool(8);
            CountDownLatch go = new CountDownLatch(1);
            List<Future<?>> fs = new ArrayList<>();
            for (int i = 0; i < 8; i++) {
                fs.add(pool.submit(() -> { go.await(); for (int j = 0; j < 50; j++) if (m.tryAcquire(5)) ok.incrementAndGet(); return null; }));
            }
            go.countDown();
            for (Future<?> f : fs) f.get(5, TimeUnit.SECONDS);
            pool.shutdownNow();
            return ok.get() == 5 && m.active() == 5;
        });
        return t;
    }
}
