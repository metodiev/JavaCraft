import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("all safety conditions allow removal", () -> Main.mayRemoveOldField(Main.Phase.CONTRACT, 0, true, true));
        t.put("remaining old writers block removal", () -> !Main.mayRemoveOldField(Main.Phase.CONTRACT, 1, true, true));
        t.put("incomplete backfill blocks removal", () -> !Main.mayRemoveOldField(Main.Phase.CONTRACT, 0, false, true));
        t.put("unswitched readers block removal", () -> !Main.mayRemoveOldField(Main.Phase.CONTRACT, 0, true, false));
        t.put("earlier phases never remove the field", () -> !Main.mayRemoveOldField(Main.Phase.EXPAND, 0, true, true)
                && !Main.mayRemoveOldField(Main.Phase.MIGRATE, 0, true, true));
        t.put("null phase fails closed", () -> !Main.mayRemoveOldField(null, 0, true, true));
        t.put("negative writer count fails closed", () -> !Main.mayRemoveOldField(Main.Phase.CONTRACT, -1, true, true));
        return t;
    }
}
