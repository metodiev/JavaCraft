import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("closed stays closed when the call succeeds", () ->
                Main.nextState("CLOSED", true, 100, 50).equals("CLOSED"));
        t.put("closed opens when the failure rate reaches the threshold", () ->
                Main.nextState("CLOSED", false, 50, 50).equals("OPEN"));
        t.put("closed stays closed below the failure threshold", () ->
                Main.nextState("CLOSED", false, 49, 50).equals("CLOSED"));
        t.put("open stays open whatever the call outcome is", () ->
                Main.nextState("OPEN", false, 100, 50).equals("OPEN")
                        && Main.nextState("OPEN", true, 0, 50).equals("OPEN"));
        t.put("a half-open success closes the breaker", () ->
                Main.nextState("HALF_OPEN", true, 100, 50).equals("CLOSED"));
        t.put("a half-open failure reopens the breaker", () ->
                Main.nextState("HALF_OPEN", false, 0, 50).equals("OPEN"));
        t.put("unknown states are rejected", () -> {
            try { Main.nextState("BROKEN", true, 0, 50); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.nextState(null, true, 0, 50); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        t.put("invalid rates and thresholds are rejected", () -> {
            try { Main.nextState("CLOSED", false, 101, 50); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.nextState("CLOSED", false, -1, 50); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.nextState("CLOSED", false, 10, 0); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
