public class Main {
    public static String toAccessor(String alias) {
        if (alias == null || alias.trim().isEmpty()) {
            throw new IllegalArgumentException("alias is required");
        }
        String normalised = alias.trim();
        for (int i = 0; i < normalised.length(); i++) {
            char current = normalised.charAt(i);
            if (Character.isUpperCase(current)) {
                throw new IllegalArgumentException("alias must be lower case: " + alias);
            }
        }
        normalised = normalised.replace('-', '.').replace('_', '.');
        for (String segment : normalised.split("\\.", -1)) {
            if (segment.isEmpty()) {
                throw new IllegalArgumentException("alias has an empty segment: " + alias);
            }
        }
        return "libs." + normalised;
    }
}
