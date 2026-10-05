import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a top level string field is resolved", () ->
                Main.field("{\"name\":\"ada\"}", "name").equals(Optional.of("ada")));
        t.put("a nested field is resolved through dotted paths", () ->
                Main.field("{\"a\":{\"b\":{\"c\":\"deep\"}}}", "a.b.c").equals(Optional.of("deep")));
        t.put("a missing key yields empty", () ->
                Main.field("{\"a\":{\"b\":\"x\"}}", "a.z").isEmpty());
        t.put("a path through a non-object yields empty", () ->
                Main.field("{\"items\":[{\"id\":\"1\"}]}", "items.id").isEmpty());
        t.put("a non-string value yields empty", () ->
                Main.field("{\"n\":42,\"flag\":true,\"nil\":null}", "n").isEmpty()
                        && Main.field("{\"n\":42,\"flag\":true,\"nil\":null}", "flag").isEmpty()
                        && Main.field("{\"n\":42,\"flag\":true,\"nil\":null}", "nil").isEmpty());
        t.put("malformed json yields empty", () ->
                Main.field("{\"a\":\"b\"", "a").isEmpty()
                        && Main.field("{\"a\":}", "a").isEmpty()
                        && Main.field("not json", "a").isEmpty());
        t.put("escapes in string values are decoded", () ->
                Main.field("{\"a\":\"say \\\"hi\\\"\"}", "a").equals(Optional.of("say \"hi\"")));
        t.put("null or empty arguments yield empty", () ->
                Main.field(null, "a").isEmpty()
                        && Main.field("{\"a\":\"x\"}", null).isEmpty()
                        && Main.field("{\"a\":\"x\"}", "").isEmpty());
        t.put("whitespace around tokens is tolerated", () ->
                Main.field("{ \"a\" : { \"b\" : \"x\" } }", "a.b").equals(Optional.of("x")));
        return t;
    }
}
