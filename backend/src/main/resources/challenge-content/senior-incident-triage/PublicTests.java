import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a recent change is checked right after confirming impact",
                () -> Main.triageOrder(true, true, true, true).equals(List.of(
                        "confirm-user-impact", "check-recent-changes", "inspect-errors",
                        "inspect-latency", "inspect-saturation", "form-hypothesis")));
        t.put("errors alone give a minimal ordered loop",
                () -> Main.triageOrder(false, true, false, false).equals(List.of(
                        "confirm-user-impact", "inspect-errors", "form-hypothesis")));
        t.put("latency and saturation keep the documented signal order",
                () -> Main.triageOrder(false, false, true, true).equals(List.of(
                        "confirm-user-impact", "inspect-latency", "inspect-saturation", "form-hypothesis")));
        t.put("with no signal the investigation widens scope",
                () -> Main.triageOrder(false, false, false, false).equals(List.of(
                        "confirm-user-impact", "widen-scope", "form-hypothesis")));
        t.put("a recent change with no signal still widens scope",
                () -> Main.triageOrder(true, false, false, false).equals(List.of(
                        "confirm-user-impact", "check-recent-changes", "widen-scope", "form-hypothesis")));
        t.put("the symptom step always comes first",
                () -> Main.triageOrder(false, false, false, true).get(0).equals("confirm-user-impact")
                        && Main.triageOrder(true, false, false, true).get(0).equals("confirm-user-impact"));
        t.put("the hypothesis step always comes last", () -> {
            List<String> order = Main.triageOrder(true, true, false, true);
            return order.get(order.size() - 1).equals("form-hypothesis");
        });
        return t;
    }
}
