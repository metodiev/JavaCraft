import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;

public class Main {
    public record BatchResult(List<String> succeeded, List<String> failed) {}

    public static BatchResult process(List<String> items, Consumer<String> handler) {
        if (items == null) {
            throw new IllegalArgumentException("items must not be null");
        }
        for (String item : items) {
            if (item == null) {
                throw new IllegalArgumentException("items must not contain null");
            }
        }
        List<String> succeeded = new ArrayList<>();
        List<String> failed = new ArrayList<>();
        for (String item : items) {
            try {
                handler.accept(item);
                succeeded.add(item);
            } catch (RuntimeException e) {
                failed.add(item);
            }
        }
        return new BatchResult(succeeded, failed);
    }
}
