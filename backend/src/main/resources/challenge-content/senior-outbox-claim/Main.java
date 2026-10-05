public class Main {
    public static boolean claim(String workerId, String owner, long leaseExpiresAt, long now) {
        // TODO: allow only unowned, expired or self-owned rows
        return owner != null && leaseExpiresAt <= now;
    }
}
