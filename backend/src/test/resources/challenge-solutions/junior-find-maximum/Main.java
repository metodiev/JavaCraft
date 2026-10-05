import java.util.OptionalInt;

public class Main {
    public static OptionalInt maximum(int[] values) {
        if (values == null || values.length == 0) {
            return OptionalInt.empty();
        }
        int best = values[0];
        for (int value : values) {
            if (value > best) {
                best = value;
            }
        }
        return OptionalInt.of(best);
    }
}
