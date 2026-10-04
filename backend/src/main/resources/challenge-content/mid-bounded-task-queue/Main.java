import java.util.ArrayDeque;
import java.util.Optional;

public class Main {
    private final ArrayDeque<Integer> items = new ArrayDeque<>();
    private final int capacity;

    public Main(int capacity) {
        this.capacity = capacity;
    }

    public boolean offer(int item) {
        // TODO: respect capacity and make this thread-safe
        items.add(item);
        return true;
    }

    public Optional<Integer> poll() {
        // TODO: make this thread-safe
        return Optional.ofNullable(items.poll());
    }
}
