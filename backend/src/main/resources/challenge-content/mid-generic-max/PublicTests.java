import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("finds the maximum integer", () -> Main.max(List.of(3, 1, 4, 2)).equals(Optional.of(4)));
        t.put("finds the maximum string", () -> Main.max(List.of("pear", "apple", "plum")).equals(Optional.of("plum")));
        t.put("single element list is its own maximum", () -> Main.max(List.of(9)).equals(Optional.of(9)));
        t.put("empty list gives empty optional", () -> Main.<Integer>max(List.of()).isEmpty());
        t.put("null list gives empty optional", () -> {
            List<Integer> values = null;
            return Main.max(values).isEmpty();
        });
        t.put("ignores null entries", () -> {
            List<Integer> values = Arrays.asList(5, null, 7, null);
            return Main.max(values).equals(Optional.of(7));
        });
        t.put("list of only nulls gives empty optional", () -> {
            List<Integer> values = Arrays.asList(null, null);
            return Main.max(values).isEmpty();
        });
        t.put("negative values compare correctly", () -> Main.max(List.of(-3, -7, -1)).equals(Optional.of(-1)));
        return t;
    }
}
