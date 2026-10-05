import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts the vowels of a lowercase word", () -> Main.countVowels("hello") == 2);
        t.put("counts repeated and adjacent vowels", () -> Main.countVowels("queue") == 4);
        t.put("counts uppercase vowels", () -> Main.countVowels("AEIOU") == 5);
        t.put("mixes upper and lower case", () -> Main.countVowels("JavaCraft") == 3);
        t.put("treats y as a consonant", () -> Main.countVowels("rhythm") == 0);
        t.put("ignores digits and punctuation", () -> Main.countVowels("h3ll0, w0rld!") == 0);
        t.put("returns zero for null", () -> Main.countVowels(null) == 0);
        t.put("returns zero for blank", () -> Main.countVowels("   ") == 0);
        return t;
    }
}
