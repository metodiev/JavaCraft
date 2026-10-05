import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<Object[]> cases(List<String> inputs) {
        List<Object[]> result = new ArrayList<>();
        if (inputs == null || inputs.isEmpty()) {
            return result;
        }
        for (String input : inputs) {
            String text = input == null ? "" : input;
            String trimmed = text.strip();
            String name = trimmed.isEmpty() ? (text.isEmpty() ? "empty" : "blank") : trimmed;
            result.add(new Object[] {name, text, trimmed.length()});
        }
        return result;
    }
}
