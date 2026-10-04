import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;

public class Main {
    private final Set<String> seen = new LinkedHashSet<>();
    private final int capacity;

    public Main(int capacity) {
        if (capacity < 1) {
            throw new IllegalArgumentException("capacity must be at least 1");
        }
        this.capacity = capacity;
    }

    public synchronized boolean firstDelivery(String eventId) {
        if (eventId == null) {
            throw new IllegalArgumentException("eventId is required");
        }
        if (!seen.add(eventId)) {
            return false;
        }
        if (seen.size() > capacity) {
            Iterator<String> oldest = seen.iterator();
            oldest.next();
            oldest.remove();
        }
        return true;
    }
}
