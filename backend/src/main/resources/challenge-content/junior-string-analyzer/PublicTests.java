import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts simple words", () -> Main.wordCount("hello world") == 2);
        t.put("ignores repeated and surrounding whitespace", () -> Main.wordCount("  a   b  ") == 2);
        t.put("tabs and newlines separate words", () -> Main.wordCount("one\ttwo\nthree") == 3);
        t.put("punctuation does not create words", () -> Main.wordCount("Hello, world!") == 2);
        t.put("non-ASCII letters are supported", () -> Main.wordCount("h\u00e9llo w\u00f6rld, ok!") == 3);
        t.put("null is zero", () -> Main.wordCount(null) == 0);
        t.put("blank is zero", () -> Main.wordCount("   ") == 0);
        return t;
    }
}
