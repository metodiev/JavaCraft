import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    private final AtomicInteger available = new AtomicInteger(10);

    public boolean reserve(int quantity) {
        // TODO: never oversell, even under concurrency
        available.addAndGet(-quantity);
        return true;
    }

    public int available() {
        return available.get();
    }
}
