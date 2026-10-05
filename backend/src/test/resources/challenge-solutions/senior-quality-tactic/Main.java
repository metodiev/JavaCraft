import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> tactics(String attribute, boolean latencyCritical) {
        String name = attribute == null ? "" : attribute.trim().toLowerCase(Locale.ROOT);
        return switch (name) {
            case "availability" -> latencyCritical
                    ? List.of("heartbeat-monitor", "active-redundancy", "graceful-degradation")
                    : List.of("heartbeat-monitor", "passive-redundancy", "graceful-degradation");
            case "performance" -> latencyCritical
                    ? List.of("resource-pooling", "introduce-concurrency", "prioritise-requests")
                    : List.of("resource-pooling", "prioritise-requests");
            case "modifiability" -> List.of("reduce-coupling", "increase-cohesion", "defer-binding", "use-an-intermediary");
            case "security" -> List.of("authenticate-requests", "authorise-requests", "encrypt-sensitive-data", "audit-access");
            default -> throw new IllegalArgumentException("unknown quality attribute: " + attribute);
        };
    }
}
