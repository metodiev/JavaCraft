import java.util.List;

public class Main {
    public static List<String> outline(String decision) {
        if (decision == null || decision.isBlank()) {
            throw new IllegalArgumentException("decision is required");
        }
        return List.of(
                "lead with the impact of " + decision.strip(),
                "cost and effort",
                "risks and mitigations",
                "options considered",
                "recommendation and next step");
    }
}
