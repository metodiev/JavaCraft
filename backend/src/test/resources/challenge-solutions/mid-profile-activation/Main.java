import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static List<String> activeProfiles(List<String> requiredProperties, Set<String> present,
            String requiredOs, String currentOs) {
        Set<String> defined = new HashSet<>();
        if (present != null) {
            for (String name : present) {
                if (name != null) {
                    defined.add(name);
                }
            }
        }
        TreeSet<String> active = new TreeSet<>();
        if (requiredProperties == null) {
            return new ArrayList<>(active);
        }
        boolean hasOsCondition = requiredOs != null && !requiredOs.trim().isEmpty();
        boolean osMatches = !hasOsCondition
                || (currentOs != null && requiredOs.trim().equalsIgnoreCase(currentOs.trim()));
        for (String descriptor : requiredProperties) {
            if (descriptor == null || descriptor.trim().isEmpty()) {
                continue;
            }
            String[] parts = descriptor.trim().split(":", 2);
            String name = parts[0].trim();
            if (name.isEmpty() || !osMatches) {
                continue;
            }
            String requirements = parts.length > 1 ? parts[1] : "";
            boolean satisfied = true;
            for (String requirement : requirements.split(",", -1)) {
                String property = requirement.trim();
                if (property.isEmpty()) {
                    continue;
                }
                boolean negated = property.startsWith("!");
                String bare = negated ? property.substring(1).trim() : property;
                if (bare.isEmpty()) {
                    continue;
                }
                if (negated == defined.contains(bare)) {
                    satisfied = false;
                    break;
                }
            }
            if (satisfied) {
                active.add(name);
            }
        }
        return new ArrayList<>(active);
    }
}
