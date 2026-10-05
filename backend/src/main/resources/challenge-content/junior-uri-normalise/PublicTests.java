import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("collapses duplicate slashes", () -> Main.normalise("//api///v1//users").equals("/api/v1/users"));
        t.put("removes single dot segments", () -> Main.normalise("/a/./b").equals("/a/b") && Main.normalise("/.").equals("/"));
        t.put("resolves parent segments", () -> Main.normalise("/a/b/../c").equals("/a/c"));
        t.put("parents never escape the root", () -> Main.normalise("/../a").equals("/a")
                && Main.normalise("/a/../../../b").equals("/b"));
        t.put("strips the trailing slash except at the root", () -> Main.normalise("/api/v1/").equals("/api/v1")
                && Main.normalise("/").equals("/") && Main.normalise("/a///").equals("/a"));
        t.put("preserves the query string", () -> Main.normalise("/a/b/?x=1").equals("/a/b?x=1"));
        t.put("preserves a fragment", () -> Main.normalise("/a//./#frag").equals("/a#frag"));
        t.put("adds a leading slash to a relative path", () -> Main.normalise("a/b").equals("/a/b"));
        t.put("blank input is the root path", () -> Main.normalise("   ").equals("/") && Main.normalise(null).equals("/"));
        return t;
    }
}
