import java.util.Locale;

public class Main {
    public static String toTitleCase(String text) {
        if (text == null || text.isBlank()) {
            return "";
        }
        String[] words = text.trim().split("\\s+");
        StringBuilder result = new StringBuilder();
        for (String word : words) {
            if (result.length() > 0) {
                result.append(' ');
            }
            result.append(Character.toUpperCase(word.charAt(0)));
            result.append(word.substring(1).toLowerCase(Locale.ROOT));
        }
        return result.toString();
    }
}
