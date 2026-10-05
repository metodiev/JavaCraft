import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a zero rollout keeps traffic on legacy", () ->
                Main.target(0, "user-93", true).equals("LEGACY")
                        && Main.target(0, "user-1", true).equals("LEGACY"));
        t.put("a full rollout moves all traffic to the new implementation", () ->
                Main.target(100, "user-1", true).equals("NEW")
                        && Main.target(100, "user-93", true).equals("NEW"));
        t.put("routing is sticky per user", () ->
                Main.target(50, "user-1", true).equals("LEGACY")
                        && Main.target(50, "user-1", true).equals(Main.target(50, "user-1", true))
                        && Main.target(50, "bob", true).equals("NEW"));
        t.put("a user whose bucket equals the rollout stays on legacy", () ->
                Main.target(17, "bob", true).equals("LEGACY") && Main.target(18, "bob", true).equals("NEW"));
        t.put("an unhealthy legacy target fails over to new", () ->
                Main.target(0, "user-1", false).equals("NEW")
                        && Main.target(0, "user-93", false).equals("NEW"));
        t.put("bucket zero moves first", () ->
                Main.target(0, "user-93", true).equals("LEGACY") && Main.target(1, "user-93", true).equals("NEW"));
        t.put("invalid rollout percentages or users are rejected", () -> {
            try { Main.target(-1, "user-1", true); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.target(101, "user-1", true); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.target(50, null, true); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.target(50, "   ", true); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
