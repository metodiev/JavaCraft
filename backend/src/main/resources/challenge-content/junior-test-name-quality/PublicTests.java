import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a condition and an expectation need no problems", () ->
                Main.problems("returnsEmptyListWhenInputIsBlank").isEmpty());
        t.put("a vague name reports both problems", () ->
                Main.problems("test1").equals(List.of("missing-condition", "missing-expectation")));
        t.put("a condition without an expectation misses the expectation", () ->
                Main.problems("when input is blank").equals(List.of("missing-expectation")));
        t.put("an expectation without a condition misses the condition", () ->
                Main.problems("should reject blank input").equals(List.of("missing-condition")));
        t.put("null and blank names report both problems", () ->
                Main.problems(null).equals(List.of("missing-condition", "missing-expectation"))
                        && Main.problems("   ").equals(List.of("missing-condition", "missing-expectation")));
        t.put("given and then wording needs no problems", () ->
                Main.problems("givenAnEmptyCart thenTotalIsZero").isEmpty());
        t.put("camel case words are split before matching", () ->
                Main.problems("thenTotalIsZeroIfCartIsEmpty").isEmpty());
        return t;
    }
}
