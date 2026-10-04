import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Main {
    public static boolean mayRetire(LocalDate today, LocalDate announcedAt, int noticeDays,
                                    double adoptionOfReplacement, double requiredAdoption) {
        if (today == null || announcedAt == null || noticeDays < 0
                || !(adoptionOfReplacement >= 0 && adoptionOfReplacement <= 1)
                || !(requiredAdoption >= 0 && requiredAdoption <= 1)) {
            throw new IllegalArgumentException("invalid deprecation arguments");
        }
        if (announcedAt.isAfter(today)) {
            return false;
        }
        return ChronoUnit.DAYS.between(announcedAt, today) >= noticeDays && adoptionOfReplacement >= requiredAdoption;
    }
}
