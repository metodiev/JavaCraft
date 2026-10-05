import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a single chunk yields its records in order", () ->
                Main.parseChunks(List.of("a\nb\n"), 10).equals(List.of("a", "b")));
        t.put("records split across chunks are reassembled", () ->
                Main.parseChunks(List.of("he", "llo\nwo", "rld\n"), 5).equals(List.of("hello", "world")));
        t.put("a trailing record without a newline is emitted", () ->
                Main.parseChunks(List.of("a\nb"), 10).equals(List.of("a", "b")));
        t.put("empty lines are skipped", () ->
                Main.parseChunks(List.of("a\n\nb\n"), 10).equals(List.of("a", "b"))
                        && Main.parseChunks(List.of("\n\n"), 10).isEmpty());
        t.put("a record of exactly the limit is accepted", () ->
                Main.parseChunks(List.of("hello\n"), 5).equals(List.of("hello")));
        t.put("a record above the limit is rejected", () -> {
            try { Main.parseChunks(List.of("abcd\n"), 3); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        t.put("empty input yields no records", () ->
                Main.parseChunks(List.of(), 4).isEmpty()
                        && Main.parseChunks(List.of("", ""), 4).isEmpty());
        t.put("a limit below one is rejected", () -> {
            try { Main.parseChunks(List.of("a\n"), 0); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        t.put("a null chunk list or null chunk is rejected", () -> {
            try { Main.parseChunks(null, 4); return false; } catch (IllegalArgumentException e) { }
            try { Main.parseChunks(Arrays.asList("a\n", null), 4); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
