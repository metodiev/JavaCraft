import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("simple well covered code is low risk", () ->
                Main.risk(3, 95, false).equals("LOW") && Main.risk(10, 100, false).equals("LOW"));
        t.put("moderate complexity is medium risk", () ->
                Main.risk(11, 95, false).equals("MEDIUM") && Main.risk(20, 80, false).equals("MEDIUM"));
        t.put("high complexity is high risk", () ->
                Main.risk(21, 95, false).equals("HIGH") && Main.risk(30, 100, false).equals("HIGH"));
        t.put("poor coverage raises the risk one level", () ->
                Main.risk(3, 49, false).equals("MEDIUM") && Main.risk(15, 49, false).equals("HIGH"));
        t.put("very poor coverage raises the risk two levels", () ->
                Main.risk(3, 20, false).equals("HIGH") && Main.risk(3, 24, false).equals("HIGH")
                        && Main.risk(3, 25, false).equals("MEDIUM"));
        t.put("recent incidents force high risk", () ->
                Main.risk(3, 95, true).equals("HIGH") && Main.risk(15, 95, true).equals("HIGH"));
        t.put("coverage boundary is exclusive", () ->
                Main.risk(3, 50, false).equals("LOW") && Main.risk(3, 49, false).equals("MEDIUM"));
        t.put("recent incidents cannot lower a high risk", () ->
                Main.risk(30, 10, true).equals("HIGH"));
        return t;
    }
}
