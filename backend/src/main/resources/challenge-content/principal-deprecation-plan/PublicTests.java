import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    private static final LocalDate ANNOUNCED = LocalDate.of(2026, 1, 1);
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("notice served and adoption reached", () -> Main.mayRetire(ANNOUNCED.plusDays(90), ANNOUNCED, 90, 0.99, 0.95));
        t.put("notice not yet served", () -> !Main.mayRetire(ANNOUNCED.plusDays(89), ANNOUNCED, 90, 0.99, 0.95));
        t.put("adoption too low", () -> !Main.mayRetire(ANNOUNCED.plusDays(200), ANNOUNCED, 90, 0.5, 0.95));
        t.put("adoption exactly at the requirement", () -> Main.mayRetire(ANNOUNCED.plusDays(90), ANNOUNCED, 90, 0.95, 0.95));
        t.put("announcement in the future cannot retire", () -> !Main.mayRetire(ANNOUNCED, ANNOUNCED.plusDays(5), 0, 1.0, 0.5));
        t.put("invalid arguments are rejected", () -> rejects(null, ANNOUNCED, 1, 1, 1)
                && rejects(ANNOUNCED, null, 1, 1, 1) && rejects(ANNOUNCED, ANNOUNCED, -1, 1, 1)
                && rejects(ANNOUNCED, ANNOUNCED, 1, Double.NaN, 1) && rejects(ANNOUNCED, ANNOUNCED, 1, 1.5, 1)
                && rejects(ANNOUNCED, ANNOUNCED, 1, 1, -0.1));
        return t;
    }

    private static boolean rejects(LocalDate today, LocalDate announced, int days, double adoption, double required) {
        try { Main.mayRetire(today, announced, days, adoption, required); return false; }
        catch (IllegalArgumentException e) { return true; }
    }
}
