import java.util.*;

public class Main {
    public static Map<String, String> parseFilters(String query) {
        // TODO: decode every key=value pair and ignore blanks and duplicates
        Map<String, String> filters = new HashMap<>();
        if (query == null) {
            return filters;
        }
        for (String pair : query.split("&")) {
            String[] parts = pair.split("=");
            if (parts.length == 2) {
                filters.put(parts[0], parts[1]);
            }
        }
        return filters;
    }
}
