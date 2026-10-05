import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("sorts shorter strings first", () ->
                Main.byLength(List.of("ccc", "a", "bb")).equals(List.of("a", "bb", "ccc")));
        t.put("equal lengths keep their original order", () ->
                Main.byLength(List.of("bb", "aa", "c")).equals(List.of("c", "bb", "aa")));
        t.put("empty strings sort before longer ones", () ->
                Main.byLength(List.of("abc", "", "z")).equals(List.of("", "z", "abc")));
        t.put("nulls go last", () ->
                Main.byLength(Arrays.asList("aaa", null, "b")).equals(Arrays.asList("b", "aaa", null)));
        t.put("several nulls keep their original order", () ->
                Main.byLength(Arrays.asList(null, "x", null)).equals(Arrays.asList("x", null, null)));
        t.put("null input yields an empty list", () -> Main.byLength(null).isEmpty());
        t.put("empty input yields an empty list", () -> Main.byLength(List.of()).isEmpty());
        t.put("single element is returned", () -> Main.byLength(List.of("only")).equals(List.of("only")));
        return t;
    }
}
