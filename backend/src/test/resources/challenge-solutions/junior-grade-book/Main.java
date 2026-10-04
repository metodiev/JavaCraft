import java.util.List;
import java.util.OptionalDouble;

public class Main {
    public static OptionalDouble average(List<Integer> scores) {
        if (scores == null || scores.isEmpty()) {
            return OptionalDouble.empty();
        }
        long total = 0;
        for (Integer score : scores) {
            if (score == null || score < 0 || score > 100) {
                throw new IllegalArgumentException("scores must be between 0 and 100");
            }
            total += score;
        }
        return OptionalDouble.of((double) total / scores.size());
    }
}
