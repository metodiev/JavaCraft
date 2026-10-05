import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("small organisation adopts only the baseline controls", () -> Main.controls(false, false, 2).equals(List.of(
                "assign a security owner for every system",
                "require two-person review for production changes",
                "keep an incident response runbook up to date")));
        t.put("regulated data adds classification and encryption", () -> Main.controls(true, false, 1).equals(List.of(
                "assign a security owner for every system",
                "require two-person review for production changes",
                "keep an incident response runbook up to date",
                "classify and retain regulated data under the data policy",
                "encrypt regulated data at rest and in transit")));
        t.put("public api adds authentication and rate limiting", () -> Main.controls(false, true, 1).size() == 4
                && Main.controls(false, true, 1).get(3).equals("authenticate and rate limit every public endpoint"));
        t.put("three teams add access reviews", () -> Main.controls(false, false, 3).size() == 4
                && Main.controls(false, false, 3).get(3).equals("run a quarterly access review")
                && Main.controls(false, false, 2).size() == 3);
        t.put("ten teams add a security function", () -> Main.controls(false, false, 10).size() == 5
                && Main.controls(false, false, 10).get(4).equals("fund a dedicated security engineering function")
                && Main.controls(false, false, 9).size() == 4);
        t.put("all flags return every control in order", () -> Main.controls(true, true, 12).equals(List.of(
                "assign a security owner for every system",
                "require two-person review for production changes",
                "keep an incident response runbook up to date",
                "classify and retain regulated data under the data policy",
                "encrypt regulated data at rest and in transit",
                "authenticate and rate limit every public endpoint",
                "run a quarterly access review",
                "fund a dedicated security engineering function")));
        t.put("negative team counts are rejected", () -> {
            try {
                Main.controls(false, false, -1);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
