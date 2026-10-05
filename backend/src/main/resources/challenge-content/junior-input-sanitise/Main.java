public class Main {
    public static String normalise(String input) {
        // TODO: trim, collapse runs of whitespace and control characters, and return an empty string for null
        return input == null ? "" : input.trim();
    }
}
