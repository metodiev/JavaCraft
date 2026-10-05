import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("regulated organisations without a platform team use central review", () ->
                Main.governance(true, 3, false).equals("CENTRAL_REVIEW"));
        t.put("a platform team governs regulated organisations with paved roads", () ->
                Main.governance(true, 12, true).equals("PLATFORM_TEAM"));
        t.put("many unregulated teams federate ownership", () ->
                Main.governance(false, 8, false).equals("FEDERATED"));
        t.put("few unregulated teams use central review", () ->
                Main.governance(false, 3, false).equals("CENTRAL_REVIEW"));
        t.put("the team-count boundary is eight", () ->
                Main.governance(false, 7, false).equals("CENTRAL_REVIEW")
                        && Main.governance(false, 8, false).equals("FEDERATED"));
        t.put("a platform team governs regardless of regulation", () ->
                Main.governance(false, 20, true).equals("PLATFORM_TEAM"));
        t.put("regulation beats a large but unregulated team count", () ->
                Main.governance(true, 20, false).equals("CENTRAL_REVIEW"));
        t.put("every branch returns a documented model", () ->
                new HashSet<>(List.of(
                        Main.governance(true, 1, false),
                        Main.governance(false, 20, false),
                        Main.governance(false, 1, true)))
                        .equals(Set.of("CENTRAL_REVIEW", "FEDERATED", "PLATFORM_TEAM")));
        t.put("a non-positive team count is rejected", () -> {
            try { Main.governance(false, 0, false); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.governance(true, -5, true); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
