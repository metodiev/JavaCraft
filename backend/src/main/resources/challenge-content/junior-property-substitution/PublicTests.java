import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("replaces a known token with its value", () ->
                Main.substitute("v=${version}", Map.of("version", "1.0")).equals("v=1.0"));
        t.put("replaces every occurrence", () ->
                Main.substitute("${a}-${a}", Map.of("a", "1")).equals("1-1"));
        t.put("leaves unknown tokens untouched", () ->
                Main.substitute("v=${missing}", Map.of("version", "1.0")).equals("v=${missing}"));
        t.put("replaces known tokens beside unknown ones", () ->
                Main.substitute("${a}:${b}", Map.of("a", "1")).equals("1:${b}"));
        t.put("leaves an unterminated token untouched", () ->
                Main.substitute("cost of ${10", Map.of("10", "ten")).equals("cost of ${10"));
        t.put("leaves an empty token untouched", () ->
                Main.substitute("${}", Map.of()).equals("${}"));
        t.put("does not rescan substituted values", () ->
                Main.substitute("${a}", Map.of("a", "${b}", "b", "boom")).equals("${b}"));
        t.put("rejects a null template or null properties", () ->
                rejects(null, Map.of()) && rejects("x", null));
        return t;
    }

    private static boolean rejects(String template, Map<String, String> properties) {
        try {
            Main.substitute(template, properties);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
