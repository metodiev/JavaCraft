import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an exact supported version is chosen", () ->
                Main.handler("2.0", List.of("1.0", "2.0", "3.0"), "1.0").equals("2.0"));
        t.put("the highest version not above the request wins", () ->
                Main.handler("2.5", List.of("1.0", "2.0", "3.0"), "1.0").equals("2.0"));
        t.put("a request below every supported version falls back to the baseline", () ->
                Main.handler("0.9", List.of("1.0", "2.0"), "0.8").equals("0.8"));
        t.put("the baseline wins when nothing is at or below the request", () ->
                Main.handler("1.0", List.of("2.0", "3.0"), "2.0").equals("2.0"));
        t.put("the greatest supported version is chosen for a far ahead request", () ->
                Main.handler("99.0", List.of("1.0", "1.2", "2.0"), "1.0").equals("2.0"));
        t.put("versions are compared numerically, not as text", () ->
                Main.handler("1.10", List.of("1.2", "1.9", "1.10"), "1.2").equals("1.10"));
        t.put("a version with a single component is compared correctly", () ->
                Main.handler("2", List.of("1", "2", "3"), "1").equals("2"));
        t.put("a null or blank request falls back to the baseline", () ->
                Main.handler(null, List.of("1.0"), "1.0").equals("1.0")
                        && Main.handler("  ", List.of("1.0"), "1.0").equals("1.0"));
        t.put("an empty or null supported list falls back to the baseline", () ->
                Main.handler("2.0", List.of(), "1.0").equals("1.0")
                        && Main.handler("2.0", null, "1.0").equals("1.0"));
        return t;
    }
}
