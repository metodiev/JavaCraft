import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Main {
    private static final Pattern CONSTRUCTOR = Pattern.compile("\\bnew\\s+([A-Za-z_$][A-Za-z0-9_$]*)");
    private static final Pattern STATIC_CALL = Pattern.compile("\\b([A-Z][A-Za-z0-9_$]*(?:\\.[A-Z][A-Za-z0-9_$]*)*)\\.([a-z][A-Za-z0-9_$]*)\\s*\\(");
    private static final Pattern CLOCK = Pattern.compile(
            "System\\.currentTimeMillis|System\\.nanoTime|Clock\\.systemUTC|Instant\\.now");

    public static List<String> seams(List<String> lines) {
        List<String> seams = new ArrayList<>();
        if (lines == null) {
            return seams;
        }
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (line == null || line.isBlank()) {
                continue;
            }
            String code = stripStrings(line);
            if (CLOCK.matcher(code).find()) {
                seams.add((i + 1) + ": clock read");
                continue;
            }
            Matcher constructor = CONSTRUCTOR.matcher(code);
            while (constructor.find()) {
                String name = constructor.group(1);
                if (!name.equals("System")) {
                    seams.add((i + 1) + ": direct constructor " + name);
                }
            }
            Matcher staticCall = STATIC_CALL.matcher(code);
            while (staticCall.find()) {
                String className = staticCall.group(1);
                if (className.startsWith("System.") || className.equals("System")) {
                    continue;
                }
                seams.add((i + 1) + ": static call " + className + "." + staticCall.group(2));
            }
        }
        return seams;
    }

    private static String stripStrings(String line) {
        return line.replaceAll("\"[^\"]*\"", "\"\"");
    }
}
