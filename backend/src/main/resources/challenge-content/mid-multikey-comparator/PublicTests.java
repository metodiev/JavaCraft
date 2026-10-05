import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static List<String> sorted(List<String> values) {
        List<String> copy = new ArrayList<>(values);
        copy.sort(Main.byLengthThenText());
        return copy;
    }

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("sorts shorter text first", () ->
                sorted(List.of("ccc", "a", "bb")).equals(List.of("a", "bb", "ccc")));
        t.put("breaks ties with natural order", () ->
                sorted(List.of("bb", "aa", "cc")).equals(List.of("aa", "bb", "cc")));
        t.put("keeps equal-length ties case sensitive natural order", () ->
                sorted(List.of("b", "A")).equals(List.of("A", "b")));
        t.put("puts nulls last", () ->
                sorted(Arrays.asList("b", null, "a")).equals(Arrays.asList("a", "b", null)));
        t.put("puts nulls after equal-length text", () ->
                sorted(Arrays.asList(null, "aa", "bb")).equals(Arrays.asList("aa", "bb", null)));
        t.put("is stable for identical values", () ->
                sorted(List.of("xy", "xy", "ab")).equals(List.of("ab", "xy", "xy")));
        t.put("compares single elements without error", () ->
                Main.byLengthThenText().compare(null, null) == 0
                        && Main.byLengthThenText().compare(null, "a") > 0
                        && Main.byLengthThenText().compare("a", null) < 0);
        return t;
    }
}
