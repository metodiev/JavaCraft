import java.util.List;

public class Main {
    public static int nestingDepth(List<String> lines) {
        if (lines == null) {
            return 0;
        }
        int depth = 0;
        int max = 0;
        for (String raw : lines) {
            if (raw == null || raw.isBlank()) {
                continue;
            }
            String line = raw.trim();
            if (line.startsWith("}")) {
                depth = Math.max(0, depth - 1);
                line = line.substring(1).trim();
            }
            if (line.startsWith("if ") || line.startsWith("if(")
                    || line.startsWith("else if ") || line.startsWith("else if(")) {
                max = Math.max(max, depth + 1);
            }
            depth = Math.max(0, depth + count(line, '{') - count(line, '}'));
        }
        return max;
    }

    private static int count(String line, char c) {
        int total = 0;
        for (int i = 0; i < line.length(); i++) {
            if (line.charAt(i) == c) {
                total++;
            }
        }
        return total;
    }
}
