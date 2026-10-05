import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("contains treats both ends as inside", () ->
                Main.Range.of(1, 5).contains(1) && Main.Range.of(1, 5).contains(5));
        t.put("contains rejects values outside", () ->
                !Main.Range.of(1, 5).contains(0) && !Main.Range.of(1, 5).contains(6));
        t.put("contains accepts an interior value", () -> Main.Range.of(1, 5).contains(3));
        t.put("a single point range contains only that point", () -> {
            Main.Range point = Main.Range.of(4, 4);
            return point.contains(4) && !point.contains(5) && !point.contains(3);
        });
        t.put("negative bounds work", () ->
                Main.Range.of(-5, -1).contains(-3) && !Main.Range.of(-5, -1).contains(-6));
        t.put("constructor rejects low greater than high", () -> {
            try {
                new Main.Range(5, 1);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("factory rejects low greater than high", () -> {
            try {
                Main.Range.of(9, 2);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("equal bounds are allowed", () -> Main.Range.of(7, 7).low() == 7 && Main.Range.of(7, 7).high() == 7);
        return t;
    }
}
