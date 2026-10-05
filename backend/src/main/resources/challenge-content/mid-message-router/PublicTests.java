import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the first channel accepting the type wins", () ->
                "orders".equals(Main.channelFor("created", linked("orders", List.of("created"),
                        "audit", List.of("created", "deleted")))));
        t.put("a later channel is chosen when earlier ones do not match", () ->
                "billing".equals(Main.channelFor("paid", linked("orders", List.of("created"),
                        "billing", List.of("paid")))));
        t.put("matching a message type is case sensitive", () ->
                "default".equals(Main.channelFor("CREATED", linked("orders", List.of("created")))));
        t.put("an unrouted type falls back to the default channel", () ->
                "default".equals(Main.channelFor("unknown", linked("orders", List.of("created")))));
        t.put("missing input falls back to the default channel", () ->
                "default".equals(Main.channelFor(null, linked("orders", List.of("created"))))
                        && "default".equals(Main.channelFor("created", null)));
        t.put("null keys and null lists are skipped while matching", () ->
                "billing".equals(Main.channelFor("paid", linked(null, List.of("paid"),
                        "billing", List.of("paid"))))
                        && "default".equals(Main.channelFor("paid", linked(null, List.of("paid"))))
                        && "billing".equals(Main.channelFor("paid", linked("orders", null,
                        "billing", List.of("paid"))))
                        && "default".equals(Main.channelFor("paid", linked("orders", null,
                        "empty", new ArrayList<>()))));
        t.put("an empty routing map uses the fallback", () ->
                "default".equals(Main.channelFor("created", linked())));
        return t;
    }

    private static Map<String, List<String>> linked(Object... pairs) {
        Map<String, List<String>> map = new LinkedHashMap<>();
        for (int i = 0; i + 1 < pairs.length; i += 2) {
            @SuppressWarnings("unchecked")
            List<String> value = (List<String>) pairs[i + 1];
            map.put((String) pairs[i], value);
        }
        return map;
    }
}
