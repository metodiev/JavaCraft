import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    private static final String BASE = "com.acme.";

    public static List<String> violations(Map<String, List<String>> dependencies) {
        if (dependencies == null) {
            return List.of();
        }
        Set<String> known = new HashSet<>();
        for (String module : dependencies.keySet()) {
            if (module != null) {
                known.add(module);
            }
        }
        TreeSet<String> violations = new TreeSet<>();
        for (Map.Entry<String, List<String>> entry : dependencies.entrySet()) {
            String source = entry.getKey();
            if (source == null || entry.getValue() == null) {
                continue;
            }
            for (String target : entry.getValue()) {
                if (target == null || target.isBlank() || !target.startsWith(BASE)) {
                    continue;
                }
                String[] segments = target.substring(BASE.length()).split("\\.");
                String module = segments[0];
                if (module.isEmpty() || module.equals(source) || !known.contains(module)) {
                    continue;
                }
                if (segments.length < 2) {
                    continue;
                }
                String subpackage = segments[1];
                if (Character.isUpperCase(subpackage.charAt(0))) {
                    continue;
                }
                if (!"api".equals(subpackage)) {
                    violations.add(source + " -> " + target);
                }
            }
        }
        return new ArrayList<>(violations);
    }
}
