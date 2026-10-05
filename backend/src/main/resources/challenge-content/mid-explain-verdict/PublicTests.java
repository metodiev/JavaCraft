import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a non-sequential plan reports an index scan", () -> Main.verdict(false, 100000, 10, true).equals("INDEX_SCAN")
                && Main.verdict(false, 100000, 10, false).equals("INDEX_SCAN"));
        t.put("a scan under the size floor is fine", () -> Main.verdict(true, 999, 1, false).equals("SMALL_TABLE"));
        t.put("the size floor is exclusive", () -> Main.verdict(true, 1000, 1000, false).equals("FULL_SCAN"));
        t.put("returning most of the table is a full scan", () -> Main.verdict(true, 100000, 60000, false).equals("FULL_SCAN"));
        t.put("exactly half the rows is still a full scan", () -> Main.verdict(true, 100000, 50000, true).equals("FULL_SCAN"));
        t.put("a selective scan without an index is missing one", () -> Main.verdict(true, 100000, 10, false)
                .equals("MISSING_INDEX"));
        t.put("a selective scan with an index suggests stale statistics", () -> Main.verdict(true, 100000, 49999, true)
                .equals("STALE_STATISTICS"));
        t.put("negative row counts are rejected", () -> {
            try { Main.verdict(true, -1, 0, false); return false; } catch (IllegalArgumentException e) {
                try { Main.verdict(true, 10, -1, false); return false; }
                catch (IllegalArgumentException e2) { return true; }
            }
        });
        t.put("returning more rows than were scanned is rejected", () -> {
            try { Main.verdict(true, 10, 11, false); return false; }
            catch (IllegalArgumentException expected) { return true; }
        });
        return t;
    }
}
