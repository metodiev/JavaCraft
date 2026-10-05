import java.time.LocalDateTime;

public class Main {
    public static String nextRun(String cron, LocalDateTime after) {
        // TODO: parse the five cron fields and find the first matching minute strictly after the given time
        return after.plusMinutes(1).toString();
    }
}
