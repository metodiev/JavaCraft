import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("reflection needs reflect-config.json", () ->
                Main.requiredHints(List.of("reflection:com.acme.Order")).equals(List.of("reflect-config.json")));
        t.put("resources need resource-config.json", () ->
                Main.requiredHints(List.of("resource:/files/*.ext")).equals(List.of("resource-config.json")));
        t.put("dynamic proxies need proxy-config.json", () ->
                Main.requiredHints(List.of("proxy:com.acme.OrderRepository")).equals(List.of("proxy-config.json")));
        t.put("every pattern type is deduplicated and ordered", () ->
                Main.requiredHints(List.of("resource:/a", "reflection:com.acme.A", "proxy:com.acme.B", "reflection:com.acme.C"))
                        .equals(List.of("reflect-config.json", "resource-config.json", "proxy-config.json")));
        t.put("member categories do not add a second reflection entry", () ->
                Main.requiredHints(List.of("reflection:com.acme.Order#methods", "reflection:com.acme.Order#fields"))
                        .equals(List.of("reflect-config.json")));
        t.put("prefixes are matched without regard to case or surrounding whitespace", () ->
                Main.requiredHints(List.of("  REFLECTION:com.acme.Order ")).equals(List.of("reflect-config.json")));
        t.put("unrecognized patterns are ignored", () ->
                Main.requiredHints(List.of("serialization:com.acme.Order", "nonsense", "")).isEmpty());
        t.put("null and blank entries are ignored", () ->
                Main.requiredHints(Arrays.asList(null, "   ", "proxy:com.acme.A")).equals(List.of("proxy-config.json")));
        t.put("a null pattern list returns an empty list", () -> Main.requiredHints(null).isEmpty());
        return t;
    }
}
