import java.util.Set;

public class Main {
    public static boolean authorised(Set<String> granted, String required, boolean adminBypass) {
        // TODO: an admin scope or admin bypass grants everything; otherwise the
        // granted set must contain the required scope exactly.
        return true;
    }
}
