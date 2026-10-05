import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class Main {
    public static List<String> drift(Map<String, String> desired, Map<String, String> actual) {
        Set<String> keys = new LinkedHashSet<>();
        if (desired != null) {
            keys.addAll(desired.keySet());
        }
        if (actual != null) {
            keys.addAll(actual.keySet());
        }
        List<String> result = new ArrayList<>();
        for (String key : keys) {
            if (key == null) {
                continue;
            }
            boolean inDesired = desired != null && desired.containsKey(key);
            boolean inActual = actual != null && actual.containsKey(key);
            if (inDesired && !inActual) {
                result.add("removed " + key);
            } else if (!inDesired && inActual) {
                result.add("added " + key);
            } else if (!Objects.equals(desired.get(key), actual.get(key))) {
                result.add("changed " + key);
            }
        }
        Collections.sort(result);
        return result;
    }
}
