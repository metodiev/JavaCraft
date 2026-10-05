import java.util.List;
import java.util.Locale;

public class Main {
    private static final List<String> PRECEDENCE = List.of("DOWN", "OUT_OF_SERVICE", "UP", "UNKNOWN");

    public static String aggregate(List<String> indicatorStatuses) {
        if (indicatorStatuses == null) {
            return "UNKNOWN";
        }
        boolean[] present = new boolean[PRECEDENCE.size()];
        for (String status : indicatorStatuses) {
            if (status == null) {
                continue;
            }
            int index = PRECEDENCE.indexOf(status.trim().toUpperCase(Locale.ROOT));
            if (index >= 0) {
                present[index] = true;
            }
        }
        for (int i = 0; i < PRECEDENCE.size(); i++) {
            if (present[i]) {
                return PRECEDENCE.get(i);
            }
        }
        return "UNKNOWN";
    }
}
