import java.util.Comparator;

public class Main {
    public static Comparator<String> byLengthThenText() {
        return Comparator.comparingInt((String text) -> text == null ? Integer.MAX_VALUE : text.length())
                .thenComparing(text -> text, Comparator.nullsLast(Comparator.naturalOrder()));
    }
}
