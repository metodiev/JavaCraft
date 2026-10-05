import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("allocation under budget is accepted", () -> Main.withinBudget(80, 100, 0.0)
                && Main.withinBudget(100, 100, 0.0));
        t.put("exactly at the budget is accepted", () -> Main.withinBudget(100, 100, 0.0));
        t.put("tolerance allows a small overshoot", () -> Main.withinBudget(105, 100, 0.1)
                && Main.withinBudget(110, 100, 0.1));
        t.put("overshoot beyond tolerance is rejected", () -> !Main.withinBudget(111, 100, 0.1)
                && !Main.withinBudget(101, 100, 0.0));
        t.put("tolerance of one doubles the budget", () -> Main.withinBudget(200, 100, 1.0)
                && !Main.withinBudget(201, 100, 1.0));
        t.put("negative input is rejected", () -> !Main.withinBudget(-1, 100, 0.5)
                && !Main.withinBudget(50, -100, 0.5)
                && !Main.withinBudget(50, 100, -0.1));
        t.put("zero allocation is always within a positive budget", () -> Main.withinBudget(0, 100, 0.0));
        t.put("zero budget allows only its tolerance", () -> !Main.withinBudget(1, 0, 0.0)
                && Main.withinBudget(0, 0, 0.0));
        return t;
    }
}
