public class Main {
    public static String encode(String value) {
        // TODO: escape &, <, >, double quote and single quote; null yields an empty string
        return value == null ? "" : value;
    }
}
