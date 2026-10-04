import java.util.ArrayDeque;
import java.util.Optional;

public class Main {
    private final ArrayDeque<Integer> items = new ArrayDeque<>();
    private final int capacity;

    public Main(int capacity) {
        if (capacity < 1) {
            throw new IllegalArgumentException("capacity must be at least 1");
        }
        this.capacity = capacity;
    }

    public synchronized boolean offer(int item) {
        if (items.size() >= capacity) {
            return false;
        }
        items.add(item);
        return true;
    }

    public synchronized Optional<Integer> poll() {
        return Optional.ofNullable(items.poll());
    }
}
