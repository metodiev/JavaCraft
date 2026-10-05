import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("hasRole grants when the ROLE_ authority is present",
                () -> Main.permit("hasRole('ADMIN')", Set.of("ROLE_ADMIN"), null, null));
        t.put("hasRole does not match a bare authority",
                () -> !Main.permit("hasRole('ADMIN')", Set.of("ADMIN"), null, null));
        t.put("hasAuthority matches the authority exactly",
                () -> Main.permit("hasAuthority('orders:read')", Set.of("orders:read"), null, null)
                        && !Main.permit("hasAuthority('orders:read')", Set.of("orders:write"), null, null));
        t.put("isOwner compares the caller with the owner",
                () -> Main.permit("isOwner", null, "u-1", "u-1")
                        && !Main.permit("isOwner", null, "u-1", "u-2"));
        t.put("isOwner is false for null or blank ids", () -> !Main.permit("isOwner", null, "u-1", null)
                && !Main.permit("isOwner", null, "", "")
                && !Main.permit("isOwner", null, null, null));
        t.put("and and or follow their truth tables",
                () -> !Main.permit("isOwner and hasRole('ADMIN')", Set.of("ROLE_ADMIN"), "u-1", "u-2")
                        && Main.permit("isOwner and hasRole('ADMIN')", Set.of("ROLE_ADMIN"), "u-1", "u-1")
                        && Main.permit("isOwner or hasRole('ADMIN')", Set.of("ROLE_ADMIN"), "u-1", "u-2")
                        && Main.permit("isOwner or hasRole('ADMIN')", Set.of("OTHER"), "u-1", "u-1")
                        && !Main.permit("isOwner or hasRole('ADMIN')", Set.of("OTHER"), "u-1", "u-2"));
        t.put("not negates the atom it precedes",
                () -> Main.permit("!hasRole('ADMIN')", Set.of("ROLE_USER"), null, null)
                        && !Main.permit("!hasRole('ADMIN')", Set.of("ROLE_ADMIN"), null, null));
        t.put("and binds tighter than or", () -> Main.permit(
                "hasRole('A') or hasRole('B') and hasRole('C')", Set.of("ROLE_A"), null, null)
                && !Main.permit("(hasRole('A') or hasRole('B')) and hasRole('C')", Set.of("ROLE_A"), null, null));
        t.put("an unknown or malformed expression is denied", () -> !Main.permit("hasPermission('x')", Set.of("x"), null, null)
                && !Main.permit("", Set.of("x"), null, null)
                && !Main.permit(null, Set.of("x"), null, null)
                && !Main.permit("hasRole('A'", Set.of("ROLE_A"), null, null));
        return t;
    }
}
