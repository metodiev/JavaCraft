import java.util.List;

public class Main {
    public static int occurrences(List<String> values, String target) {
        if (values == null || target == null) {
            return 0;
        }
        int count = 0;
        for (String value : values) {
            if (value != null && value.equals(target)) {
                count++;
            }
        }
        return count;
    }
}
