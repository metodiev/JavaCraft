import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the shortest path wins", () -> Main.resolve(List.of(
                "com.example:app:1.0 -> com.example:lib:1.2",
                "com.example:app:1.0 -> com.example:dep:2.0 -> com.example:lib:1.3")).equals("1.2"));
        t.put("a direct declaration beats a transitive one", () -> Main.resolve(List.of(
                "com.example:app:1.0 -> com.example:dep:2.0 -> com.example:lib:1.3",
                "com.example:lib:1.2")).equals("1.2"));
        t.put("ties are broken by declaration order", () -> Main.resolve(List.of(
                "com.example:app:1.0 -> com.example:lib:1.9",
                "com.example:app:1.0 -> com.example:lib:1.8")).equals("1.9"));
        t.put("a single path returns its version", () -> Main.resolve(List.of("g:a:4.2")).equals("4.2"));
        t.put("surrounding whitespace is ignored", () -> Main.resolve(List.of(
                "  com.example:app:1.0   ->   com.example:lib:2.0  ")).equals("2.0"));
        t.put("an empty or null list yields an empty version", () ->
                Main.resolve(List.of()).isEmpty() && Main.resolve(null).isEmpty());
        t.put("a malformed path is rejected", () ->
                rejects(List.of("garbage")) && rejects(List.of("g:a")) && rejects(List.of("  ")));
        return t;
    }

    private static boolean rejects(List<String> paths) {
        try {
            Main.resolve(paths);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
