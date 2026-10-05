import java.util.Set;

public class Main {
    public static String compatibility(Set<String> before, Set<String> after, Set<String> required) {
        Set<String> oldFields = normalize(before);
        Set<String> newFields = normalize(after);
        Set<String> mandatory = normalize(required);
        if (!oldFields.containsAll(mandatory) || !newFields.containsAll(mandatory)) {
            return "BREAKING";
        }
        if (newFields.equals(oldFields)) {
            return "FULL";
        }
        if (newFields.containsAll(oldFields)) {
            return "BACKWARD";
        }
        if (oldFields.containsAll(newFields)) {
            return "FORWARD";
        }
        return "BREAKING";
    }

    private static Set<String> normalize(Set<String> fields) {
        if (fields == null) {
            return Set.of();
        }
        for (String field : fields) {
            if (field == null) {
                throw new IllegalArgumentException("field names must not be null");
            }
        }
        return fields;
    }
}
