import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("joins a base and segments", () -> Main.path("/api/v1", List.of("users", "42")).equals("/api/v1/users/42"));
        t.put("collapses duplicate and edge slashes", () -> Main.path("/api/", List.of("/users/", "42")).equals("/api/users/42"));
        t.put("encodes spaces in a segment", () -> Main.path("", List.of("hello world")).equals("/hello%20world"));
        t.put("ignores blank and null segments", () -> Main.path("/api", Arrays.asList("", " ", null, "/")).equals("/api"));
        t.put("null inputs still produce the root path", () -> Main.path(null, null).equals("/"));
        t.put("an empty base with segments has one leading slash", () -> Main.path("/", List.of("health")).equals("/health"));
        t.put("no base and no segments is the root path", () -> Main.path("", List.of()).equals("/"));
        return t;
    }
}
