import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("parses a fully qualified goal", () -> Arrays.equals(
                Main.parseGoal("org.apache.maven.plugins:maven-compiler-plugin:3.13.0:compile"),
                new String[] {"org.apache.maven.plugins", "maven-compiler-plugin", "3.13.0", "compile"}));
        t.put("defaults the version when it is omitted", () -> Arrays.equals(
                Main.parseGoal("org.apache.maven.plugins:maven-surefire-plugin:test"),
                new String[] {"org.apache.maven.plugins", "maven-surefire-plugin", "RELEASE", "test"}));
        t.put("trims every segment", () -> Arrays.equals(
                Main.parseGoal("  org.apache.maven.plugins : maven-jar-plugin : 3.4.1 : jar  "),
                new String[] {"org.apache.maven.plugins", "maven-jar-plugin", "3.4.1", "jar"}));
        t.put("rejects a goal without a group and artifact", () -> rejects("maven-jar-plugin:jar"));
        t.put("rejects too many segments", () -> rejects("g:a:1.0:jar:extra"));
        t.put("rejects an empty segment", () -> rejects("g::1.0:jar"));
        t.put("rejects a trailing colon", () -> rejects("g:a:1.0:"));
        t.put("rejects null and blank goals", () -> rejects(null) && rejects("   "));
        return t;
    }

    private static boolean rejects(String goal) {
        try {
            Main.parseGoal(goal);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
