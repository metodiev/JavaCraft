import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

public class Main {
    public static List<String> violations(Map<String, String> rules, Map<String, String> actual) {
        TreeSet<String> report = new TreeSet<>();
        if (rules == null || rules.isEmpty()) {
            return new ArrayList<>(report);
        }
        String banned = rules.get("bannedDependencies");
        if (banned != null) {
            for (String coordinate : split(banned)) {
                for (String dependency : split(actual == null ? null : actual.get("dependencies"))) {
                    if (dependency.equals(coordinate)) {
                        report.add("banned-dependency " + coordinate);
                    }
                }
            }
        }
        String required = rules.get("requireJavaVersion");
        if (required != null) {
            required = required.trim();
            String found = actual == null ? null : actual.get("javaVersion");
            found = found == null || found.trim().isEmpty() ? "unknown" : found.trim();
            if (!required.isEmpty() && !required.equals(found)) {
                report.add("wrong-java-version expected " + required + " but found " + found);
            }
        }
        return new ArrayList<>(report);
    }

    private static List<String> split(String value) {
        List<String> parts = new ArrayList<>();
        if (value != null) {
            for (String part : value.split(",", -1)) {
                if (!part.trim().isEmpty()) {
                    parts.add(part.trim());
                }
            }
        }
        return parts;
    }
}
