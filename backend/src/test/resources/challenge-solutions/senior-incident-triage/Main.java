import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> triageOrder(boolean recentChange, boolean errorSpike,
                                           boolean latencySpike, boolean saturation) {
        List<String> order = new ArrayList<>();
        order.add("confirm-user-impact");
        if (recentChange) {
            order.add("check-recent-changes");
        }
        if (errorSpike) {
            order.add("inspect-errors");
        }
        if (latencySpike) {
            order.add("inspect-latency");
        }
        if (saturation) {
            order.add("inspect-saturation");
        }
        if (!errorSpike && !latencySpike && !saturation) {
            order.add("widen-scope");
        }
        order.add("form-hypothesis");
        return order;
    }
}
