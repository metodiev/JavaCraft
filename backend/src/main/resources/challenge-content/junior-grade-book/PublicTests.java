import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("average keeps the fraction", () -> {
            OptionalDouble average = Main.average(List.of(90, 80, 71));
            return average.isPresent() && Math.abs(average.getAsDouble() - 80.3333333333) < 1e-6;
        });
        t.put("boundary scores are accepted", () -> Main.average(List.of(0, 100)).orElse(-1) == 50.0);
        t.put("single score is its own average", () -> Main.average(List.of(100)).orElse(-1) == 100.0);
        t.put("empty list has no average", () -> Main.average(List.of()).isEmpty());
        t.put("null list has no average", () -> Main.average(null).isEmpty());
        t.put("score above 100 is rejected", () -> rejects(List.of(90, 101)));
        t.put("negative score is rejected", () -> rejects(List.of(-1, 90)));
        t.put("null score is rejected", () -> rejects(Arrays.asList(90, null)));
        return t;
    }

    private static boolean rejects(List<Integer> scores) {
        try {
            Main.average(scores);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
