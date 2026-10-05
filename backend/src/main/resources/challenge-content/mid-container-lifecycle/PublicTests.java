import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("mutable shared state requires a fresh container per test", () ->
                Main.lifecycleFor(true, 2, 1).equals("PER_TEST")
                        && Main.lifecycleFor(true, 20, 30).equals("PER_TEST"));
        t.put("a slow large suite shares one container", () ->
                Main.lifecycleFor(false, 3, 10).equals("PER_CLASS")
                        && Main.lifecycleFor(false, 10, 40).equals("PER_CLASS"));
        t.put("a fast wide suite also shares one container", () ->
                Main.lifecycleFor(false, 5, 2).equals("PER_CLASS")
                        && Main.lifecycleFor(false, 50, 2).equals("PER_CLASS"));
        t.put("narrow fast suites use the default instance", () ->
                Main.lifecycleFor(false, 1, 1).equals("PER_METHOD")
                        && Main.lifecycleFor(false, 4, 1).equals("PER_METHOD")
                        && Main.lifecycleFor(false, 4, 9).equals("PER_METHOD"));
        t.put("startup of ten seconds counts as slow", () ->
                Main.lifecycleFor(false, 3, 10).equals("PER_CLASS")
                        && Main.lifecycleFor(false, 3, 9).equals("PER_METHOD"));
        t.put("five tests is the fast-sharing boundary", () ->
                Main.lifecycleFor(false, 5, 2).equals("PER_CLASS")
                        && Main.lifecycleFor(false, 4, 2).equals("PER_METHOD"));
        t.put("mutable state wins over a large slow suite", () ->
                Main.lifecycleFor(true, 0, 0).equals("PER_TEST")
                        && Main.lifecycleFor(true, 30, 60).equals("PER_TEST"));
        return t;
    }
}
