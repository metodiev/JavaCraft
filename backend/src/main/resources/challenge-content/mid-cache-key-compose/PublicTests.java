import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a single argument key is composed from its parts", () ->
                Main.cacheKey("orders", "acme", List.of("42")).equals("orders:acme:42:"));
        t.put("arguments are joined with the separator", () ->
                Main.cacheKey("orders", "acme", List.of("42", "active")).equals("orders:acme:42:active:"));
        t.put("an empty argument list still produces a key", () ->
                Main.cacheKey("orders", "acme", List.of()).equals("orders:acme:"));
        t.put("the key is scoped by tenant", () -> {
            String a = Main.cacheKey("orders", "acme", List.of("42"));
            String b = Main.cacheKey("orders", "globex", List.of("42"));
            return !a.equals(b) && b.equals("orders:globex:42:");
        });
        t.put("the separator is escaped inside parts", () ->
                Main.cacheKey("orders", "acme", List.of("a:b")).equals("orders:acme:a\\:b:"));
        t.put("escaping prevents ambiguous keys", () -> {
            String single = Main.cacheKey("orders", "acme", List.of("a:b"));
            String pair = Main.cacheKey("orders", "acme", List.of("a", "b"));
            return !single.equals(pair);
        });
        t.put("the backslash is escaped too", () ->
                Main.cacheKey("orders", "acme", List.of("a\\b")).equals("orders:acme:a\\\\b:"));
        t.put("a null argument becomes an empty part", () ->
                Main.cacheKey("orders", "acme", Arrays.asList("42", null)).equals("orders:acme:42::"));
        t.put("a null argument list is treated as empty", () ->
                Main.cacheKey("orders", "acme", null).equals("orders:acme:"));
        return t;
    }
}
