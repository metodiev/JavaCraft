import java.util.function.Function;

public class Main {
    public static class ConflictException extends RuntimeException {
        public ConflictException(String message) { super(message); }
    }

    public String execute(String key, String request, Function<String, String> action) {
        // TODO: make retries with the same key execute the action at most once
        return action.apply(request);
    }
}
