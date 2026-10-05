import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> metrics(boolean deliveryFocused, boolean reliabilityFocused) {
        List<String> out = new ArrayList<>();
        if (deliveryFocused) {
            out.add("lead time for change");
            out.add("deployment frequency");
        }
        if (reliabilityFocused) {
            out.add("change failure rate");
            out.add("time to restore service");
        }
        return out;
    }
}
