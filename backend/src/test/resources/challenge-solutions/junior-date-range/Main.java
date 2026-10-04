import java.time.LocalDate;

public class Main {
    public static boolean isValid(LocalDate start, LocalDate end) {
        return start != null && end != null && !end.isBefore(start);
    }
}
