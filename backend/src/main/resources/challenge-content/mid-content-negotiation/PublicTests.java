import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("picks an exactly accepted type", () -> "text/html"
                .equals(Main.negotiate("text/html", List.of("application/json", "text/html"))));
        t.put("picks the highest quality match", () -> "text/html"
                .equals(Main.negotiate("text/html;q=0.9, application/json;q=0.8", List.of("application/json", "text/html"))));
        t.put("a wildcard matches every supported type", () -> "application/json"
                .equals(Main.negotiate("*/*", List.of("application/json", "text/html"))));
        t.put("a subtype wildcard matches the text family", () -> "text/html"
                .equals(Main.negotiate("text/*", List.of("application/json", "text/html"))));
        t.put("q zero removes a type from consideration", () -> "text/html"
                .equals(Main.negotiate("application/json;q=0, text/html", List.of("application/json", "text/html"))));
        t.put("an absent header falls back to the first supported type", () -> "application/json"
                .equals(Main.negotiate(null, List.of("application/json", "text/html")))
                && "application/json".equals(Main.negotiate("   ", List.of("application/json", "text/html"))));
        t.put("an unmatched header falls back to the first supported type", () -> "application/json"
                .equals(Main.negotiate("image/png", List.of("application/json", "text/html"))));
        t.put("matching is case-insensitive and ignores parameters", () -> "application/json"
                .equals(Main.negotiate(" Application/JSON ; charset=utf-8 ", List.of("application/json"))));
        t.put("an empty supported list is rejected", () -> {
            try {
                Main.negotiate("application/json", List.of());
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
