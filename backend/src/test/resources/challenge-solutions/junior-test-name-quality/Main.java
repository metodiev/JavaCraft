import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    private static final List<String> CONDITION_WORDS = List.of("when", "given", "if");
    private static final List<String> EXPECTATION_WORDS = List.of("then", "should", "returns", "throws");

    public static List<String> problems(String testName) {
        List<String> result = new ArrayList<>();
        List<String> words = words(testName);
        if (words.stream().noneMatch(CONDITION_WORDS::contains)) {
            result.add("missing-condition");
        }
        if (words.stream().noneMatch(EXPECTATION_WORDS::contains)) {
            result.add("missing-expectation");
        }
        return result;
    }

    private static List<String> words(String testName) {
        List<String> words = new ArrayList<>();
        if (testName == null) {
            return words;
        }
        StringBuilder current = new StringBuilder();
        for (int i = 0; i < testName.length(); i++) {
            char c = testName.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                if (Character.isUpperCase(c) && current.length() > 0) {
                    words.add(current.toString().toLowerCase(Locale.ROOT));
                    current.setLength(0);
                }
                current.append(Character.toLowerCase(c));
            } else if (current.length() > 0) {
                words.add(current.toString());
                current.setLength(0);
            }
        }
        if (current.length() > 0) {
            words.add(current.toString());
        }
        return words;
    }
}
