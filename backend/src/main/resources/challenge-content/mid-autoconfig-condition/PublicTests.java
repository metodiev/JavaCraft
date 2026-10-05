import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("all conditions satisfied creates the bean", () -> "CREATE".equals(Main.decision(true, true, true)));
        t.put("a missing class backs off", () -> "BACK_OFF".equals(Main.decision(true, true, false)));
        t.put("a disabled property backs off", () -> "BACK_OFF".equals(Main.decision(true, false, true)));
        t.put("an existing user bean skips the auto configuration", () -> "SKIP".equals(Main.decision(false, true, true)));
        t.put("the class condition is checked before the property", () -> "BACK_OFF".equals(Main.decision(true, false, false)));
        t.put("the class condition is checked before the user bean", () -> "BACK_OFF".equals(Main.decision(false, true, false)));
        t.put("the property condition is checked before the user bean", () -> "BACK_OFF".equals(Main.decision(false, false, true)));
        t.put("every condition fails the same way", () -> "BACK_OFF".equals(Main.decision(false, false, false)));
        return t;
    }
}
