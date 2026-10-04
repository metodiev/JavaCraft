import java.util.List;
import java.util.function.Consumer;

public class Main {
    public record BatchResult(List<String> succeeded, List<String> failed) {}

    public static BatchResult process(List<String> items, Consumer<String> handler) {
        // TODO: one failing item must not stop the rest
        for (String item : items) {
            handler.accept(item);
        }
        return new BatchResult(items, List.of());
    }
}
