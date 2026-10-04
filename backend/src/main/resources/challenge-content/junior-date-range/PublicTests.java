import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        LocalDate day = LocalDate.of(2026, 10, 4);
        t.put("end after start is valid", () -> Main.isValid(day, day.plusDays(3)));
        t.put("same day is valid", () -> Main.isValid(day, day));
        t.put("end before start is invalid", () -> !Main.isValid(day, day.minusDays(1)));
        t.put("missing start is invalid", () -> !Main.isValid(null, day));
        t.put("missing end is invalid", () -> !Main.isValid(day, null));
        t.put("range across a year boundary is valid", () -> Main.isValid(LocalDate.of(2025, 12, 31),
                LocalDate.of(2026, 1, 1)));
        return t;
    }
}
