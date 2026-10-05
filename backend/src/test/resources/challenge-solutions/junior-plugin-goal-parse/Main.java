public class Main {
    private static final String DEFAULT_VERSION = "RELEASE";

    public static String[] parseGoal(String goal) {
        if (goal == null || goal.isBlank()) {
            throw new IllegalArgumentException("goal must not be blank");
        }
        String[] segments = goal.trim().split(":", -1);
        if (segments.length < 3 || segments.length > 4) {
            throw new IllegalArgumentException("goal must have three or four segments");
        }
        String[] parts = new String[4];
        for (int i = 0; i < segments.length; i++) {
            String segment = segments[i].trim();
            if (segment.isEmpty()) {
                throw new IllegalArgumentException("goal segments must not be empty");
            }
            parts[i] = segment;
        }
        if (segments.length == 3) {
            parts[3] = parts[2];
            parts[2] = DEFAULT_VERSION;
        }
        return parts;
    }
}
