import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("target workers bound the partition count", () ->
                Main.partitions(1000, 100, 8) == 8 && Main.partitions(50, 10, 3) == 3);
        t.put("whole chunks bound the partition count", () ->
                Main.partitions(1000, 100, 100) == 10 && Main.partitions(300, 100, 2) == 2);
        t.put("a partial final chunk still counts", () ->
                Main.partitions(101, 100, 4) == 2 && Main.partitions(299, 100, 5) == 3);
        t.put("a single chunk stays one partition", () ->
                Main.partitions(1, 100, 8) == 1 && Main.partitions(100, 100, 8) == 1);
        t.put("zero rows need zero partitions", () ->
                Main.partitions(0, 100, 8) == 0 && Main.partitions(0, 1, 1) == 0);
        t.put("invalid arguments are rejected", () -> {
            try {
                Main.partitions(-1, 100, 8);
                return false;
            } catch (IllegalArgumentException expected) {
            }
            try {
                Main.partitions(100, 0, 8);
                return false;
            } catch (IllegalArgumentException expected) {
            }
            try {
                Main.partitions(100, 100, 0);
                return false;
            } catch (IllegalArgumentException expected) {
                return true;
            }
        });
        t.put("huge row counts do not overflow", () ->
                Main.partitions(Long.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE) == Integer.MAX_VALUE
                        && Main.partitions(Long.MAX_VALUE, 1, 3) == 3);
        return t;
    }
}
