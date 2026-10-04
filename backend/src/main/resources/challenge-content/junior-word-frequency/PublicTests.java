import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts repeated words", () -> Main.countWords("the cat the dog")
                .equals(Map.of("the", 2, "cat", 1, "dog", 1)));
        t.put("ignores letter case", () -> Main.countWords("Hello hello HELLO").equals(Map.of("hello", 3)));
        t.put("punctuation separates words", () -> Main.countWords("a, b. a! b? c")
                .equals(Map.of("a", 2, "b", 2, "c", 1)));
        t.put("digits are part of words", () -> Main.countWords("route66 route66").equals(Map.of("route66", 2)));
        t.put("null input returns an empty map", () -> Main.countWords(null).isEmpty());
        t.put("blank input returns an empty map", () -> Main.countWords("  \t ").isEmpty());
        return t;
    }
}
