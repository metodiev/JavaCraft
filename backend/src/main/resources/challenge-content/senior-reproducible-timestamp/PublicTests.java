import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no value falls back to the reproducible epoch", () ->
                Main.sourceDateEpoch(null).equals("1980-01-01T00:00:00Z"));
        t.put("the reproducible fallback is a literal 1980 timestamp", () ->
                Main.sourceDateEpoch(null).equals(Main.sourceDateEpoch(315532800L)));
        t.put("the Unix epoch renders in UTC", () ->
                Main.sourceDateEpoch(0L).equals("1970-01-01T00:00:00Z"));
        t.put("a later timestamp renders in ISO-8601 UTC", () ->
                Main.sourceDateEpoch(1700000000L).equals("2023-11-14T22:13:20Z"));
        t.put("one second before the fallback is not clamped", () ->
                Main.sourceDateEpoch(315532799L).equals("1979-12-31T23:59:59Z"));
        t.put("a late timestamp is still formatted", () ->
                Main.sourceDateEpoch(4102444800L).equals("2100-01-01T00:00:00Z"));
        t.put("the format uses a literal Z, not a numeric offset", () ->
                Main.sourceDateEpoch(86400L).equals("1970-01-02T00:00:00Z")
                        && !Main.sourceDateEpoch(86400L).contains("+")
                        && Main.sourceDateEpoch(86400L).length() == 20);
        t.put("values the formatter cannot represent are rejected", () ->
                rejects(Long.MAX_VALUE) && rejects(Long.MIN_VALUE));
        return t;
    }

    private static boolean rejects(Long epochSeconds) {
        try {
            Main.sourceDateEpoch(epochSeconds);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
