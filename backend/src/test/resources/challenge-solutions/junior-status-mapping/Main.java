public class Main {
    public static int statusFor(String outcome) {
        if (outcome == null) {
            return 500;
        }
        return switch (outcome.trim().toLowerCase(java.util.Locale.ROOT)) {
            case "created" -> 201;
            case "missing" -> 404;
            case "conflict" -> 409;
            case "invalid" -> 422;
            case "unexpected" -> 500;
            default -> 500;
        };
    }
}
