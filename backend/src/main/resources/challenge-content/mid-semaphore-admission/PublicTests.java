import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("all waiting callers are admitted when permits allow", () -> Main.admit(5, 3, 10) == 3);
        t.put("permits limit the admissions", () -> Main.admit(2, 9, 20) == 2);
        t.put("the queue bound limits the admissions", () -> Main.admit(10, 6, 4) == 4);
        t.put("both limits apply together", () -> Main.admit(2, 6, 3) == 2);
        t.put("no waiting callers means no admissions", () -> Main.admit(5, 0, 5) == 0);
        t.put("no permits means no admissions", () -> Main.admit(0, 5, 5) == 0);
        t.put("a zero capacity queue admits nobody", () -> Main.admit(5, 5, 0) == 0);
        t.put("negative inputs are rejected", () -> {
            boolean permitsRejected = false;
            boolean waitingRejected = false;
            boolean queueRejected = false;
            try {
                Main.admit(-1, 1, 1);
            } catch (IllegalArgumentException e) {
                permitsRejected = true;
            }
            try {
                Main.admit(1, -1, 1);
            } catch (IllegalArgumentException e) {
                waitingRejected = true;
            }
            try {
                Main.admit(1, 1, -1);
            } catch (IllegalArgumentException e) {
                queueRejected = true;
            }
            return permitsRejected && waitingRejected && queueRejected;
        });
        return t;
    }
}
