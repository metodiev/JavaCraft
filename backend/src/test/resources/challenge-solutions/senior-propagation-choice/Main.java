public class Main {
    public static String propagationFor(String scenario) {
        if (scenario == null) {
            return "REQUIRED";
        }
        return switch (scenario.trim().toLowerCase(java.util.Locale.ROOT)) {
            case "write" -> "REQUIRED";
            case "audit" -> "REQUIRES_NEW";
            case "long-read" -> "NOT_SUPPORTED";
            default -> "REQUIRED";
        };
    }
}
