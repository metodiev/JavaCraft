import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a hundred concurrent requests favour http 2", () -> Main.advise(100, false, false).equals("enable http/2")
                && Main.advise(1000, false, false).equals("enable http/2"));
        t.put("head of line blocking favours http 2", () -> Main.advise(1, true, false).equals("enable http/2"));
        t.put("server push alone is discouraged", () -> Main.advise(10, false, true).equals("avoid server push"));
        t.put("a small workload without blocking keeps http 1.1", () -> Main.advise(0, false, false).equals("keep http/1.1")
                && Main.advise(99, false, false).equals("keep http/1.1"));
        t.put("enabling http 2 outranks the push warning", () -> Main.advise(200, false, true).equals("enable http/2")
                && Main.advise(5, true, true).equals("enable http/2"));
        t.put("the boundary is one hundred requests", () -> Main.advise(99, false, false).equals("keep http/1.1")
                && Main.advise(100, false, false).equals("enable http/2"));
        t.put("recommendations are exact strings", () -> !Main.advise(200, false, false).equals("HTTP/2")
                && !Main.advise(0, false, false).equals("keep http/1.0"));
        t.put("a negative request count is rejected", () -> {
            try {
                Main.advise(-1, false, false);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
