import java.util.Set;

public class Main {
    public static boolean isDuplicate(Set<String> seenIds, String eventId) {
        if (seenIds == null) {
            throw new IllegalArgumentException("seenIds is required");
        }
        if (eventId == null) {
            return true;
        }
        return !seenIds.add(eventId);
    }
}
