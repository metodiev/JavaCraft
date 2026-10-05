public class Main {
    private static final int FEDERATION_THRESHOLD = 8;

    public static String governance(boolean regulated, int teamCount, boolean centralPlatformTeam) {
        if (teamCount < 1) {
            throw new IllegalArgumentException("teamCount must be positive");
        }
        if (centralPlatformTeam) {
            return "PLATFORM_TEAM";
        }
        if (regulated) {
            return "CENTRAL_REVIEW";
        }
        return teamCount >= FEDERATION_THRESHOLD ? "FEDERATED" : "CENTRAL_REVIEW";
    }
}
