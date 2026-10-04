import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("retry with the same key and request runs once", () -> {
            Main m = new Main();
            int[] calls = {0};
            Function<String, String> action = r -> { calls[0]++; return "done:" + r; };
            return m.execute("k", "pay", action).equals("done:pay") && m.execute("k", "pay", action).equals("done:pay")
                    && calls[0] == 1;
        });
        t.put("different keys run independently", () -> {
            Main m = new Main();
            int[] calls = {0};
            Function<String, String> action = r -> { calls[0]++; return r; };
            m.execute("a", "x", action);
            m.execute("b", "x", action);
            return calls[0] == 2;
        });
        t.put("same key with a different request conflicts", () -> {
            Main m = new Main();
            m.execute("k", "one", r -> r);
            try {
                m.execute("k", "two", r -> r);
                return false;
            } catch (Main.ConflictException expected) {
                return true;
            }
        });
        t.put("failures are not cached", () -> {
            Main m = new Main();
            try {
                m.execute("k", "x", r -> { throw new IllegalStateException("boom"); });
                return false;
            } catch (IllegalStateException expected) {
                return m.execute("k", "x", r -> "ok").equals("ok");
            }
        });
        t.put("concurrent duplicates run once", () -> {
            Main m = new Main();
            java.util.concurrent.atomic.AtomicInteger calls = new java.util.concurrent.atomic.AtomicInteger();
            ExecutorService pool = Executors.newFixedThreadPool(8);
            CountDownLatch go = new CountDownLatch(1);
            List<Future<String>> results = new ArrayList<>();
            for (int i = 0; i < 8; i++) {
                results.add(pool.submit(() -> {
                    go.await();
                    return m.execute("k", "x", r -> { calls.incrementAndGet(); sleep(50); return "ok"; });
                }));
            }
            go.countDown();
            for (Future<String> f : results) f.get(5, TimeUnit.SECONDS);
            pool.shutdownNow();
            return calls.get() == 1;
        });
        return t;
    }

    private static void sleep(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }
}
