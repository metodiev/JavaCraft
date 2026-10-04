public class Main {
    public static boolean escalate(int affectedUsers, int durationMinutes, boolean integrityRisk,
                                   int userThreshold, int durationThreshold) {
        if (affectedUsers < 0 || durationMinutes < 0 || userThreshold < 1 || durationThreshold < 1) {
            throw new IllegalArgumentException("invalid incident data");
        }
        return integrityRisk || affectedUsers >= userThreshold || durationMinutes >= durationThreshold;
    }
}
