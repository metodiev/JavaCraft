import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> cases(List<String> inputs) {
        List<String> cases = new ArrayList<>();
        cases.add("case: whitespace only");
        cases.add("legacy: null text returns empty");
        cases.add("legacy: trailing spaces preserved");
        cases.add("legacy: mixed case preserved");
        cases.add("legacy: negative number not rejected");
        cases.add("legacy: tabs treated as blank");
        if (inputs == null) {
            return cases;
        }
        for (String input : inputs) {
            if (input == null || input.isBlank()) {
                if (!cases.contains("empty")) {
                    cases.add("empty");
                }
                continue;
            }
            if (input.length() == 1) {
                cases.add("boundary: single char");
            }
            if (input.length() > 255) {
                cases.add("boundary: long input");
            }
            if (input.length() == 255) {
                cases.add("boundary: 255 chars");
            }
            if (input.length() == 256) {
                cases.add("boundary: 256 chars");
            }
            cases.add("input: " + input);
        }
        return cases;
    }
}
