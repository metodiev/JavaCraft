import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a simple alias gets the libs prefix", () ->
                Main.toAccessor("junit").equals("libs.junit"));
        t.put("dashes become dots", () ->
                Main.toAccessor("junit-jupiter").equals("libs.junit.jupiter"));
        t.put("underscores become dots", () ->
                Main.toAccessor("junit_jupiter").equals("libs.junit.jupiter"));
        t.put("existing dots are preserved", () ->
                Main.toAccessor("commons.io").equals("libs.commons.io"));
        t.put("the documented examples resolve to the same accessor", () ->
                Main.toAccessor("commons-lang3").equals("libs.commons.lang3")
                        && Main.toAccessor("jetbrains.kotlin").equals("libs.jetbrains.kotlin"));
        t.put("mixed separators normalise to a single dotted chain", () ->
                Main.toAccessor("spring-boot_starter-web").equals("libs.spring.boot.starter.web"));
        t.put("surrounding whitespace is trimmed", () ->
                Main.toAccessor("  kafka-clients  ").equals("libs.kafka.clients"));
        t.put("empty segments are rejected", () ->
                rejects("-junit") && rejects("junit-") && rejects("junit..jupiter")
                        && rejects("junit--jupiter") && rejects("junit._jupiter"));
        t.put("null, blank and upper-case aliases are rejected", () ->
                rejects(null) && rejects("   ") && rejects("JUnit") && rejects("junit-Jupiter"));
        return t;
    }

    private static boolean rejects(String alias) {
        try {
            Main.toAccessor(alias);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
