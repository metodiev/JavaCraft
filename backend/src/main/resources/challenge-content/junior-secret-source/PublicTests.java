import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("production reads secrets from a managed store", () ->
                "MANAGED_SECRET_STORE".equals(Main.sourceFor(true, false, false)));
        t.put("production short-lived credentials still come from the store", () ->
                "MANAGED_SECRET_STORE".equals(Main.sourceFor(true, false, true)));
        t.put("a short-lived credential uses workload identity", () ->
                "WORKLOAD_IDENTITY".equals(Main.sourceFor(false, false, true)));
        t.put("local development uses environment variables", () ->
                "ENVIRONMENT_VARIABLES".equals(Main.sourceFor(false, true, false)));
        t.put("local development wins over short-lived handling", () ->
                "ENVIRONMENT_VARIABLES".equals(Main.sourceFor(false, true, true)));
        t.put("plain non-production deployment uses mounted files", () ->
                "MOUNTED_FILES".equals(Main.sourceFor(false, false, false)));
        t.put("source control is never returned", () -> {
            for (boolean production : new boolean[] {true, false}) {
                for (boolean local : new boolean[] {true, false}) {
                    for (boolean shortLived : new boolean[] {true, false}) {
                        if ("SOURCE_CONTROL".equals(Main.sourceFor(production, local, shortLived))) {
                            return false;
                        }
                    }
                }
            }
            return true;
        });
        t.put("every combination returns a documented source", () -> {
            List<String> known = List.of("MANAGED_SECRET_STORE", "WORKLOAD_IDENTITY",
                    "ENVIRONMENT_VARIABLES", "MOUNTED_FILES");
            for (boolean production : new boolean[] {true, false}) {
                for (boolean local : new boolean[] {true, false}) {
                    for (boolean shortLived : new boolean[] {true, false}) {
                        if (!known.contains(Main.sourceFor(production, local, shortLived))) {
                            return false;
                        }
                    }
                }
            }
            return true;
        });
        return t;
    }
}
