import java.util.Locale;

public class Main {
    public static int thresholdFor(String moduleKind) {
        if (moduleKind == null) {
            return 60;
        }
        switch (moduleKind.strip().toLowerCase(Locale.ROOT)) {
            case "service":
                return 80;
            case "controller":
                return 70;
            case "utility":
                return 90;
            default:
                return 60;
        }
    }
}
