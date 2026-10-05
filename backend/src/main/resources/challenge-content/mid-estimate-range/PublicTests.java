import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("typical range is best, likely and worst", () -> Main.estimate(4, 1.5).equals(
                Map.of("best", 4, "likely", 6, "worst", 8)));
        t.put("factor of one pins the whole range", () -> Main.estimate(3, 1.0).equals(
                Map.of("best", 3, "likely", 3, "worst", 3)));
        t.put("fractional products use ceiling", () -> Main.estimate(3, 1.5).equals(
                Map.of("best", 3, "likely", 5, "worst", 7)));
        t.put("small estimate still gets a full range", () -> Main.estimate(1, 2.0).equals(
                Map.of("best", 1, "likely", 2, "worst", 3)));
        t.put("larger factors scale the range", () -> Main.estimate(10, 4.0).equals(
                Map.of("best", 10, "likely", 40, "worst", 70)));
        t.put("factor above five is clamped", () -> Main.estimate(10, 8.0).equals(
                Map.of("best", 10, "likely", 50, "worst", 90)));
        t.put("optimistic days must be positive", () -> rejects(0, 1.5) && rejects(-3, 1.5));
        t.put("uncertainty factor must be at least one", () -> rejects(4, 0.5) && rejects(4, 0.0));
        return t;
    }

    private static boolean rejects(int days, double factor) {
        try {
            Main.estimate(days, factor);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
