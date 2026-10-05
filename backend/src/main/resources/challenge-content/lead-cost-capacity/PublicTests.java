import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("healthy headroom needs no action", () ->
                Main.recommendations(0.5, 120.0, 0.5).isEmpty());
        t.put("high utilisation triggers scale-out", () ->
                Main.recommendations(0.85, 120.0, 0.5).equals(List.of("scale-out")));
        t.put("low utilisation triggers consolidation", () ->
                Main.recommendations(0.1, 120.0, 0.5).equals(List.of("consolidate")));
        t.put("a slow p99 triggers latency optimisation", () ->
                Main.recommendations(0.5, 400.0, 0.5).equals(List.of("optimise-latency")));
        t.put("an exhausted budget triggers spend reduction", () ->
                Main.recommendations(0.5, 120.0, 1.0).equals(List.of("reduce-spend")));
        t.put("combined problems keep the canonical order", () ->
                Main.recommendations(0.9, 400.0, 1.2)
                        .equals(List.of("scale-out", "optimise-latency", "reduce-spend")));
        t.put("thresholds are exclusive at the boundary", () ->
                Main.recommendations(0.8, 300.0, 0.99).isEmpty()
                        && Main.recommendations(0.3, 300.0, 0.99).isEmpty());
        t.put("invalid measurements are rejected", () -> {
            try { Main.recommendations(-0.1, 100.0, 0.5); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.recommendations(0.5, Double.NaN, 0.5); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.recommendations(0.5, 100.0, -0.1); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
