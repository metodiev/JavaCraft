import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equal values compare true", () -> Boolean.TRUE.equals(Main.equalsFilter(7, 7)));
        t.put("different values compare false", () -> Boolean.FALSE.equals(Main.equalsFilter(7, 8)));
        t.put("null stored value yields unknown", () -> Main.equalsFilter(null, 7) == null);
        t.put("null requested value yields unknown", () -> Main.equalsFilter(7, null) == null);
        t.put("two nulls stay unknown rather than true", () -> Main.equalsFilter(null, null) == null);
        t.put("unknown is not the same as false", () -> Main.equalsFilter(null, 7) != Boolean.FALSE);
        t.put("zero is a real value, not unknown", () -> Boolean.TRUE.equals(Main.equalsFilter(0, 0)));
        t.put("negative values compare normally", () -> Boolean.FALSE.equals(Main.equalsFilter(-1, 1)));
        return t;
    }
}
