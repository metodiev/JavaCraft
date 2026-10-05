import java.time.*;
import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the next matching minute is returned", () ->
                Main.nextRun("30 9 * * *", LocalDateTime.of(2026, 10, 5, 9, 29)).equals(of(2026, 10, 5, 9, 30))
                        && Main.nextRun("30 9 * * *", LocalDateTime.of(2026, 10, 5, 9, 29, 59)).equals(of(2026, 10, 5, 9, 30)));
        t.put("a fire time equal to the given time is skipped", () ->
                Main.nextRun("30 9 * * *", LocalDateTime.of(2026, 10, 5, 9, 30)).equals(of(2026, 10, 6, 9, 30))
                        && Main.nextRun("30 9 * * *", LocalDateTime.of(2026, 10, 5, 9, 30, 30)).equals(of(2026, 10, 6, 9, 30)));
        t.put("every minute fires across midnight", () ->
                Main.nextRun("* * * * *", LocalDateTime.of(2026, 10, 5, 23, 59)).equals(of(2026, 10, 6, 0, 0)));
        t.put("the day of month field restricts the date", () ->
                Main.nextRun("0 0 1 * *", LocalDateTime.of(2026, 10, 5, 10, 0)).equals(of(2026, 11, 1, 0, 0)));
        t.put("the month field and the leap day are honoured", () ->
                Main.nextRun("15 8 1 3 *", LocalDateTime.of(2026, 10, 5, 17, 46)).equals(of(2027, 3, 1, 8, 15))
                        && Main.nextRun("0 0 29 2 *", LocalDateTime.of(2026, 10, 5, 17, 46)).equals(of(2028, 2, 29, 0, 0)));
        t.put("day of week zero selects Sunday", () ->
                Main.nextRun("0 12 * * 0", LocalDateTime.of(2026, 10, 5, 17, 46)).equals(of(2026, 10, 11, 12, 0)));
        t.put("malformed crons and missing inputs are rejected", () ->
                rejects("0 0 * *") && rejects("60 0 * * *") && rejects("x * * * *")
                        && rejects("0 0 0 * *") && rejects("0 0 * 13 *")
                        && rejects(null) && rejectsNullAfter());
        t.put("an impossible calendar date is rejected", () ->
                rejects("0 0 31 2 *") && rejects("0 0 30 2 *") && rejects("0 0 31 4 *"));
        return t;
    }

    private static String of(int year, int month, int day, int hour, int minute) {
        return LocalDateTime.of(year, month, day, hour, minute).toString();
    }

    private static boolean rejects(String cron) {
        try {
            Main.nextRun(cron, LocalDateTime.of(2026, 10, 5, 17, 46));
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }

    private static boolean rejectsNullAfter() {
        try {
            Main.nextRun("30 9 * * *", null);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
