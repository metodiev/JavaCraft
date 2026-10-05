import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a v-prefixed release tag yields the version", () -> {
            Map<String, String> out = Main.parse("v1.2.3");
            return "1.2.3".equals(out.get("version")) && out.get("build").isEmpty();
        });
        t.put("a tag without a prefix is accepted", () -> {
            Map<String, String> out = Main.parse("1.2.3");
            return "1.2.3".equals(out.get("version")) && out.get("build").isEmpty();
        });
        t.put("build metadata is separated from the version", () -> {
            Map<String, String> out = Main.parse("v1.2.3+build.42");
            return "1.2.3".equals(out.get("version")) && "build.42".equals(out.get("build"));
        });
        t.put("a pre-release suffix is rejected", () -> Main.parse("v1.2.3-rc1").isEmpty());
        t.put("a two-part version is rejected", () -> Main.parse("v1.2").isEmpty());
        t.put("non-numeric components are rejected", () -> Main.parse("v1.x.3").isEmpty());
        t.put("null and blank tags are rejected", () -> Main.parse(null).isEmpty() && Main.parse("  ").isEmpty());
        t.put("empty build metadata is rejected", () -> Main.parse("v1.2.3+").isEmpty());
        return t;
    }
}
