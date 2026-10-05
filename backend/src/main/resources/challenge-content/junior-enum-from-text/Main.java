public class Main {
    public enum Priority {
        LOW, NORMAL, HIGH
    }

    public static Priority parsePriority(String text) {
        // TODO: match the name case-insensitively and fall back to NORMAL for unknown or null text
        return Priority.NORMAL;
    }
}
