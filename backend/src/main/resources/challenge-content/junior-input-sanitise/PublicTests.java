import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null becomes empty", () -> Main.normalise(null).isEmpty());
        t.put("empty stays empty", () -> Main.normalise("").isEmpty());
        t.put("blank becomes empty", () -> Main.normalise("   \t\n ").isEmpty());
        t.put("clean text is unchanged", () -> Main.normalise("hello world").equals("hello world"));
        t.put("ends are trimmed", () -> Main.normalise("  hello  ").equals("hello"));
        t.put("control runs become one space", () -> Main.normalise("a\u0007\u0007b").equals("a b"));
        t.put("mixed whitespace runs collapse", () -> Main.normalise("a \t\n b").equals("a b"));
        t.put("control characters at the edges are removed", () -> Main.normalise("\u0000hello\u0007").equals("hello"));
        t.put("other characters are kept unchanged", () -> Main.normalise("caf\u00e9-au-lait").equals("caf\u00e9-au-lait"));
        return t;
    }
}
