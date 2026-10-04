import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        List<String> values = List.of("a", "b", "c");
        t.put("returns a value at a valid index", () -> Main.find(values, 1).equals(Optional.of("b")));
        t.put("returns the first and last values", () -> Main.find(values, 0).equals(Optional.of("a"))
                && Main.find(values, 2).equals(Optional.of("c")));
        t.put("null list is empty", () -> Main.find(null, 0).isEmpty());
        t.put("negative index is empty", () -> Main.find(values, -1).isEmpty());
        t.put("index equal to size is empty", () -> Main.find(values, 3).isEmpty());
        t.put("empty list is empty", () -> Main.find(List.of(), 0).isEmpty());
        t.put("null element is empty", () -> Main.find(Arrays.asList("a", null), 1).isEmpty());
        return t;
    }
}
