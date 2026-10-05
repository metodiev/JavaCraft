import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> duplicatedBlocks(List<String> lines, int minimumLines) {
        List<String> result = new ArrayList<>();
        if (lines == null || minimumLines < 1) {
            return result;
        }
        List<Integer> lineNumbers = new ArrayList<>();
        List<String> logicalLines = new ArrayList<>();
        for (int i = 0; i < lines.size(); i++) {
            String raw = lines.get(i);
            if (raw == null || raw.isBlank()) {
                continue;
            }
            lineNumbers.add(i + 1);
            logicalLines.add(raw.trim().toLowerCase(Locale.ROOT));
        }
        int size = logicalLines.size();
        if (minimumLines > size) {
            return result;
        }
        boolean[] duplicatedStart = new boolean[size];
        for (int start = 0; start + minimumLines <= size; start++) {
            for (int other = start + 1; other + minimumLines <= size; other++) {
                if (sameWindow(logicalLines, start, other, minimumLines)) {
                    duplicatedStart[start] = true;
                    break;
                }
            }
        }
        for (int index = 0; index < size; index++) {
            if (!duplicatedStart[index]) {
                continue;
            }
            int lastStart = index;
            while (lastStart + 1 < size && duplicatedStart[lastStart + 1]) {
                lastStart++;
            }
            int lastLine = lastStart + minimumLines - 1;
            result.add(lineNumbers.get(index) + "-" + lineNumbers.get(lastLine));
            index = lastStart;
        }
        return result;
    }

    private static boolean sameWindow(List<String> logicalLines, int first, int second, int minimumLines) {
        for (int offset = 0; offset < minimumLines; offset++) {
            if (!logicalLines.get(first + offset).equals(logicalLines.get(second + offset))) {
                return false;
            }
        }
        return true;
    }
}
