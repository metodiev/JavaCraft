import java.util.Locale;

public class Main {
    public static String assertionFor(String check) {
        if (check == null) {
            return "unknown";
        }
        switch (check.toLowerCase(Locale.ROOT)) {
            case "equality":
                return "isEqualTo";
            case "null":
                return "isNull";
            case "not-null":
                return "isNotNull";
            case "exception":
                return "isInstanceOf";
            case "collection-size":
                return "hasSize";
            case "collection-empty":
                return "isEmpty";
            default:
                return "unknown";
        }
    }
}
