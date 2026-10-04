import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("items come out in FIFO order", () -> {
            Main q = new Main(3);
            q.offer(1); q.offer(2);
            return q.poll().equals(Optional.of(1)) && q.poll().equals(Optional.of(2));
        });
        t.put("offer fails when full", () -> {
            Main q = new Main(2);
            return q.offer(1) && q.offer(2) && !q.offer(3);
        });
        t.put("space is reusable after poll", () -> {
            Main q = new Main(1);
            q.offer(1); q.poll();
            return q.offer(2);
        });
        t.put("poll on empty is empty", () -> new Main(1).poll().isEmpty());
        t.put("capacity below one is rejected", () -> {
            try { new Main(0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("concurrent producers never exceed capacity", () -> {
            Main q = new Main(50);
            ExecutorService pool = Executors.newFixedThreadPool(8);
            java.util.concurrent.atomic.AtomicInteger accepted = new java.util.concurrent.atomic.AtomicInteger();
            List<Future<?>> fs = new ArrayList<>();
            for (int i = 0; i < 8; i++) {
                fs.add(pool.submit(() -> { for (int j = 0; j < 100; j++) if (q.offer(j)) accepted.incrementAndGet(); }));
            }
            for (Future<?> f : fs) f.get(5, TimeUnit.SECONDS);
            pool.shutdownNow();
            int drained = 0;
            while (q.poll().isPresent()) drained++;
            return accepted.get() == 50 && drained == 50;
        });
        return t;
    }
}
