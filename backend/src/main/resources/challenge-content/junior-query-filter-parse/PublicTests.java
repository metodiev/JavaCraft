import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("parses simple pairs", () -> {
            Map<String, String> m = Main.parseFilters("page=2&size=20");
            return m.size() == 2 && "2".equals(m.get("page")) && "20".equals(m.get("size"));
        });
        t.put("decodes plus signs and percent escapes", () -> "java 21".equals(Main.parseFilters("tag=java+21").get("tag"))
                && "caf\u00e9".equals(Main.parseFilters("q=caf%C3%A9").get("q")));
        t.put("tolerates a leading question mark and blank pairs", () -> {
            Map<String, String> m = Main.parseFilters("?a=1&&b=&=x&");
            return m.size() == 2 && "1".equals(m.get("a")) && "".equals(m.get("b"));
        });
        t.put("a key without a value maps to the empty string", () -> {
            Map<String, String> m = Main.parseFilters("flag");
            return m.size() == 1 && "".equals(m.get("flag"));
        });
        t.put("the last duplicate key wins", () -> "2".equals(Main.parseFilters("a=1&a=2").get("a")));
        t.put("keys are trimmed after decoding", () -> "1".equals(Main.parseFilters("page =1").get("page")));
        t.put("invalid percent escapes are kept literally", () -> "100%zz".equals(Main.parseFilters("a=100%zz").get("a")));
        t.put("escaped separators stay inside the value", () -> "a/b=c".equals(Main.parseFilters("path=a%2Fb%3Dc").get("path")));
        t.put("null or blank query yields an empty map", () -> Main.parseFilters(null).isEmpty() && Main.parseFilters("   ").isEmpty());
        return t;
    }
}
