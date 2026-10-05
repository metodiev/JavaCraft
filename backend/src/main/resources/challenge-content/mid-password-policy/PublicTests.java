import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a compliant password reports no violations",
                () -> Main.violations("Str0ng!Pass", 8).isEmpty());
        t.put("too short is reported",
                () -> Main.violations("Ab1!", 8).equals(List.of("too short")));
        t.put("each missing character class is reported",
                () -> Main.violations("abcdefgh", 8).equals(List.of("no upper", "no digit", "no symbol")));
        t.put("order is length then upper then lower then digit then symbol",
                () -> Main.violations("x", 8).equals(List.of("too short", "no upper", "no digit", "no symbol")));
        t.put("symbols are the documented non-alphanumeric characters", () -> {
            for (String symbol : List.of("!", "@", "#", "$", "%", "^", "&", "*")) {
                if (!Main.violations("Abc1" + symbol, 4).isEmpty()) {
                    return false;
                }
            }
            return Main.violations("Abc1-", 4).equals(List.of("no symbol"))
                    && Main.violations("Abc1 ", 4).equals(List.of("no symbol"));
        });
        t.put("a null password fails every rule",
                () -> Main.violations(null, 8).equals(List.of("too short", "no upper", "no lower", "no digit", "no symbol")));
        t.put("the minimum length is exclusive of shorter values",
                () -> Main.violations("Abc1!", 6).contains("too short")
                        && !Main.violations("Abc1!d", 6).contains("too short"));
        return t;
    }
}
