import java.util.Map;

public class Main {
    public static String datasourceFor(String tenantId, Map<String, String> tenantTier) {
        // TODO: route regulated tenants to their own datasource
        return "pooled";
    }
}
