import java.util.ArrayList;
import java.util.List;

public class Main {
    public static String joinNonBlank(List<String> parts, String separator) {
        List<String> kept = new ArrayList<>();
        if (parts != null) {
            for (String part : parts) {
                if (part != null && !part.isBlank()) {
                    kept.add(part.trim());
                }
            }
        }
        return String.join(separator, kept);
    }
}
