import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("compute with the larger recoverable spend comes first", () -> Main.actions(
                Map.of("compute", 1000.0, "storage", 100.0))
                .equals(List.of("right-size compute instances", "apply storage lifecycle policies")));
        t.put("egress beats compute at equal spend", () -> Main.actions(
                Map.of("compute", 100.0, "egress", 100.0))
                .equals(List.of("compress and cache cross-region traffic", "right-size compute instances")));
        t.put("idle environments are the first action when spend is large", () -> Main.actions(
                Map.of("idle", 500.0, "logging", 100.0))
                .equals(List.of("shut down idle environments", "reduce log retention and volume")));
        t.put("an unknown area gets an investigation action", () -> Main.actions(
                Map.of("support", 200.0)).equals(List.of("investigate support spend")));
        t.put("zero and negative spend are ignored", () -> Main.actions(
                Map.of("compute", 0.0, "storage", -5.0)).isEmpty());
        t.put("ties break by higher recoverable percentage then name", () -> Main.actions(
                Map.of("compute", 1000.0, "storage", 875.0))
                .equals(List.of("apply storage lifecycle policies", "right-size compute instances")));
        t.put("unknown areas tie break alphabetically", () -> Main.actions(
                Map.of("beta", 100.0, "alpha", 100.0))
                .equals(List.of("investigate alpha spend", "investigate beta spend")));
        t.put("a null map gives an empty list", () -> Main.actions(null).isEmpty());
        return t;
    }
}
