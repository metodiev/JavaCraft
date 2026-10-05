import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("strategy for a nine year horizon", () -> Main.sections(9).equals(List.of(
                "context and forces",
                "nine year horizon and outcomes",
                "principles that guide decisions",
                "options and trade-offs",
                "decision and investment",
                "measurement and review cadence")));
        t.put("the horizon is echoed in the second section", () -> Main.sections(3).get(1).equals("three year horizon and outcomes"));
        t.put("two year horizon is supported", () -> Main.sections(2).equals(List.of(
                "context and forces",
                "two year horizon and outcomes",
                "principles that guide decisions",
                "options and trade-offs",
                "decision and investment",
                "measurement and review cadence")));
        t.put("five year horizon is supported", () -> Main.sections(5).get(1).equals("five year horizon and outcomes"));
        t.put("horizons outside two to nine are rejected", () -> rejects(1) && rejects(0) && rejects(10) && rejects(-3));
        t.put("section order is fixed", () -> {
            List<String> out = Main.sections(4);
            return out.size() == 6 && out.get(0).equals("context and forces")
                    && out.get(5).equals("measurement and review cadence")
                    && out.indexOf("principles that guide decisions") == 2;
        });
        return t;
    }

    private static boolean rejects(int horizonYears) {
        try {
            Main.sections(horizonYears);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
