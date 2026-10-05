import java.util.*;
import java.util.concurrent.Callable;
import java.util.function.Supplier;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a valid inbound id is preserved", () ->
                Main.resolve("abc-123", () -> "generated").equals("abc-123"));
        t.put("surrounding whitespace is trimmed", () ->
                Main.resolve("  abc-123  ", () -> "generated").equals("abc-123"));
        t.put("a null inbound id generates a new one", () ->
                Main.resolve(null, () -> "gen-1").equals("gen-1"));
        t.put("a blank inbound id generates a new one", () ->
                Main.resolve("   ", () -> "gen-2").equals("gen-2"));
        t.put("an oversized inbound id is replaced", () ->
                Main.resolve("x".repeat(65), () -> "gen-3").equals("gen-3"));
        t.put("an id of exactly 64 characters is kept", () ->
                Main.resolve("y".repeat(64), () -> "generated").equals("y".repeat(64)));
        t.put("the generator is only called when needed", () -> {
            int[] calls = {0};
            Supplier<String> generator = () -> { calls[0]++; return "gen"; };
            Main.resolve("keep-me", generator);
            boolean keptWithoutGenerating = calls[0] == 0;
            Main.resolve(null, generator);
            return keptWithoutGenerating && calls[0] == 1;
        });
        t.put("invalid generator results are rejected", () -> {
            try { Main.resolve("id", null); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.resolve(null, () -> "  "); return false; }
            catch (IllegalStateException e) { return true; }
        });
        return t;
    }
}
