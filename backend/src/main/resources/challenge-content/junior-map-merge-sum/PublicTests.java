import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("sums values for shared keys", () ->
                Main.mergeSums(Map.of("a", 2, "b", 3), Map.of("a", 5, "b", 1)).equals(Map.of("a", 7, "b", 4)));
        t.put("keeps keys present in only one map", () ->
                Main.mergeSums(Map.of("a", 2), Map.of("b", 3)).equals(Map.of("a", 2, "b", 3)));
        t.put("empty right map returns a copy of left", () ->
                Main.mergeSums(Map.of("a", 4), Map.of()).equals(Map.of("a", 4)));
        t.put("empty left map returns a copy of right", () ->
                Main.mergeSums(Map.of(), Map.of("z", -1)).equals(Map.of("z", -1)));
        t.put("null maps behave like empty maps", () ->
                Main.mergeSums(null, null).isEmpty()
                        && Main.mergeSums(null, Map.of("a", 1)).equals(Map.of("a", 1))
                        && Main.mergeSums(Map.of("a", 1), null).equals(Map.of("a", 1)));
        t.put("does not mutate either input", () -> {
            Map<String, Integer> left = new HashMap<>(Map.of("a", 1));
            Map<String, Integer> right = new HashMap<>(Map.of("a", 1));
            Main.mergeSums(left, right);
            return left.equals(Map.of("a", 1)) && right.equals(Map.of("a", 1));
        });
        return t;
    }
}
