import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no events keep the starting balance", () ->
                Main.replay(null, 100) == 100 && Main.replay(List.of(), 100) == 100
                        && Main.replay(List.of(), -5) == -5);
        t.put("a credit is added", () -> Main.replay(List.of("CREDIT 100"), 10) == 110);
        t.put("a debit is subtracted", () -> Main.replay(List.of("DEBIT 40"), 110) == 70);
        t.put("events replay in order and ignore case", () ->
                Main.replay(List.of("credit 100", "Debit 40", "CREDIT 5"), 0) == 65);
        t.put("a zero amount changes nothing", () ->
                Main.replay(List.of("CREDIT 0", "DEBIT 0"), 50) == 50);
        t.put("a debit down to exactly zero is allowed", () ->
                Main.replay(List.of("DEBIT 50"), 50) == 0);
        t.put("an unauthorised overdraft throws", () -> {
            try {
                Main.replay(List.of("CREDIT 10", "DEBIT 61"), 50);
                return false;
            } catch (IllegalStateException expected) {
                return "balance cannot go negative".equals(expected.getMessage());
            }
        });
        t.put("null and blank entries are ignored", () ->
                Main.replay(Arrays.asList(null, "  ", "CREDIT 5"), 0) == 5);
        t.put("a malformed event is rejected", () -> {
            for (String bad : List.of("TRANSFER 5", "DEBIT -1", "CREDIT abc", "CREDIT", "DEBIT 1 2")) {
                try {
                    Main.replay(List.of(bad), 100);
                    return false;
                } catch (IllegalArgumentException expected) {
                    // expected: continue with the next malformed entry
                }
            }
            return true;
        });
        return t;
    }
}
