import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an exact supported version wins", () ->
                "v3".equals(Main.handlerFor(3, List.of(1, 2, 3))));
        t.put("an exact middle version beats a higher handler", () ->
                "v2".equals(Main.handlerFor(2, List.of(1, 2, 3))));
        t.put("a newer event uses the highest supported version below it", () ->
                "v3".equals(Main.handlerFor(5, List.of(1, 2, 3))));
        t.put("the highest compatible version ignores order and duplicates", () ->
                "v3".equals(Main.handlerFor(4, List.of(2, 3, 3, 1))));
        t.put("an event older than every handler has none", () ->
                Main.handlerFor(0, List.of(1, 2, 3)) == null);
        t.put("missing or empty support has no handler", () ->
                Main.handlerFor(1, null) == null && Main.handlerFor(1, List.of()) == null);
        t.put("null entries and invalid versions are ignored", () ->
                "v2".equals(Main.handlerFor(2, Arrays.asList(null, 2)))
                        && Main.handlerFor(-1, List.of(1)) == null);
        return t;
    }
}
