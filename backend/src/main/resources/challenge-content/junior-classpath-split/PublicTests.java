import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("unix classpath splits on colon", () -> Main.classpathEntries("/a/b:/c/d", false)
                .equals(List.of("/a/b", "/c/d")));
        t.put("windows classpath splits on semicolon", () -> Main.classpathEntries("C:\\a;C:\\b", true)
                .equals(List.of("C:\\a", "C:\\b")));
        t.put("the other separator is kept inside entries", () -> {
            List<String> entries = Main.classpathEntries("a:1;b:2", true);
            return entries.equals(List.of("a:1", "b:2"));
        });
        t.put("trailing separator is dropped", () -> Main.classpathEntries("/a/b:", false).equals(List.of("/a/b")));
        t.put("empty entries are dropped", () -> Main.classpathEntries("/a::/b", false).equals(List.of("/a", "/b")));
        t.put("null and empty paths give an empty list", () -> Main.classpathEntries(null, false).isEmpty()
                && Main.classpathEntries("", true).isEmpty()
                && Main.classpathEntries(":::", false).isEmpty());
        t.put("a single entry has no separator", () -> Main.classpathEntries("/only", false).equals(List.of("/only")));
        return t;
    }
}
