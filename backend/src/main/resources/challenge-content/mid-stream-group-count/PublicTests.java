import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts words sharing an initial", () ->
                Main.countByInitial(List.of("Apple", "avocado", "Banana")).equals(Map.of('a', 2L, 'b', 1L)));
        t.put("groups upper and lower case under one key", () ->
                Main.countByInitial(List.of("cat", "Cat", "CAT")).equals(Map.of('c', 3L)));
        t.put("skips null and blank words", () ->
                Main.countByInitial(Arrays.asList("apple", null, "   ", "", "apricot")).equals(Map.of('a', 2L)));
        t.put("empty list gives an empty map", () -> Main.countByInitial(List.of()).isEmpty());
        t.put("null list gives an empty map", () -> Main.countByInitial(null).isEmpty());
        t.put("all blank words give an empty map", () ->
                Main.countByInitial(Arrays.asList(null, " ", "\t")).isEmpty());
        t.put("non-letter initials are valid keys", () ->
                Main.countByInitial(List.of("123", "1st", "$5")).equals(Map.of('1', 2L, '$', 1L)));
        return t;
    }
}
