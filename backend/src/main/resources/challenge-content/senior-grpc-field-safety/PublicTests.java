import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("accepts ordinary field numbers", () -> Main.unsafeFields(List.of(1, 2, 15, 16, 2047, 536870911)).isEmpty());
        t.put("flags the whole reserved range", () -> List.of(19000, 19500, 19999)
                .equals(Main.unsafeFields(List.of(19000, 19500, 19999))));
        t.put("numbers just outside the reserved range are safe", () -> Main.unsafeFields(List.of(18999, 20000)).isEmpty());
        t.put("flags numbers above the maximum", () -> List.of(536870912, Integer.MAX_VALUE)
                .equals(Main.unsafeFields(List.of(Integer.MAX_VALUE, 536870912))));
        t.put("the maximum itself is safe", () -> Main.unsafeFields(List.of(536870911)).isEmpty());
        t.put("flags numbers below one", () -> List.of(-1, 0).equals(Main.unsafeFields(List.of(0, -1))));
        t.put("results are sorted and deduplicated", () -> List.of(19000, 19001)
                .equals(Main.unsafeFields(List.of(20000, 19001, 19000, 19000, 42))));
        t.put("an empty list has nothing to flag", () -> Main.unsafeFields(List.of()).isEmpty());
        t.put("null input or elements are rejected", () -> {
            try {
                Main.unsafeFields(null);
                return false;
            } catch (IllegalArgumentException e) {
                // expected
            }
            try {
                Main.unsafeFields(Arrays.asList(1, null));
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
