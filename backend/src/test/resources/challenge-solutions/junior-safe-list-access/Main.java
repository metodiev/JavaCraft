import java.util.List;
import java.util.Optional;

public class Main {
    public static Optional<String> find(List<String> values, int index) {
        if (values == null || index < 0 || index >= values.size()) {
            return Optional.empty();
        }
        return Optional.ofNullable(values.get(index));
    }
}
