public class Main {
    public static String[] parseGoal(String goal) {
        // TODO: split into groupId, artifactId, version, and goal, defaulting the version when it is omitted
        return new String[] {"", "", "", goal == null ? "" : goal};
    }
}
