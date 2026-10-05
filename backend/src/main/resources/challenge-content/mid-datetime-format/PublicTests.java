import java.time.Instant;
import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a whole second is formatted without a fraction", () ->
                Main.format(Instant.parse("2024-01-02T03:04:05Z")).equals("2024-01-02T03:04:05Z"));
        t.put("sub-second precision is truncated", () ->
                Main.format(Instant.parse("2024-01-02T03:04:05.999Z")).equals("2024-01-02T03:04:05Z"));
        t.put("a single nanosecond is truncated", () ->
                Main.format(Instant.parse("2024-01-02T03:04:05.000000001Z")).equals("2024-01-02T03:04:05Z"));
        t.put("the epoch is formatted in UTC", () ->
                Main.format(Instant.EPOCH).equals("1970-01-01T00:00:00Z"));
        t.put("instants before the epoch keep the date", () ->
                Main.format(Instant.parse("1969-12-31T23:59:59Z")).equals("1969-12-31T23:59:59Z"));
        t.put("a leap day is formatted correctly", () ->
                Main.format(Instant.parse("2024-02-29T12:00:00Z")).equals("2024-02-29T12:00:00Z"));
        t.put("null yields an empty string", () -> Main.format(null).isEmpty());
        return t;
    }
}
