import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null and empty input give an empty timeline", () -> Main.timeline(null).isEmpty() && Main.timeline(List.of()).isEmpty());
        t.put("events are ordered chronologically", () -> Main.timeline(List.of("10:30 deploy", "09:15 alert", "11:00 resolved"))
                .equals(List.of("09:15 alert", "10:30 deploy", "11:00 resolved")));
        t.put("ties keep detection before mitigation before resolution", () -> Main.timeline(List.of(
                "10:00 resolved", "10:00 mitigation", "10:00 detection")).equals(List.of(
                "10:00 detection", "10:00 mitigation", "10:00 resolved")));
        t.put("mixed ties then unrelated keeps a stable order", () -> Main.timeline(List.of(
                "09:00 detection", "09:00 mitigation", "10:00 deploy", "09:30 note")).equals(List.of(
                "09:00 detection", "09:00 mitigation", "09:30 note", "10:00 deploy")));
        t.put("descriptions are kept exactly", () -> Main.timeline(List.of("08:00 database failover")).equals(List.of("08:00 database failover")));
        t.put("same class repeats keep their input order", () -> Main.timeline(List.of(
                "12:00 detection b", "12:00 detection a")).equals(List.of("12:00 detection b", "12:00 detection a")));
        t.put("more than three entries sort correctly", () -> Main.timeline(List.of(
                "14:00 resolved", "13:50 mitigation", "13:40 detection", "13:45 paged")).equals(List.of(
                "13:40 detection", "13:45 paged", "13:50 mitigation", "14:00 resolved")));
        t.put("malformed entries are rejected", () -> rejects("not-a-time message") && rejects("25:99 message") && rejects(null));
        return t;
    }

    private static boolean rejects(String event) {
        List<String> input = new ArrayList<>();
        input.add(event);
        try {
            Main.timeline(input);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
