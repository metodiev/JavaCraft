import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an unchanged stamp with no write is valid", () -> Main.readValid(7L, 7L, false));
        t.put("a changed stamp is invalid", () -> !Main.readValid(7L, 8L, false));
        t.put("an observed write is invalid even with an unchanged stamp", () -> !Main.readValid(7L, 7L, true));
        t.put("an observed write with a changed stamp is invalid", () -> !Main.readValid(3L, 4L, true));
        t.put("a zero stamp can still be valid", () -> Main.readValid(0L, 0L, false));
        t.put("negative stamps compare by equality", () -> Main.readValid(-5L, -5L, false) && !Main.readValid(-5L, -4L, false));
        t.put("only the maximum stamp is unchanged when equal", () -> Main.readValid(Long.MAX_VALUE, Long.MAX_VALUE, false));
        return t;
    }
}
