import java.util.List;
import java.util.function.Function;

public class Main {
    public static <T> Function<T, T> pipeline(List<Function<T, T>> steps) {
        // TODO: compose the steps so they run in order, and return the identity when the list is empty
        return value -> value;
    }
}
