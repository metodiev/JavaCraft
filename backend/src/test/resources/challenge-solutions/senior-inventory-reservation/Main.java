import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    private final AtomicInteger available = new AtomicInteger(10);

    public boolean reserve(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("quantity must be positive");
        }
        while (true) {
            int current = available.get();
            if (current < quantity) {
                return false;
            }
            if (available.compareAndSet(current, current - quantity)) {
                return true;
            }
        }
    }

    public int available() {
        return available.get();
    }
}
