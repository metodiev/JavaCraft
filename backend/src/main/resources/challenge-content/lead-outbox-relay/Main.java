import java.util.Optional;

public class Main {
    public enum Status { PENDING, IN_FLIGHT, DELIVERED, FAILED }

    public Main(int maxAttempts) {
        // TODO
    }

    public void add(String id) {}

    public Optional<String> claim() {
        // TODO: hand out the oldest pending message exactly once
        return Optional.empty();
    }

    public void confirm(String id) {}

    public void fail(String id, boolean transientFailure) {}

    public Status status(String id) {
        return null;
    }
}
