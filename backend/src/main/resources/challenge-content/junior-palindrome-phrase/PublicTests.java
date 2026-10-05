import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("detects a classic palindrome phrase", () -> Main.isPalindrome("A man, a plan, a canal: Panama"));
        t.put("ignores quotes and case", () -> Main.isPalindrome("No 'x' in Nixon"));
        t.put("accepts a long mixed palindrome", () -> Main.isPalindrome("Was it a car or a cat I saw?"));
        t.put("accepts a single letter", () -> Main.isPalindrome("A"));
        t.put("rejects a non-palindrome", () -> !Main.isPalindrome("hello"));
        t.put("ignores digits and spaces", () -> Main.isPalindrome("1 2 2 1"));
        t.put("rejects null", () -> !Main.isPalindrome(null));
        t.put("rejects blank", () -> !Main.isPalindrome("   "));
        return t;
    }
}
