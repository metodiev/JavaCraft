import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    private final AtomicInteger active = new AtomicInteger();

    public boolean tryAcquire(int limit) {
        // TODO: enforce the limit atomically
        active.incrementAndGet();
        return true;
    }

    public void release() {
        // TODO: reject releases that were never acquired
        active.decrementAndGet();
    }

    public int active() {
        return active.get();
    }
}
