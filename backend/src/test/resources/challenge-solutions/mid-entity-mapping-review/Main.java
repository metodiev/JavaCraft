import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class Main {
    private static final List<String> GENERATED = List.of("IDENTITY", "SEQUENCE", "TABLE");

    public static List<String> problems(Map<String, String> mappings) {
        List<String> found = new ArrayList<>();
        if (mappings == null || !mappings.containsKey("id")) {
            return List.of("Order: missing id");
        }
        for (Map.Entry<String, String> entry : mappings.entrySet()) {
            String property = entry.getKey();
            String mapping = entry.getValue() == null ? "" : entry.getValue();
            if (!property.equals("id") && mapping.contains("EAGER collection")) {
                found.add("Order: collection " + property + " should be LAZY");
            }
        }
        if (GENERATED.contains(mappings.get("id"))) {
            for (Map.Entry<String, String> entry : mappings.entrySet()) {
                if (!entry.getKey().equals("id") && "assigned".equals(entry.getValue())) {
                    found.add("Order: generated id conflicts with assigned id on " + entry.getKey());
                }
            }
        }
        Collections.sort(found);
        return found;
    }
}
