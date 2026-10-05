import java.util.Set;

public class Main {
    public static boolean enabled(String userId, int rolloutPercent, boolean killSwitch, Set<String> allowedUsers) {
        // TODO: kill switch first, then the allowlist, then the stable hash bucket
        return false;
    }
}
