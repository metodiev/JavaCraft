import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an api usage in a published library uses api", () ->
                Main.configurationFor("api", true).equals("api"));
        t.put("an api usage in an unpublished module falls back to implementation", () ->
                Main.configurationFor("api", false).equals("implementation"));
        t.put("an internal usage uses implementation", () ->
                Main.configurationFor("internal", true).equals("implementation")
                        && Main.configurationFor("internal", false).equals("implementation"));
        t.put("a runtime usage uses runtimeOnly", () ->
                Main.configurationFor("runtime", true).equals("runtimeOnly")
                        && Main.configurationFor("runtime", false).equals("runtimeOnly"));
        t.put("a test usage uses testImplementation", () ->
                Main.configurationFor("test", true).equals("testImplementation")
                        && Main.configurationFor("test", false).equals("testImplementation"));
        t.put("unknown usages are rejected", () ->
                rejects("compile") && rejects("") && rejects("API") && rejects("api ")
                        && rejects(null));
        t.put("configuration names are not usage tokens", () ->
                rejects("implementation") && rejects("runtimeOnly") && rejects("testImplementation"));
        return t;
    }

    private static boolean rejects(String usage) {
        try {
            Main.configurationFor(usage, true);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
