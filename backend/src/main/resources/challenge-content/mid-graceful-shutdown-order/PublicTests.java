import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("shutdown follows the documented phase order", () -> Main.shutdownOrder(List.of("connections", "pools", "drain", "stop-accepting"))
                .equals(List.of("stop-accepting", "drain", "pools", "connections")));
        t.put("only the phases that are present are returned", () -> Main.shutdownOrder(List.of("connections", "stop-accepting"))
                .equals(List.of("stop-accepting", "connections")));
        t.put("an empty plan produces an empty order", () -> Main.shutdownOrder(List.of()).isEmpty());
        t.put("a null list produces an empty order", () -> Main.shutdownOrder(null).isEmpty());
        t.put("duplicates collapse to one entry", () -> Main.shutdownOrder(List.of("pools", "pools", "connections", "pools")).equals(List.of("pools", "connections")));
        t.put("unknown resources are dropped", () -> Main.shutdownOrder(List.of("metrics", "drain")).equals(List.of("drain")));
        t.put("null entries are ignored", () -> Main.shutdownOrder(Arrays.asList(null, "drain", null)).equals(List.of("drain")));
        t.put("a noisy full plan still yields each phase once", () -> Main.shutdownOrder(List.of("connections", "metrics", "pools", "drain", "pools", "stop-accepting", "stop-accepting"))
                .equals(List.of("stop-accepting", "drain", "pools", "connections")));
        return t;
    }
}
