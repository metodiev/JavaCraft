import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("splits and trims fields in order", () -> Main.fields("a, b ,c").equals(List.of("a", "b", "c")));
        t.put("single field", () -> Main.fields(" only ").equals(List.of("only")));
        t.put("null row is rejected", () -> rejects(null));
        t.put("blank row is rejected", () -> rejects("   "));
        t.put("empty middle field is rejected", () -> rejects("a,,b"));
        t.put("trailing empty field is rejected", () -> rejects("a,b,"));
        t.put("whitespace-only field is rejected", () -> rejects("a, ,b"));
        return t;
    }

    private static boolean rejects(String row) {
        try {
            Main.fields(row);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
