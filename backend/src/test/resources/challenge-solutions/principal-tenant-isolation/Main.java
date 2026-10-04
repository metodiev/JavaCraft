public class Main {
    public record Record(String tenantId, String id) {}

    public static boolean mayRead(String principalTenant, Record record) {
        if (principalTenant == null || principalTenant.isBlank() || record == null
                || record.tenantId() == null || record.tenantId().isBlank()) {
            return false;
        }
        return principalTenant.equals(record.tenantId());
    }

    public static boolean mayAdminRead(String principalTenant, Record record, boolean platformAdmin, String auditReason) {
        if (mayRead(principalTenant, record)) {
            return true;
        }
        return platformAdmin && record != null && auditReason != null && !auditReason.isBlank();
    }
}
