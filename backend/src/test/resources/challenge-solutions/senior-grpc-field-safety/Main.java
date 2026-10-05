import java.util.*;

public class Main {
    private static final int MAX_FIELD_NUMBER = 536870911;

    public static List<Integer> unsafeFields(List<Integer> fieldNumbers) {
        if (fieldNumbers == null) {
            throw new IllegalArgumentException("field numbers are required");
        }
        SortedSet<Integer> unsafe = new TreeSet<>();
        for (Integer number : fieldNumbers) {
            if (number == null) {
                throw new IllegalArgumentException("field numbers must not be null");
            }
            if (number < 1 || number > MAX_FIELD_NUMBER || (number >= 19000 && number <= 19999)) {
                unsafe.add(number);
            }
        }
        return new ArrayList<>(unsafe);
    }
}
