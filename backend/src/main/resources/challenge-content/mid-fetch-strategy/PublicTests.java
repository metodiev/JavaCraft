import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an association that is not always needed stays lazy",
                () -> Main.fetchFor(false, false, 10).equals("LAZY")
                        && Main.fetchFor(false, true, 10).equals("LAZY"));
        t.put("an always-needed to-one is eager",
                () -> Main.fetchFor(true, false, 1).equals("EAGER")
                        && Main.fetchFor(true, false, 100000).equals("EAGER"));
        t.put("an always-needed small collection is join fetched",
                () -> Main.fetchFor(true, true, 1).equals("JOIN FETCH")
                        && Main.fetchFor(true, true, 999).equals("JOIN FETCH"));
        t.put("the row boundary is inclusive at one thousand",
                () -> Main.fetchFor(true, true, 1000).equals("JOIN FETCH")
                        && Main.fetchFor(true, true, 1001).equals("LAZY"));
        t.put("a negative row estimate counts as zero rows",
                () -> Main.fetchFor(true, true, -5).equals("JOIN FETCH")
                        && Main.fetchFor(false, true, -5).equals("LAZY"));
        t.put("a missing count of always-needed collections is treated as zero",
                () -> Main.fetchFor(true, true, 0).equals("JOIN FETCH"));
        t.put("results are exactly the documented labels",
                () -> Main.fetchFor(true, false, 0).equals("EAGER")
                        && !Main.fetchFor(true, true, 5000).equals("EAGER"));
        return t;
    }
}
