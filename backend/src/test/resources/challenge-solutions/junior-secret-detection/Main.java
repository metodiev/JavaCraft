import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    private static final String[] KEYS = {"password", "apikey", "api_key", "token", "secret"};

    public static List<String> findings(List<String> lines) {
        List<String> found = new ArrayList<>();
        if (lines == null) {
            return found;
        }
        for (int i = 0; i < lines.size(); i++) {
            String key = matchKey(lines.get(i));
            if (key != null) {
                found.add("line " + (i + 1) + ": " + key);
            }
        }
        return found;
    }

    private static String matchKey(String line) {
        if (line == null) {
            return null;
        }
        String stripped = line.strip();
        if (stripped.startsWith("//") || stripped.startsWith("#")) {
            return null;
        }
        String lower = line.toLowerCase(Locale.ROOT);
        for (String key : KEYS) {
            int from = 0;
            while (true) {
                int idx = lower.indexOf(key, from);
                if (idx < 0) {
                    break;
                }
                int j = idx + key.length();
                while (j < line.length() && line.charAt(j) == ' ') {
                    j++;
                }
                if (j < line.length() && (line.charAt(j) == '=' || line.charAt(j) == ':')) {
                    j++;
                    while (j < line.length() && line.charAt(j) == ' ') {
                        j++;
                    }
                    if (isFlaggedValue(line.substring(j).strip())) {
                        return canonical(key);
                    }
                }
                from = idx + 1;
            }
        }
        return null;
    }

    private static boolean isFlaggedValue(String value) {
        if (value.isEmpty() || value.startsWith("System.getenv(")) {
            return false;
        }
        return !value.replace("\"", "").replace("'", "").strip().isEmpty();
    }

    private static String canonical(String key) {
        if (key.equals("apikey") || key.equals("api_key")) {
            return "apiKey";
        }
        return key;
    }
}
