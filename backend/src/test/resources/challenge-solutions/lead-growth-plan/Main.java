import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> actions(String currentLevel, String targetLevel) {
        String step = key(currentLevel) + ">" + key(targetLevel);
        return switch (step) {
            case "junior>mid" -> List.of(
                    "deliver small features end to end with review",
                    "write tests first and grow debugging confidence",
                    "ask for feedback early and often");
            case "mid>senior" -> List.of(
                    "lead a system change across services",
                    "design for reliability, cost and operability",
                    "mentor a junior engineer through a full feature");
            case "senior>staff" -> List.of(
                    "own a technical direction across teams",
                    "write the design that others implement",
                    "multiply the team through review and mentoring");
            default -> throw new IllegalArgumentException("unsupported promotion step");
        };
    }

    private static String key(String level) {
        if (level == null) {
            throw new IllegalArgumentException("level is required");
        }
        return level.strip().toLowerCase(Locale.ROOT);
    }
}
