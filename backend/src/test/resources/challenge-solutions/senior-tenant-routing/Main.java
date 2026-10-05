import java.util.Map;

public class Main {
    public static String datasourceFor(String tenantId, Map<String, String> tenantTier) {
        if (tenantId == null || tenantId.isBlank()) {
            throw new IllegalArgumentException("tenantId is required");
        }
        String tier = tenantTier == null ? null : tenantTier.get(tenantId);
        if (tier != null && tier.trim().equalsIgnoreCase("REGULATED")) {
            return "isolated:" + tenantId;
        }
        return "pooled";
    }
}
