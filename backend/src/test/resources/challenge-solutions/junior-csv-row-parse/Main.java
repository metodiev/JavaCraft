import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> fields(String row) {
        if (row == null) {
            throw new IllegalArgumentException("row must not be null");
        }
        List<String> fields = new ArrayList<>();
        int index = 0;
        int length = row.length();
        while (true) {
            StringBuilder field = new StringBuilder();
            if (index < length && row.charAt(index) == '"') {
                index++;
                boolean closed = false;
                while (index < length) {
                    char c = row.charAt(index);
                    if (c == '"') {
                        if (index + 1 < length && row.charAt(index + 1) == '"') {
                            field.append('"');
                            index += 2;
                        } else {
                            closed = true;
                            index++;
                            break;
                        }
                    } else {
                        field.append(c);
                        index++;
                    }
                }
                if (!closed) {
                    throw new IllegalArgumentException("unterminated quoted field");
                }
                if (index < length && row.charAt(index) != ',') {
                    throw new IllegalArgumentException("text after closing quote");
                }
            } else {
                while (index < length && row.charAt(index) != ',') {
                    field.append(row.charAt(index));
                    index++;
                }
            }
            fields.add(field.toString());
            if (index >= length) {
                return fields;
            }
            index++;
        }
    }
}
