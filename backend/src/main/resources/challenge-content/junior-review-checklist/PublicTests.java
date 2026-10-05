import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("small change keeps the review light", () -> Main.checks(20, true, false).equals(List.of(
                "readability and naming", "tests cover the change")));
        t.put("a change without tests is called out", () -> Main.checks(20, false, false).equals(List.of(
                "readability and naming", "tests cover the change", "add or update tests")));
        t.put("config change gets its own focus", () -> Main.checks(20, true, true).equals(List.of(
                "readability and naming", "tests cover the change", "check configuration and environment impact")));
        t.put("all findings stack in order", () -> Main.checks(500, false, true).equals(List.of(
                "readability and naming", "tests cover the change", "add or update tests",
                "check configuration and environment impact", "split the change or review in small commits")));
        t.put("boundary of 200 lines is still small", () -> Main.checks(200, true, false).size() == 2);
        t.put("201 lines needs splitting", () -> Main.checks(201, true, false).size() == 3);
        t.put("zero or negative line counts are rejected", () -> rejects(0) && rejects(-5));
        return t;
    }

    private static boolean rejects(int changedLines) {
        try {
            Main.checks(changedLines, true, false);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
