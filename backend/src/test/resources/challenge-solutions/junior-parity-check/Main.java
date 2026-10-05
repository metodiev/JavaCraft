import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class Main {
    public static List<String> differences(Map<String, String> local, Map<String, String> deployed) {
        Set<String> keys = new LinkedHashSet<>();
        if (local != null) {
            keys.addAll(local.keySet());
        }
        if (deployed != null) {
            keys.addAll(deployed.keySet());
        }
        List<String> result = new ArrayList<>();
        for (String key : keys) {
            boolean inLocal = local != null && local.containsKey(key);
            boolean inDeployed = deployed != null && deployed.containsKey(key);
            if (!inLocal || !inDeployed) {
                result.add(key);
            } else if (!Objects.equals(local.get(key), deployed.get(key))) {
                result.add(key);
            }
        }
        Collections.sort(result);
        return result;
    }
}
