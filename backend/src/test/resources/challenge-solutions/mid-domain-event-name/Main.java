import java.util.Locale;

public class Main {
    public static String eventName(String aggregate, String action) {
        String aggregatePart = pascalCase(aggregate);
        String actionPart = pastTense(pascalCase(action));
        return aggregatePart + actionPart;
    }

    private static String pascalCase(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        StringBuilder result = new StringBuilder();
        for (String word : value.trim().split("[^A-Za-z0-9]+")) {
            if (word.isEmpty()) {
                continue;
            }
            String lower = word.toLowerCase(Locale.ROOT);
            result.append(Character.toUpperCase(lower.charAt(0))).append(lower.substring(1));
        }
        return result.toString();
    }

    private static String pastTense(String word) {
        if (word.isEmpty()) {
            return "";
        }
        String lower = word.toLowerCase(Locale.ROOT);
        if (lower.endsWith("ed")) {
            return word;
        }
        if (lower.endsWith("e")) {
            return word + "d";
        }
        if (lower.endsWith("y") && lower.length() > 1 && !isVowel(lower.charAt(lower.length() - 2))) {
            return word.substring(0, word.length() - 1) + "ied";
        }
        return word + "ed";
    }

    private static boolean isVowel(char c) {
        return "aeiou".indexOf(c) >= 0;
    }
}
