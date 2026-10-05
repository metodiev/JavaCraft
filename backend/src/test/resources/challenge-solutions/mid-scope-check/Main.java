import java.util.List;
import java.util.Set;

public class Main {
    public static boolean permits(Set<String> granted, List<String> required, boolean requireAll) {
        if (required == null || required.isEmpty()) {
            return true;
        }
        if (granted == null || granted.isEmpty()) {
            return false;
        }
        if (requireAll) {
            return granted.containsAll(required);
        }
        for (String scope : required) {
            if (granted.contains(scope)) {
                return true;
            }
        }
        return false;
    }
}
