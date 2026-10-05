import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null input has depth zero", () -> Main.nestingDepth(null) == 0);
        t.put("code without if statements has depth zero", () -> Main.nestingDepth(
                List.of("int x = 1;", "return x;")) == 0);
        t.put("a flat if has depth one", () -> Main.nestingDepth(
                List.of("if (x) {", "    return 1;", "}")) == 1);
        t.put("nested if statements are counted", () -> Main.nestingDepth(
                List.of("if (a) {", "    if (b) {", "        return 1;", "    }", "}")) == 2);
        t.put("an else branch does not add depth", () -> Main.nestingDepth(
                List.of("if (a) {", "    work();", "} else {", "    other();", "}")) == 1);
        t.put("an else if chain stays at one level", () -> Main.nestingDepth(
                List.of("if (a) {", "} else if (b) {", "} else {", "}")) == 1);
        t.put("a single line if is counted", () -> Main.nestingDepth(
                List.of("if (x) return 1;")) == 1);
        t.put("blank and null lines are skipped", () -> {
            List<String> lines = new ArrayList<>();
            lines.add("if (a) {");
            lines.add(null);
            lines.add("   ");
            lines.add("  if (b) {");
            lines.add("  }");
            lines.add("}");
            return Main.nestingDepth(lines) == 2;
        });
        t.put("braces close the depth", () -> Main.nestingDepth(
                List.of("if (a) {", "}", "if (b) {", "}")) == 1);
        return t;
    }
}
