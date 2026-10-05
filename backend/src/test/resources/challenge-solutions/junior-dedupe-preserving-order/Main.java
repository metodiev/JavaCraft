import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class Main {
    public static List<String> uniqueInOrder(List<String> values) {
        Set<String> seen = new LinkedHashSet<>();
        if (values != null) {
            for (String value : values) {
                if (value != null) {
                    seen.add(value);
                }
            }
        }
        return new ArrayList<>(seen);
    }
}
