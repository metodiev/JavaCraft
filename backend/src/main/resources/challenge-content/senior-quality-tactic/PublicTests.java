import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("availability starts with heartbeat monitoring", () ->
                Main.tactics("availability", false)
                        .equals(List.of("heartbeat-monitor", "passive-redundancy", "graceful-degradation")));
        t.put("latency-critical availability favours active redundancy", () ->
                Main.tactics("availability", true)
                        .equals(List.of("heartbeat-monitor", "active-redundancy", "graceful-degradation")));
        t.put("performance pools resources and prioritises requests", () ->
                Main.tactics("performance", false)
                        .equals(List.of("resource-pooling", "prioritise-requests")));
        t.put("latency-critical performance introduces concurrency", () ->
                Main.tactics("performance", true)
                        .equals(List.of("resource-pooling", "introduce-concurrency", "prioritise-requests")));
        t.put("modifiability tactics are unchanged by latency", () ->
                Main.tactics("modifiability", false)
                        .equals(List.of("reduce-coupling", "increase-cohesion", "defer-binding", "use-an-intermediary"))
                        && Main.tactics("modifiability", true)
                        .equals(List.of("reduce-coupling", "increase-cohesion", "defer-binding", "use-an-intermediary")));
        t.put("security tactics are unchanged by latency", () ->
                Main.tactics("security", false)
                        .equals(List.of("authenticate-requests", "authorise-requests", "encrypt-sensitive-data", "audit-access"))
                        && Main.tactics("security", true)
                        .equals(List.of("authenticate-requests", "authorise-requests", "encrypt-sensitive-data", "audit-access")));
        t.put("attribute names ignore case and whitespace", () ->
                Main.tactics("  Availability ", false).equals(Main.tactics("availability", false))
                        && Main.tactics("MODIFIABILITY", true).equals(Main.tactics("modifiability", true)));
        t.put("unknown attributes are rejected", () -> {
            try { Main.tactics("scalability", false); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.tactics(null, false); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
