import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("finds the largest of mixed values", () -> Main.maximum(new int[]{3, 9, 4}).orElse(-1) == 9);
        t.put("maximum of a single element is that element", () -> Main.maximum(new int[]{42}).orElse(-1) == 42);
        t.put("duplicate maximum values are fine", () -> Main.maximum(new int[]{5, 7, 7, 2}).orElse(-1) == 7);
        t.put("maximum can appear at the end", () -> Main.maximum(new int[]{1, 2, 10}).orElse(-1) == 10);
        t.put("works with only negative values", () -> Main.maximum(new int[]{-8, -3, -12}).orElse(0) == -3);
        t.put("supports Integer.MIN_VALUE at the smallest extremes", () ->
                Main.maximum(new int[]{Integer.MIN_VALUE, -5}).orElse(0) == -5
                        && Main.maximum(new int[]{Integer.MIN_VALUE}).orElse(0) == Integer.MIN_VALUE);
        t.put("null input yields empty", () -> Main.maximum(null).isEmpty());
        t.put("empty input yields empty", () -> Main.maximum(new int[0]).isEmpty());
        return t;
    }
}
