import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the key for the pinned example is stable", () ->
                Main.cacheKey("compileJava", List.of("src/A.java", "src/B.java"), "21").equals("9fbbb931042e9484059970cd9cfa273a8012d945b89bb51b9f104b778bc2702f"));
        t.put("input order does not change the key", () ->
                Main.cacheKey("compileJava", List.of("src/A.java", "src/B.java"), "21")
                        .equals(Main.cacheKey("compileJava", List.of("src/B.java", "src/A.java"), "21")));
        t.put("the same build always produces the same key", () -> {
            String first = Main.cacheKey("processResources", List.of("a.txt"), "21");
            String second = Main.cacheKey("processResources", List.of("a.txt"), "21");
            return first.equals(second) && first.length() == 64;
        });
        t.put("a different task name changes the key", () ->
                !Main.cacheKey("compileJava", List.of("src/A.java"), "21")
                        .equals(Main.cacheKey("compileTestJava", List.of("src/A.java"), "21")));
        t.put("a different JDK version changes the key", () ->
                !Main.cacheKey("compileJava", List.of("src/A.java"), "21")
                        .equals(Main.cacheKey("compileJava", List.of("src/A.java"), "17")));
        t.put("a different input set changes the key", () ->
                !Main.cacheKey("compileJava", List.of("src/A.java"), "21")
                        .equals(Main.cacheKey("compileJava", List.of("src/C.java"), "21")));
        t.put("repeated and blank inputs count once", () ->
                Main.cacheKey("compileJava", Arrays.asList("src/A.java", "src/A.java", "  ", null), "21")
                        .equals(Main.cacheKey("compileJava", List.of("src/A.java"), "21")));
        t.put("a task without inputs gets a 64 character lower-case key", () -> {
            String key = Main.cacheKey("clean", List.of(), "21");
            return key.length() == 64
                    && key.equals(key.toLowerCase(Locale.ROOT))
                    && key.equals(Main.cacheKey("clean", null, "21"));
        });
        t.put("a missing task name or JDK version is rejected", () ->
                rejects(null, List.of("src/A.java"), "21")
                        && rejects("compileJava", List.of("src/A.java"), null)
                        && rejects("  ", List.of("src/A.java"), "21")
                        && rejects("compileJava", List.of("src/A.java"), " "));
        return t;
    }

    private static boolean rejects(String taskName, List<String> inputs, String jdkVersion) {
        try {
            Main.cacheKey(taskName, inputs, jdkVersion);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
