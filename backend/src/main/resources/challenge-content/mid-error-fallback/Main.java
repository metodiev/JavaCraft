import java.util.List;

public class Main {
    public static List<String> signals(boolean mainFails, boolean fallbackAvailable) {
        // TODO: model onErrorResume: the fallback runs only when the main sequence fails,
        // and an empty fallback completes without emitting a value.
        return List.of();
    }
}
