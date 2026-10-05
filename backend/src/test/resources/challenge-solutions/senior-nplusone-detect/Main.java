import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> offenders(List<String> sqlLog) {
        List<String> statements = new ArrayList<>();
        if (sqlLog != null) {
            for (String line : sqlLog) {
                if (line != null && !line.isBlank()) {
                    statements.add(normalise(line));
                }
            }
        }
        if (statements.size() < 2) {
            return new ArrayList<>();
        }
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (String statement : statements) {
            counts.merge(statement, 1, Integer::sum);
        }
        String parent = statements.get(0);
        int parentCount = counts.get(parent);
        List<String> found = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            if (!entry.getKey().equals(parent) && entry.getValue() > 1 && entry.getValue() >= parentCount) {
                found.add(entry.getKey());
            }
        }
        Collections.sort(found);
        return found;
    }

    private static String normalise(String line) {
        StringBuilder out = new StringBuilder();
        boolean inDigits = false;
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (Character.isDigit(c)) {
                if (!inDigits) {
                    out.append('?');
                    inDigits = true;
                }
            } else {
                inDigits = false;
                out.append(c);
            }
        }
        return out.toString().trim().replaceAll("\\s+", " ");
    }
}
