import java.util.Set;

public class Main {
    public static boolean enabled(String userId, int rolloutPercent, boolean killSwitch, Set<String> allowedUsers) {
        if (killSwitch) {
            return false;
        }
        if (userId == null) {
            return false;
        }
        if (allowedUsers != null && allowedUsers.contains(userId)) {
            return true;
        }
        int bucket = Math.floorMod(userId.hashCode(), 100);
        return bucket < rolloutPercent;
    }
}
