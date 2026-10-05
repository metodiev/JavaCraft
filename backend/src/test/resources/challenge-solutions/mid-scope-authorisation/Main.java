import java.util.Set;

public class Main {
    private static final String ADMIN_SCOPE = "admin";

    public static boolean authorised(Set<String> granted, String required, boolean adminBypass) {
        if (adminBypass || (granted != null && granted.contains(ADMIN_SCOPE))) {
            return true;
        }
        if (required == null || required.isBlank() || required.indexOf(' ') >= 0) {
            return false;
        }
        return granted != null && granted.contains(required);
    }
}
