import java.util.HashSet;
import java.util.Set;

public class Main {
    private final Set<String> seen = new HashSet<>();
    private final int capacity;

    public Main(int capacity) {
        this.capacity = capacity;
    }

    public boolean firstDelivery(String eventId) {
        // TODO: bound memory, evict the oldest, and be thread-safe
        return seen.add(eventId);
    }
}
