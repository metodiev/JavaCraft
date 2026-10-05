import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class Main {
    private static final List<String> SECTIONS =
            List.of("context", "options", "decision", "consequences", "revisit");

    public static List<String> missingSections(Map<String, String> record) {
        Map<String, String> normalized = new HashMap<>();
        if (record != null) {
            for (Map.Entry<String, String> entry : record.entrySet()) {
                if (entry.getKey() != null) {
                    normalized.put(entry.getKey().trim().toLowerCase(Locale.ROOT), entry.getValue());
                }
            }
        }
        List<String> missing = new ArrayList<>();
        for (String section : SECTIONS) {
            String value = normalized.get(section);
            if (value == null || value.isBlank()) {
                missing.add(section);
            }
        }
        return missing;
    }
}
