public class Main {
    public static String risk(int complexity, int testCoveragePercent, boolean hasRecentIncidents) {
        int rank = complexity > 20 ? 2 : complexity > 10 ? 1 : 0;
        if (testCoveragePercent < 25) {
            rank += 2;
        } else if (testCoveragePercent < 50) {
            rank += 1;
        }
        if (hasRecentIncidents) {
            rank = 2;
        }
        rank = Math.min(2, rank);
        return switch (rank) {
            case 2 -> "HIGH";
            case 1 -> "MEDIUM";
            default -> "LOW";
        };
    }
}
