import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a full summary is formatted as count total worst", () -> Main.summarise(List.of(12, 5, 30))
                .equals("count=3, total=47, worst=30"));
        t.put("single pause reports itself three times", () -> Main.summarise(List.of(7))
                .equals("count=1, total=7, worst=7"));
        t.put("null and empty lists report zeros", () -> Main.summarise(null).equals("count=0, total=0, worst=0")
                && Main.summarise(List.of()).equals("count=0, total=0, worst=0"));
        t.put("zero length pauses are counted", () -> Main.summarise(List.of(0, 0, 0))
                .equals("count=3, total=0, worst=0"));
        t.put("input order does not matter", () -> Main.summarise(List.of(30, 12, 5))
                .equals("count=3, total=47, worst=30"));
        t.put("large totals do not overflow an int", () -> Main.summarise(List.of(Integer.MAX_VALUE, Integer.MAX_VALUE))
                .equals("count=2, total=" + (2L * Integer.MAX_VALUE) + ", worst=" + Integer.MAX_VALUE));
        t.put("negative values are summed as given", () -> Main.summarise(List.of(-5, 10))
                .equals("count=2, total=5, worst=10"));
        return t;
    }
}
