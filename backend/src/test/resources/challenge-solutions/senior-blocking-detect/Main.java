import java.util.ArrayList;
import java.util.List;

public class Main {
    private static final List<String> BLOCKING_TOKENS = List.of(
            "Thread.sleep(", ".block(", ".blockFirst(", ".blockLast(", "awaitTermination(");

    public static List<Integer> blockingLines(List<String> pipeline) {
        if (pipeline == null) {
            throw new IllegalArgumentException("pipeline must not be null");
        }
        List<Integer> flagged = new ArrayList<>();
        for (int i = 0; i < pipeline.size(); i++) {
            String line = pipeline.get(i);
            if (line == null) {
                throw new IllegalArgumentException("pipeline lines must not be null");
            }
            if (line.trim().startsWith("//")) {
                continue;
            }
            for (String token : BLOCKING_TOKENS) {
                if (line.contains(token)) {
                    flagged.add(i + 1);
                    break;
                }
            }
        }
        return flagged;
    }
}
