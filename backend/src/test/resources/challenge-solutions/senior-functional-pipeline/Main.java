import java.util.List;
import java.util.function.Function;

public class Main {
    public static <T> Function<T, T> pipeline(List<Function<T, T>> steps) {
        return value -> {
            T result = value;
            for (Function<T, T> step : steps) {
                result = step.apply(result);
            }
            return result;
        };
    }
}
