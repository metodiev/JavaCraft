import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> compensationOrder(List<String> completedSteps) {
        List<String> compensations = new ArrayList<>();
        if (completedSteps == null) {
            return compensations;
        }
        for (int i = completedSteps.size() - 1; i >= 0; i--) {
            String step = completedSteps.get(i);
            if (step == null || step.isBlank() || step.toLowerCase().startsWith("query:")) {
                continue;
            }
            compensations.add(step);
        }
        return compensations;
    }
}
