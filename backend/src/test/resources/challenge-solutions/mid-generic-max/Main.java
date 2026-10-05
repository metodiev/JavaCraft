import java.util.List;
import java.util.Optional;

public class Main {
    public static <T extends Comparable<T>> Optional<T> max(List<T> values) {
        if (values == null) {
            return Optional.empty();
        }
        T best = null;
        for (T value : values) {
            if (value != null && (best == null || value.compareTo(best) > 0)) {
                best = value;
            }
        }
        return Optional.ofNullable(best);
    }
}
