import java.util.List;

public class Main {
    public static String partitionKey(String orderingRequirement, boolean hotKeyRisk, List<String> candidates) {
        boolean orderingRequired = orderingRequirement != null && !orderingRequirement.isBlank();
        if (candidates == null) {
            return null;
        }
        if (orderingRequired) {
            for (String candidate : candidates) {
                if (isOrderingSafe(candidate)) {
                    return candidate;
                }
            }
            return null;
        }
        if (hotKeyRisk) {
            for (String candidate : candidates) {
                if (candidate != null && candidate.equalsIgnoreCase("random")) {
                    return candidate;
                }
            }
        }
        for (String candidate : candidates) {
            if (candidate != null && !candidate.isBlank()) {
                return candidate;
            }
        }
        return null;
    }

    private static boolean isOrderingSafe(String candidate) {
        return candidate != null && !candidate.isBlank() && !candidate.equalsIgnoreCase("random");
    }
}
