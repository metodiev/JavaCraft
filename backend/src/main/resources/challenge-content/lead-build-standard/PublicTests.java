import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a minimal build starts with the baseline practices", () ->
                Main.requiredPractices(false, false).equals(List.of(
                        "reproducible-builds",
                        "locked-dependency-versions")));
        t.put("publishing a library adds the publication practices", () ->
                Main.requiredPractices(true, false).equals(List.of(
                        "reproducible-builds",
                        "locked-dependency-versions",
                        "published-metadata",
                        "signed-artifacts")));
        t.put("a regulated domain adds the audit and provenance practices", () ->
                Main.requiredPractices(false, true).equals(List.of(
                        "reproducible-builds",
                        "locked-dependency-versions",
                        "dependency-audit",
                        "build-provenance")));
        t.put("both flags combine into one ordered list", () ->
                Main.requiredPractices(true, true).equals(List.of(
                        "reproducible-builds",
                        "locked-dependency-versions",
                        "dependency-audit",
                        "build-provenance",
                        "published-metadata",
                        "signed-artifacts")));
        t.put("the baseline always comes first", () -> {
            List<String> published = Main.requiredPractices(true, false);
            List<String> regulated = Main.requiredPractices(false, true);
            return published.get(0).equals("reproducible-builds")
                    && regulated.get(0).equals("reproducible-builds")
                    && published.get(1).equals("locked-dependency-versions")
                    && regulated.get(1).equals("locked-dependency-versions");
        });
        t.put("the optional practices are only added when their flag is set", () ->
                !Main.requiredPractices(false, false).contains("signed-artifacts")
                        && !Main.requiredPractices(false, false).contains("build-provenance")
                        && !Main.requiredPractices(true, false).contains("build-provenance")
                        && !Main.requiredPractices(false, true).contains("signed-artifacts"));
        t.put("no practice is repeated", () -> {
            List<String> combined = Main.requiredPractices(true, true);
            return new LinkedHashSet<>(combined).size() == combined.size()
                    && combined.size() == 6;
        });
        t.put("every result is immutable and stable across calls", () -> {
            List<String> first = Main.requiredPractices(true, true);
            return first.equals(Main.requiredPractices(true, true)) && rejectsMutation(first);
        });
        return t;
    }

    private static boolean rejectsMutation(List<String> practices) {
        try {
            practices.add("extra");
            return false;
        } catch (UnsupportedOperationException expected) {
            return true;
        }
    }
}
