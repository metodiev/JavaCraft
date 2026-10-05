import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("everyone gets the baseline path", () -> Main.firstWeek(true, false).equals(List.of(
                "set up the development environment",
                "run the build and the test suite",
                "ship a small change to production",
                "meet the team and agree on a buddy")));
        t.put("java newcomers add the language ramp up", () -> Main.firstWeek(false, false).equals(List.of(
                "set up the development environment",
                "run the build and the test suite",
                "work through the Java and framework learning path",
                "ship a small change to production",
                "meet the team and agree on a buddy")));
        t.put("production access adds the walkthrough", () -> Main.firstWeek(true, true).equals(List.of(
                "set up the development environment",
                "run the build and the test suite",
                "ship a small change to production",
                "walk through the production runbooks and on-call basics",
                "meet the team and agree on a buddy")));
        t.put("both conditions add both steps", () -> Main.firstWeek(false, true).equals(List.of(
                "set up the development environment",
                "run the build and the test suite",
                "work through the Java and framework learning path",
                "ship a small change to production",
                "walk through the production runbooks and on-call basics",
                "meet the team and agree on a buddy")));
        t.put("order is stable regardless of flags", () -> Main.firstWeek(false, true).indexOf("work through the Java and framework learning path")
                < Main.firstWeek(false, true).indexOf("walk through the production runbooks and on-call basics"));
        return t;
    }
}
