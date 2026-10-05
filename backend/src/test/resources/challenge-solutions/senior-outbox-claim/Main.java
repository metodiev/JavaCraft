public class Main {
    public static boolean claim(String workerId, String owner, long leaseExpiresAt, long now) {
        if (workerId == null || workerId.isBlank()) {
            return false;
        }
        if (owner == null) {
            return true;
        }
        if (owner.equals(workerId)) {
            return true;
        }
        return leaseExpiresAt <= now;
    }
}
