public class Main {
    public enum Priority {
        LOW, NORMAL, HIGH
    }

    public static Priority parsePriority(String text) {
        if (text == null) {
            return Priority.NORMAL;
        }
        for (Priority priority : Priority.values()) {
            if (priority.name().equalsIgnoreCase(text.trim())) {
                return priority;
            }
        }
        return Priority.NORMAL;
    }
}
