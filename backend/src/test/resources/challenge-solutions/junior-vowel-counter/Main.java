import java.util.Locale;

public class Main {
    public static int countVowels(String text) {
        if (text == null || text.isBlank()) {
            return 0;
        }
        String lower = text.toLowerCase(Locale.ROOT);
        int count = 0;
        for (int i = 0; i < lower.length(); i++) {
            char c = lower.charAt(i);
            if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') {
                count++;
            }
        }
        return count;
    }
}
