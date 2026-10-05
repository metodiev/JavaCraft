import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        Map<String, String> rules = new LinkedHashMap<>();
        rules.put("bannedDependencies", "com.example:legacy");
        rules.put("requireJavaVersion", "21");

        t.put("a present banned dependency is reported", () -> {
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("dependencies", "com.example:legacy");
            actual.put("javaVersion", "21");
            return Main.violations(rules, actual).equals(List.of("banned-dependency com.example:legacy"));
        });
        t.put("an absent banned dependency is not reported", () -> {
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("dependencies", "org.slf4j:slf4j-api");
            actual.put("javaVersion", "21");
            return Main.violations(rules, actual).isEmpty();
        });
        t.put("every banned coordinate is checked", () -> {
            Map<String, String> wide = new LinkedHashMap<>();
            wide.put("bannedDependencies", "log4j:log4j, com.example:legacy ,");
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("dependencies", "log4j:log4j,org.slf4j:slf4j-api");
            return Main.violations(wide, actual)
                    .equals(List.of("banned-dependency log4j:log4j"));
        });
        t.put("a matching Java version is not reported", () -> {
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("javaVersion", "21");
            return Main.violations(rules, actual).isEmpty();
        });
        t.put("a mismatched Java version is reported", () -> {
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("javaVersion", "17");
            return Main.violations(rules, actual)
                    .equals(List.of("wrong-java-version expected 21 but found 17"));
        });
        t.put("an unreported Java version is treated as unknown", () -> {
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("dependencies", "org.slf4j:slf4j-api");
            return Main.violations(rules, actual)
                    .equals(List.of("wrong-java-version expected 21 but found unknown"));
        });
        t.put("both kinds of violation are reported together and sorted", () -> {
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("dependencies", "com.example:legacy");
            actual.put("javaVersion", "17");
            return Main.violations(rules, actual).equals(List.of(
                    "banned-dependency com.example:legacy",
                    "wrong-java-version expected 21 but found 17"));
        });
        t.put("duplicate coordinates are reported once", () -> {
            Map<String, String> duplicate = new LinkedHashMap<>();
            duplicate.put("bannedDependencies", "com.example:legacy,com.example:legacy");
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("dependencies", "com.example:legacy,com.example:legacy");
            return Main.violations(duplicate, actual).equals(List.of("banned-dependency com.example:legacy"));
        });
        t.put("a missing rules map yields an empty report and a build that reports nothing is a failure", () ->
                Main.violations(null, Map.of()).isEmpty()
                        && Main.violations(Map.of(), Map.of()).isEmpty()
                        && Main.violations(rules, null)
                                .equals(List.of("wrong-java-version expected 21 but found unknown"))
                        && Main.violations(rules, Map.of())
                                .equals(List.of("wrong-java-version expected 21 but found unknown")));
        return t;
    }
}
