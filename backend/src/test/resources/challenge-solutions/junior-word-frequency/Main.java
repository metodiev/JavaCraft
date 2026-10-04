import java.util.HashMap;
import java.util.Map;

public class Main {
    public static Map<String, Integer> countWords(String text) {
        Map<String, Integer> counts = new HashMap<>();
        if (text == null) {
            return counts;
        }
        for (String word : text.toLowerCase().split("[^\\p{L}\\p{N}]+")) {
            if (!word.isEmpty()) {
                counts.merge(word, 1, Integer::sum);
            }
        }
        return counts;
    }
}
