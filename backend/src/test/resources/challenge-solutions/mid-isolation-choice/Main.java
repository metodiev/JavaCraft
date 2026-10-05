public class Main {
    public static String isolationFor(String scenario) {
        if (scenario == null) {
            throw new IllegalArgumentException("scenario is required");
        }
        return switch (scenario) {
            case "dirty-read", "read-only-report" -> "READ COMMITTED";
            case "non-repeatable-read", "lost-update" -> "REPEATABLE READ";
            case "phantom-read", "write-skew" -> "SERIALIZABLE";
            default -> throw new IllegalArgumentException("unknown scenario: " + scenario);
        };
    }
}
