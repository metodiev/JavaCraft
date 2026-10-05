import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("junior to mid builds independence", () -> Main.actions("junior", "mid").equals(List.of(
                "deliver small features end to end with review",
                "write tests first and grow debugging confidence",
                "ask for feedback early and often")));
        t.put("mid to senior builds system judgement", () -> Main.actions("mid", "senior").equals(List.of(
                "lead a system change across services",
                "design for reliability, cost and operability",
                "mentor a junior engineer through a full feature")));
        t.put("senior to staff builds leverage", () -> Main.actions("senior", "staff").equals(List.of(
                "own a technical direction across teams",
                "write the design that others implement",
                "multiply the team through review and mentoring")));
        t.put("levels are matched case insensitively and trimmed", () -> Main.actions(" Junior ", "MID").equals(List.of(
                "deliver small features end to end with review",
                "write tests first and grow debugging confidence",
                "ask for feedback early and often")));
        t.put("unknown level pairs are rejected", () -> rejects("junior", "staff") && rejects("mid", "mid") && rejects("principal", "staff"));
        t.put("null levels are rejected", () -> rejects(null, "senior") && rejects("mid", null));
        return t;
    }

    private static boolean rejects(String current, String target) {
        try {
            Main.actions(current, target);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
