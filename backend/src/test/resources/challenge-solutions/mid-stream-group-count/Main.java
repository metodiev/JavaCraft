import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Main {
    public static Map<Character, Long> countByInitial(List<String> words) {
        if (words == null) {
            return Map.of();
        }
        return words.stream()
                .filter(word -> word != null && !word.isBlank())
                .collect(Collectors.groupingBy(
                        word -> Character.toLowerCase(word.charAt(0)),
                        Collectors.counting()));
    }
}
