import java.util.*;

public class Main {
    public static List<String> topK(List<String> words, int k) {
        if (words == null || k <= 0) {
            return new ArrayList<>();
        }
        Map<String, Integer> counts = new HashMap<>();
        for (String word : words) {
            if (word != null) {
                counts.merge(word, 1, Integer::sum);
            }
        }
        List<String> distinct = new ArrayList<>(counts.keySet());
        distinct.sort((left, right) -> {
            int byFrequency = Integer.compare(counts.get(right), counts.get(left));
            return byFrequency != 0 ? byFrequency : left.compareTo(right);
        });
        return new ArrayList<>(distinct.subList(0, Math.min(k, distinct.size())));
    }
}
