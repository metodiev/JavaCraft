import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("running as root is a violation", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", false);
            context.put("runAsUser", 0);
            context.put("privileged", false);
            context.put("readOnlyRootFilesystem", true);
            return Main.violations(context).equals(List.of("runAsNonRoot"));
        });
        t.put("runAsNonRoot false without an explicit user is a violation", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", false);
            context.put("privileged", false);
            context.put("readOnlyRootFilesystem", true);
            return Main.violations(context).equals(List.of("runAsNonRoot"));
        });
        t.put("a positive runAsUser clears the non-root requirement", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", false);
            context.put("runAsUser", 1000);
            context.put("privileged", false);
            context.put("readOnlyRootFilesystem", true);
            return Main.violations(context).isEmpty();
        });
        t.put("privileged mode is a violation", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", true);
            context.put("privileged", true);
            context.put("readOnlyRootFilesystem", true);
            return Main.violations(context).equals(List.of("privileged"));
        });
        t.put("a writable root filesystem is a violation", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", true);
            context.put("privileged", false);
            context.put("readOnlyRootFilesystem", false);
            return Main.violations(context).equals(List.of("readOnlyRootFilesystem"));
        });
        t.put("all three violations are reported in order", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", false);
            context.put("runAsUser", 0);
            context.put("privileged", true);
            context.put("readOnlyRootFilesystem", false);
            return Main.violations(context).equals(List.of("runAsNonRoot", "privileged", "readOnlyRootFilesystem"));
        });
        t.put("a null security context reports all three checks", () ->
                Main.violations(null).equals(List.of("runAsNonRoot", "privileged", "readOnlyRootFilesystem")));
        t.put("a hardened context has no violations", () -> {
            Map<String, Object> context = new LinkedHashMap<>();
            context.put("runAsNonRoot", true);
            context.put("runAsUser", 10001);
            context.put("privileged", false);
            context.put("readOnlyRootFilesystem", true);
            return Main.violations(context).isEmpty();
        });
        return t;
    }
}
