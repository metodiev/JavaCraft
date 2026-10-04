import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

public class Main {
    public static class ConflictException extends RuntimeException {
        public ConflictException(String message) { super(message); }
    }

    private record Entry(String request, String response) {}

    private final Map<String, Entry> completed = new HashMap<>();
    private final Map<String, String> inFlight = new HashMap<>();

    public synchronized String execute(String key, String request, Function<String, String> action) {
        while (true) {
            Entry done = completed.get(key);
            if (done != null) {
                if (!done.request().equals(request)) throw new ConflictException("key reused with a different request");
                return done.response();
            }
            String running = inFlight.get(key);
            if (running == null) break;
            if (!running.equals(request)) throw new ConflictException("key reused with a different request");
            try {
                wait();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new IllegalStateException(e);
            }
        }
        inFlight.put(key, request);
        try {
            String response = action.apply(request);
            completed.put(key, new Entry(request, response));
            return response;
        } finally {
            inFlight.remove(key);
            notifyAll();
        }
    }
}
