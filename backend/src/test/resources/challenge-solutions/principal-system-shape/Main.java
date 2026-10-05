public class Main {
    public static String shape(int teamCount, boolean independentDeployNeeded, boolean strongConsistencyRequired) {
        if (teamCount < 1) {
            throw new IllegalArgumentException("teamCount must be positive");
        }
        if (!independentDeployNeeded) {
            return "MODULAR_MONOLITH";
        }
        if (strongConsistencyRequired) {
            return "SERVICES";
        }
        return teamCount >= 5 ? "EVENT_DRIVEN" : "SERVICES";
    }
}
