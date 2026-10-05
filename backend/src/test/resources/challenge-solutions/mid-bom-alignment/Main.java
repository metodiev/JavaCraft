import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TreeSet;

public class Main {
    public static List<String> misaligned(Map<String, String> declared, Map<String, String> bom) {
        TreeSet<String> result = new TreeSet<>();
        if (declared != null && bom != null) {
            for (Map.Entry<String, String> entry : declared.entrySet()) {
                if (bom.containsKey(entry.getKey())
                        && !Objects.equals(entry.getValue(), bom.get(entry.getKey()))) {
                    result.add(entry.getKey());
                }
            }
        }
        return new ArrayList<>(result);
    }
}
