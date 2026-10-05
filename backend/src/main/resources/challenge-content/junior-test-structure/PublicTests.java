import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("given lines are setup", () ->
                Main.phases(List.of("given an empty cart")).equals(List.of("SETUP")));
        t.put("when lines are the exercise", () ->
                Main.phases(List.of("when total is requested")).equals(List.of("EXERCISE")));
        t.put("assert lines are verification", () ->
                Main.phases(List.of("assert total is zero")).equals(List.of("VERIFY")));
        t.put("a full test keeps one label per line", () -> Main.phases(List.of(
                "given an empty cart", "when total is requested", "assert total is zero", "// note"))
                .equals(List.of("SETUP", "EXERCISE", "VERIFY", "NOISE")));
        t.put("blank lines and comments are noise", () ->
                Main.phases(List.of("", "   ", "// note", "print debug"))
                        .equals(List.of("NOISE", "NOISE", "NOISE", "NOISE")));
        t.put("null input returns an empty list", () -> Main.phases(null).isEmpty());
        t.put("matching ignores case and leading whitespace", () -> Main.phases(List.of(
                "  PREPARE fixture", "CALL checkout", "then receipt is issued"))
                .equals(List.of("SETUP", "EXERCISE", "VERIFY")));
        t.put("an unrecognised line is noise", () ->
                Main.phases(List.of("squash the bug")).equals(List.of("NOISE")));
        return t;
    }
}
