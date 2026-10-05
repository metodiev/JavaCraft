import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    private static final String[] PREFIXES = {
            "findBy", "readBy", "getBy", "queryBy", "searchBy", "streamBy", "countBy", "existsBy", "deleteBy"
    };

    private static final String[][] KEYWORDS = {
            {"GreaterThanEqual", "GREATER_THAN_EQUAL"},
            {"LessThanEqual", "LESS_THAN_EQUAL"},
            {"GreaterThan", "GREATER_THAN"},
            {"LessThan", "LESS_THAN"},
            {"StartingWith", "STARTING_WITH"},
            {"EndingWith", "ENDING_WITH"},
            {"Containing", "CONTAINING"},
            {"IsNotNull", "IS_NOT_NULL"},
            {"IsNull", "IS_NULL"},
            {"Like", "LIKE"},
    };

    public static String describe(String methodName) {
        if (methodName == null || methodName.isBlank()) {
            throw new IllegalArgumentException("method name is required");
        }
        String body = null;
        for (String prefix : PREFIXES) {
            if (methodName.startsWith(prefix)) {
                body = methodName.substring(prefix.length());
                break;
            }
        }
        if (body == null) {
            throw new IllegalArgumentException("no supported query prefix in " + methodName);
        }
        List<String> predicates = new ArrayList<>();
        List<String> connectors = new ArrayList<>();
        int start = 0;
        for (int i = 0; i < body.length(); i++) {
            String connector = null;
            if (body.startsWith("And", i)) {
                connector = "And";
            } else if (body.startsWith("Or", i)) {
                connector = "Or";
            }
            if (connector != null && i > start && i + connector.length() < body.length()
                    && Character.isUpperCase(body.charAt(i + connector.length()))) {
                predicates.add(predicate(body.substring(start, i)));
                connectors.add(connector.toUpperCase(Locale.ROOT));
                start = i + connector.length();
                i = start - 1;
            }
        }
        predicates.add(predicate(body.substring(start)));
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < predicates.size(); i++) {
            if (i > 0) {
                out.append(' ').append(connectors.get(i - 1)).append(' ');
            }
            out.append(predicates.get(i));
        }
        return out.toString();
    }

    private static String predicate(String token) {
        if (token.isEmpty()) {
            throw new IllegalArgumentException("empty criterion");
        }
        requireNoConnector(token);
        for (String[] keyword : KEYWORDS) {
            if (token.endsWith(keyword[0])) {
                String property = token.substring(0, token.length() - keyword[0].length());
                if (property.isEmpty()) {
                    throw new IllegalArgumentException("keyword without a property: " + token);
                }
                return lowerFirst(property) + " " + keyword[1];
            }
        }
        return lowerFirst(token) + " EQUALS";
    }

    private static void requireNoConnector(String token) {
        for (int i = 0; i + 2 <= token.length(); i++) {
            String connector = null;
            if (token.startsWith("And", i)) {
                connector = "And";
            } else if (token.startsWith("Or", i)) {
                connector = "Or";
            }
            if (connector != null) {
                boolean startsWord = i + connector.length() < token.length()
                        && Character.isUpperCase(token.charAt(i + connector.length()));
                boolean dangling = i + connector.length() == token.length();
                if (startsWord || dangling) {
                    throw new IllegalArgumentException("unexpected connector in " + token);
                }
            }
        }
    }

    private static String lowerFirst(String property) {
        if (property.isEmpty()) {
            throw new IllegalArgumentException("empty property");
        }
        return Character.toLowerCase(property.charAt(0)) + property.substring(1);
    }
}
