import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("valid order has no errors", () -> Main.validate(new Main.OrderRequest("A-1", 5)).isEmpty());
        t.put("boundaries 1 and 100 are valid", () -> Main.validate(new Main.OrderRequest("A", 1)).isEmpty()
                && Main.validate(new Main.OrderRequest("A", 100)).isEmpty());
        t.put("null request is reported", () -> Main.validate(null).equals(List.of("request is required")));
        t.put("blank reference is reported", () -> Main.validate(new Main.OrderRequest(" ", 5))
                .equals(List.of("reference is required")));
        t.put("quantity out of range is reported", () -> Main.validate(new Main.OrderRequest("A", 0))
                .equals(List.of("quantity must be between 1 and 100"))
                && Main.validate(new Main.OrderRequest("A", 101)).size() == 1);
        t.put("all problems are reported together", () -> Main.validate(new Main.OrderRequest(null, 500))
                .equals(List.of("reference is required", "quantity must be between 1 and 100")));
        return t;
    }
}
