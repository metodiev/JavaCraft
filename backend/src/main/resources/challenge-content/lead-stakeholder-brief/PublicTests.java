import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("outline opens with the decision impact", () -> Main.outline("adopt PostgreSQL").equals(List.of(
                "lead with the impact of adopt PostgreSQL",
                "cost and effort",
                "risks and mitigations",
                "options considered",
                "recommendation and next step")));
        t.put("whitespace around the decision is trimmed", () -> Main.outline("  adopt PostgreSQL  ").get(0)
                .equals("lead with the impact of adopt PostgreSQL"));
        t.put("null decision is rejected", () -> rejects(null));
        t.put("blank decision is rejected", () -> rejects("   "));
        t.put("single word decisions still work", () -> Main.outline("migrate").get(0).equals("lead with the impact of migrate"));
        t.put("order is impact, cost, risk, options, recommendation", () -> {
            List<String> out = Main.outline("x");
            return out.size() == 5 && out.get(1).equals("cost and effort") && out.get(2).equals("risks and mitigations")
                    && out.get(3).equals("options considered") && out.get(4).equals("recommendation and next step");
        });
        return t;
    }

    private static boolean rejects(String decision) {
        try {
            Main.outline(decision);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
