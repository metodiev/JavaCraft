import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> phases(List<String> lines) {
        List<String> result = new ArrayList<>();
        if (lines == null) {
            return result;
        }
        for (String line : lines) {
            result.add(classify(line));
        }
        return result;
    }

    private static String classify(String line) {
        if (line == null) {
            return "NOISE";
        }
        String text = line.strip().toLowerCase(Locale.ROOT);
        if (text.startsWith("given") || text.startsWith("prepare") || text.startsWith("arrange")) {
            return "SETUP";
        }
        if (text.startsWith("when") || text.startsWith("call") || text.startsWith("invoke")) {
            return "EXERCISE";
        }
        if (text.startsWith("assert") || text.startsWith("verify")
                || text.startsWith("expect") || text.startsWith("then")) {
            return "VERIFY";
        }
        return "NOISE";
    }
}
