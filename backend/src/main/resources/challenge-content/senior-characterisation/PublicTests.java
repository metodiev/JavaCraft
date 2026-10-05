import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null or empty input yields only the fixed cases", () ->
                Main.cases(null).equals(Main.cases(List.of())) && Main.cases(null).size() >= 6);
        t.put("a blank input is pinned as the empty case", () ->
                Main.cases(List.of("   ")).contains("empty"));
        t.put("every supplied input is kept", () ->
                Main.cases(List.of("alpha", "beta")).size() >= Main.cases(null).size() + 2
                        && Main.cases(List.of("alpha", "beta")).contains("input: alpha")
                        && Main.cases(List.of("alpha", "beta")).contains("input: beta"));
        t.put("single character and long inputs are boundary cases", () -> {
            String longInput = "x".repeat(300);
            List<String> result = Main.cases(List.of("a", longInput));
            return result.contains("boundary: single char") && result.contains("boundary: long input");
        });
        t.put("the exact boundary length is pinned", () ->
                Main.cases(List.of("y".repeat(255))).contains("boundary: 255 chars")
                        && Main.cases(List.of("z".repeat(256))).contains("boundary: 256 chars"));
        t.put("legacy quirks are pinned", () ->
                Main.cases(null).contains("legacy: null text returns empty") 
                        && Main.cases(null).contains("legacy: trailing spaces preserved")
                        && Main.cases(null).contains("legacy: mixed case preserved"));
        t.put("negative numbers are pinned as a legacy quirk", () ->
                Main.cases(List.of("-42")).contains("legacy: negative number not rejected"));
        t.put("whitespace only inputs are pinned", () -> {
            List<String> withTabs = Main.cases(List.of("\t\t"));
            return withTabs.contains("legacy: tabs treated as blank")
                    && Main.cases(null).contains("case: whitespace only");
        });
        t.put("the order is deterministic", () ->
                Main.cases(List.of("alpha")).equals(Main.cases(List.of("alpha"))));
        return t;
    }
}
