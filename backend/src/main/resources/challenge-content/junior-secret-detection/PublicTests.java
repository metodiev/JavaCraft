import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null input has no findings", () -> Main.findings(null).isEmpty());
        t.put("clean code has no findings", () -> Main.findings(
                List.of("int total = 0;", "String name = \"app\";")).isEmpty());
        t.put("assignment is reported with its line number", () -> Main.findings(
                List.of("int total = 0;", "String password = \"dummy\";")).equals(List.of("line 2: password")));
        t.put("colon assignment and key case are handled", () -> Main.findings(
                List.of("API_KEY: abc123")).equals(List.of("line 1: apiKey")));
        t.put("environment values are safe", () -> Main.findings(
                List.of("String token = System.getenv(\"AUTH\");")).isEmpty());
        t.put("empty values and comments are ignored", () -> Main.findings(
                List.of("password =", "// secret = \"dummy\"", "# token: a")).isEmpty());
        t.put("unrelated keys are not matched", () -> Main.findings(
                List.of("int tokenCount = 3;", "String passwordHash = \"y\";")).isEmpty());
        t.put("null lines are skipped", () -> {
            List<String> input = new ArrayList<>();
            input.add(null);
            input.add("secret = \"dummy\"");
            input.add(null);
            return Main.findings(input).equals(List.of("line 2: secret"));
        });
        return t;
    }
}
