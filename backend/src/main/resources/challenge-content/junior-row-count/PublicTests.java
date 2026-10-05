import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts values above the threshold", () -> Main.countMatching(List.of(1, 5, 10, 20), 5, false) == 2);
        t.put("inclusive counts the threshold itself", () -> Main.countMatching(List.of(1, 5, 10, 20), 5, true) == 3);
        t.put("empty list counts zero", () -> Main.countMatching(List.of(), 5, true) == 0);
        t.put("null input counts zero", () -> Main.countMatching(null, 5, true) == 0);
        t.put("all values below the threshold counts zero", () -> Main.countMatching(List.of(1, 2, 3), 10, true) == 0);
        t.put("all values at the threshold are counted when inclusive", () -> Main.countMatching(List.of(7, 7, 7), 7, true) == 3);
        t.put("negative values are counted normally", () -> Main.countMatching(List.of(-5, -1, 0, 1), -1, false) == 2);
        return t;
    }
}
