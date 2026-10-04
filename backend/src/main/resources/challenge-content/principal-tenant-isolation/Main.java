public class Main {
    public record Record(String tenantId, String id) {}

    public static boolean mayRead(String principalTenant, Record record) {
        // TODO: tenant isolation, fail closed
        return true;
    }

    public static boolean mayAdminRead(String principalTenant, Record record, boolean platformAdmin, String auditReason) {
        // TODO: cross-tenant access needs an admin and an audit reason
        return true;
    }
}
