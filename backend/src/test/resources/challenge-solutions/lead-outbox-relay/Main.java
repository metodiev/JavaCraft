import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

public class Main {
    public enum Status { PENDING, IN_FLIGHT, DELIVERED, FAILED }

    private final int maxAttempts;
    private final Map<String, Status> statuses = new LinkedHashMap<>();
    private final Map<String, Integer> attempts = new HashMap<>();

    public Main(int maxAttempts) {
        if (maxAttempts < 1) {
            throw new IllegalArgumentException("maxAttempts must be at least 1");
        }
        this.maxAttempts = maxAttempts;
    }

    public synchronized void add(String id) {
        statuses.putIfAbsent(id, Status.PENDING);
    }

    public synchronized Optional<String> claim() {
        for (Map.Entry<String, Status> entry : statuses.entrySet()) {
            if (entry.getValue() == Status.PENDING) {
                entry.setValue(Status.IN_FLIGHT);
                attempts.merge(entry.getKey(), 1, Integer::sum);
                return Optional.of(entry.getKey());
            }
        }
        return Optional.empty();
    }

    public synchronized void confirm(String id) {
        requireInFlight(id);
        statuses.put(id, Status.DELIVERED);
    }

    public synchronized void fail(String id, boolean transientFailure) {
        requireInFlight(id);
        boolean retry = transientFailure && attempts.getOrDefault(id, 0) < maxAttempts;
        statuses.put(id, retry ? Status.PENDING : Status.FAILED);
    }

    public synchronized Status status(String id) {
        return statuses.get(id);
    }

    private void requireInFlight(String id) {
        if (statuses.get(id) != Status.IN_FLIGHT) {
            throw new IllegalArgumentException("message is not in flight: " + id);
        }
    }
}
