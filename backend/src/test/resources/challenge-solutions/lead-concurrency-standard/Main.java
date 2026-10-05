import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> mandatoryControls(boolean publicApi, boolean sharedPool, boolean hasTimeouts) {
        List<String> controls = new ArrayList<>();
        if (!hasTimeouts) {
            controls.add("timeouts");
        }
        controls.add("bounded-queues");
        if (sharedPool) {
            controls.add("bulkheads");
        }
        if (publicApi) {
            controls.add("rate-limiting");
        }
        return controls;
    }
}
