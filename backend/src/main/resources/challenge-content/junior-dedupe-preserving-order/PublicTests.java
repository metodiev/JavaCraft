import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("keeps first occurrences in order", () ->
                Main.uniqueInOrder(List.of("b", "a", "b", "c", "a")).equals(List.of("b", "a", "c")));
        t.put("ignores null entries", () ->
                Main.uniqueInOrder(Arrays.asList("a", null, "b", null, "a")).equals(List.of("a", "b")));
        t.put("is case sensitive", () ->
                Main.uniqueInOrder(List.of("A", "a", "A")).equals(List.of("A", "a")));
        t.put("keeps blank strings as distinct value", () ->
                Main.uniqueInOrder(List.of(" ", "", " ")).equals(List.of(" ", "")));
        t.put("empty list stays empty", () -> Main.uniqueInOrder(List.of()).isEmpty());
        t.put("null list gives empty result", () -> Main.uniqueInOrder(null).isEmpty());
        t.put("all duplicates collapse to one", () ->
                Main.uniqueInOrder(List.of("x", "x", "x", "x")).equals(List.of("x")));
        return t;
    }
}
