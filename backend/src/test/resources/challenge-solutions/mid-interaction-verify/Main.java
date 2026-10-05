import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> verifyPlan(boolean sendCalled, int sendCount, boolean idempotencyRequired) {
        List<String> plan = new ArrayList<>();
        if (sendCalled && sendCount == 1) {
            plan.add("verify once with expected argument");
        } else if (sendCalled && sendCount > 1) {
            plan.add("verify times(" + sendCount + ")");
        }
        if (idempotencyRequired) {
            plan.add("verify payload is unchanged");
        }
        return plan;
    }
}
