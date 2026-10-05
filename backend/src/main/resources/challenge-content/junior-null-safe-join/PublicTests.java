import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("joins the given parts with the separator", () ->
                Main.joinNonBlank(Arrays.asList("a", "b", "c"), "-").equals("a-b-c"));
        t.put("trims each part before joining", () ->
                Main.joinNonBlank(Arrays.asList("  a ", "\tb\n"), "+").equals("a+b"));
        t.put("skips null and blank parts", () ->
                Main.joinNonBlank(Arrays.asList("a", null, "", "   ", "b"), ",").equals("a,b"));
        t.put("supports a multi-character separator", () ->
                Main.joinNonBlank(List.of("x", "y"), " -> ").equals("x -> y"));
        t.put("keeps an empty separator", () ->
                Main.joinNonBlank(List.of("a", "b"), "").equals("ab"));
        t.put("null list gives an empty string", () -> Main.joinNonBlank(null, ",").equals(""));
        t.put("all blank parts give an empty string", () ->
                Main.joinNonBlank(Arrays.asList(null, "  "), ",").equals(""));
        return t;
    }
}
