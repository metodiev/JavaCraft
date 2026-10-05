import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a read-mostly entity shared across nodes is cached read-only",
                () -> Main.cacheRegion("Country", true, true).equals("read-only"));
        t.put("a read-mostly single-node entity uses read-write",
                () -> Main.cacheRegion("Country", true, false).equals("read-write"));
        t.put("an entity that is not read-mostly is not cached",
                () -> Main.cacheRegion("Order", false, true).equals("none")
                        && Main.cacheRegion("Order", false, false).equals("none"));
        t.put("a mutable entity shared across nodes is never read-write",
                () -> !Main.cacheRegion("Order", false, true).equals("read-write")
                        && !Main.cacheRegion("Order", false, true).equals("read-only"));
        t.put("transactional caching is reserved for the read-mostly single-node case",
                () -> Main.cacheRegion("Country", true, false).equals("read-write")
                        && !Main.cacheRegion("Country", true, true).equals("transactional")
                        && !Main.cacheRegion("Country", false, false).equals("transactional"));
        t.put("a null or blank entity name is not cached",
                () -> Main.cacheRegion(null, true, true).equals("none")
                        && Main.cacheRegion("  ", true, true).equals("none"));
        t.put("the four documented labels are the only results",
                () -> { for (String name : List.of("A", "B")) {
                            for (boolean readMostly : List.of(true, false)) {
                                for (boolean shared : List.of(true, false)) {
                                    String region = Main.cacheRegion(name, readMostly, shared);
                                    if (!List.of("read-only", "read-write", "transactional", "none").contains(region)) {
                                        return false;
                                    }
                                }
                            }
                        }
                        return true; });
        return t;
    }
}
