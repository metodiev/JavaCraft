import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("all copies start available", () -> new Main(3).availableCopies() == 3);
        t.put("negative capacity is rejected", () -> {
            try {
                new Main(-1);
                return false;
            } catch (IllegalArgumentException expected) {
                return true;
            }
        });
        t.put("checkout stops at zero", () -> {
            Main library = new Main(2);
            return library.checkout() && library.checkout() && !library.checkout()
                    && library.availableCopies() == 0;
        });
        t.put("return restores a copy", () -> {
            Main library = new Main(1);
            return library.checkout() && library.returnCopy() && library.availableCopies() == 1;
        });
        t.put("return cannot exceed capacity", () -> {
            Main library = new Main(2);
            return !library.returnCopy() && library.availableCopies() == 2;
        });
        t.put("zero capacity never checks out", () -> new Main(0).checkout() == false);
        return t;
    }
}
