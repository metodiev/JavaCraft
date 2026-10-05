import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a strong run reports no weak category", () ->
                Main.findings(9, 1, 0).equals(List.of("score 90%", "strong"))
                        && Main.findings(5, 0, 0).equals(List.of("score 100%", "strong")));
        t.put("exactly eighty percent still counts as strong", () ->
                Main.findings(8, 2, 0).equals(List.of("score 80%", "strong")));
        t.put("surviving mutants below the pass mark set the weak category", () ->
                Main.findings(7, 3, 0).equals(List.of("score 70%", "weakest: SURVIVED"))
                        && Main.findings(4, 5, 0).equals(List.of("score 44%", "weakest: SURVIVED")));
        t.put("uncovered mutants must outnumber survivors to be the weak category", () ->
                Main.findings(7, 2, 1).equals(List.of("score 70%", "weakest: SURVIVED"))
                        && Main.findings(4, 3, 3).equals(List.of("score 40%", "weakest: SURVIVED")));
        t.put("uncovered mutants are the bigger gap", () ->
                Main.findings(3, 1, 6).equals(List.of("score 30%", "weakest: NO_COVERAGE")));
        t.put("the score rounds half up", () ->
                Main.findings(1, 7, 0).equals(List.of("score 13%", "weakest: SURVIVED"))
                        && Main.findings(3, 5, 0).equals(List.of("score 38%", "weakest: SURVIVED")));
        t.put("a run with nothing to kill scores zero and has no coverage", () ->
                Main.findings(0, 0, 0).equals(List.of("score 0%", "weakest: NO_COVERAGE")));
        t.put("the report is always the score line followed by the category", () -> {
            List<String> report = Main.findings(10, 0, 0);
            return report.size() == 2
                    && report.get(0).equals("score 100%")
                    && report.get(1).equals("strong");
        });
        return t;
    }
}
