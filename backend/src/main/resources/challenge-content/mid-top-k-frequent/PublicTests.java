import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("orders by descending frequency", () -> Main.topK(List.of("a", "a", "b", "c"), 2).equals(List.of("a", "b")));
        t.put("breaks ties alphabetically", () ->
                Main.topK(List.of("b", "b", "a", "a", "c"), 2).equals(List.of("a", "b")));
        t.put("returns all distinct words when k is large", () ->
                Main.topK(List.of("x", "y"), 5).equals(List.of("x", "y")));
        t.put("k larger than distinct words is bounded", () -> Main.topK(List.of("x", "x", "x"), 10).equals(List.of("x")));
        t.put("empty and null input yield an empty list", () ->
                Main.topK(List.of(), 3).isEmpty() && Main.topK(null, 3).isEmpty());
        t.put("non-positive k yields an empty list", () ->
                Main.topK(List.of("a"), 0).isEmpty() && Main.topK(List.of("a"), -2).isEmpty());
        t.put("null words are skipped", () -> Main.topK(Arrays.asList("a", null, "a"), 2).equals(List.of("a")));
        t.put("case-sensitive ties break by natural order", () ->
                Main.topK(List.of("b", "B", "a"), 3).equals(List.of("B", "a", "b")));
        return t;
    }
}
