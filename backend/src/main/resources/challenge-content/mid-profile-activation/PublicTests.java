import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an active profile is named in the result", () ->
                Main.activeProfiles(List.of("release"), Set.of(), null, null).equals(List.of("release")));
        t.put("all required properties must be present", () ->
                Main.activeProfiles(List.of("deploy:env"), Set.of("env"), null, null).equals(List.of("deploy"))
                        && Main.activeProfiles(List.of("deploy:env"), Set.of("other"), null, null).isEmpty());
        t.put("several required properties are checked together", () ->
                Main.activeProfiles(List.of("ci:env,debug"), Set.of("env", "debug"), null, null)
                        .equals(List.of("ci"))
                        && Main.activeProfiles(List.of("ci:env,debug"), Set.of("env"), null, null).isEmpty());
        t.put("a required property can be negated with a leading bang", () ->
                Main.activeProfiles(List.of("quiet:!verbose"), Set.of(), null, null).equals(List.of("quiet"))
                        && Main.activeProfiles(List.of("quiet:!verbose"), Set.of("verbose"), null, null).isEmpty());
        t.put("the OS must match when one is required", () ->
                Main.activeProfiles(List.of("win:prod"), Set.of("prod"), "windows", "windows").equals(List.of("win"))
                        && Main.activeProfiles(List.of("win:prod"), Set.of("prod"), "windows", "linux").isEmpty());
        t.put("an empty required OS matches any current OS", () ->
                Main.activeProfiles(List.of("any:prod"), Set.of("prod"), "", "mac os x").equals(List.of("any"))
                        && Main.activeProfiles(List.of("any:prod"), Set.of("prod"), null, null).equals(List.of("any")));
        t.put("active profile names are sorted", () ->
                Main.activeProfiles(List.of("zeta", "alpha", "mid"), Set.of(), null, null)
                        .equals(List.of("alpha", "mid", "zeta")));
        t.put("a profile requiring a missing property stays inactive, and malformed input contributes nothing", () ->
                Main.activeProfiles(List.of("ci:env", "dev:env"), Set.of(), null, null).isEmpty()
                        && Main.activeProfiles(null, null, null, null).isEmpty()
                        && Main.activeProfiles(List.of("  ", ""), Set.of("x"), null, null).isEmpty());
        return t;
    }
}
