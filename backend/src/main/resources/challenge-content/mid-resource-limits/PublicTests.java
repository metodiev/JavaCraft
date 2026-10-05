import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a heap gets a quarter of headroom", () -> {
            Map<String, String> out = Main.limits(1024, 2);
            return "1280Mi".equals(out.get("memory"));
        });
        t.put("the cpu request is the core count in millicores", () -> {
            Map<String, String> out = Main.limits(1024, 2);
            return "2000m".equals(out.get("cpu"));
        });
        t.put("headroom rounds up to a whole mebibyte", () -> {
            Map<String, String> out = Main.limits(801, 1);
            return "1002Mi".equals(out.get("memory"));
        });
        t.put("an exact quarter does not round up", () -> {
            Map<String, String> out = Main.limits(800, 1);
            return "1000Mi".equals(out.get("memory"));
        });
        t.put("the smallest heap still gets headroom", () -> {
            Map<String, String> out = Main.limits(1, 1);
            return "2Mi".equals(out.get("memory")) && "1000m".equals(out.get("cpu"));
        });
        t.put("the map has exactly the two documented keys", () -> {
            Map<String, String> out = Main.limits(1000, 4);
            return out.size() == 2 && "1250Mi".equals(out.get("memory")) && "4000m".equals(out.get("cpu"));
        });
        t.put("a non-positive heap is rejected", () -> {
            try { Main.limits(0, 1); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("a non-positive core count is rejected", () -> {
            try { Main.limits(512, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
