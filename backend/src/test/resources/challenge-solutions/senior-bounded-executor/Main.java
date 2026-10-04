import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    private final AtomicInteger active = new AtomicInteger();

    public boolean tryAcquire(int limit) {
        if (limit < 1) {
            throw new IllegalArgumentException("limit must be at least 1");
        }
        while (true) {
            int current = active.get();
            if (current >= limit) {
                return false;
            }
            if (active.compareAndSet(current, current + 1)) {
                return true;
            }
        }
    }

    public void release() {
        while (true) {
            int current = active.get();
            if (current == 0) {
                throw new IllegalStateException("release without acquire");
            }
            if (active.compareAndSet(current, current - 1)) {
                return;
            }
        }
    }

    public int active() {
        return active.get();
    }
}
