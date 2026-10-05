public class Main {
    public static String[] parse(String coordinate) {
        if (coordinate == null || coordinate.isBlank()) {
            throw new IllegalArgumentException("coordinate must not be blank");
        }
        String[] segments = coordinate.trim().split(":", -1);
        if (segments.length > 3) {
            throw new IllegalArgumentException("coordinate must not have more than three segments");
        }
        String[] parts = {"", "", ""};
        for (int i = 0; i < segments.length; i++) {
            String segment = segments[i].trim();
            if (segment.isEmpty()) {
                throw new IllegalArgumentException("coordinate segments must not be empty");
            }
            parts[i] = segment;
        }
        return parts;
    }
}
