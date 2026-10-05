import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class Main {
    public static List<String> violations(String sql) {
        if (sql == null || sql.isBlank()) {
            return List.of();
        }
        Map<Integer, String> found = new TreeMap<>();
        int plus = sql.indexOf('+');
        if (plus >= 0) {
            found.put(plus, "string concatenation");
        }
        int orderBy = unsafeOrderBy(sql);
        if (orderBy >= 0) {
            found.put(orderBy, "unsafe ORDER BY interpolation");
        }
        int comment = commentMarker(sql);
        if (comment >= 0) {
            found.put(comment, "comment injection marker");
        }
        return new ArrayList<>(found.values());
    }

    private static int unsafeOrderBy(String sql) {
        String lower = sql.toLowerCase(java.util.Locale.ROOT);
        int from = 0;
        while (true) {
            int idx = lower.indexOf("order by", from);
            if (idx < 0) {
                return -1;
            }
            int start = idx + "order by".length();
            int end = sql.length();
            int semi = sql.indexOf(';', start);
            if (semi >= 0) {
                end = semi;
            }
            int next = lower.indexOf("order by", start);
            if (next >= 0 && next < end) {
                end = next;
            }
            if (isUnsafeTail(sql.substring(start, end))) {
                return idx;
            }
            from = start;
        }
    }

    private static boolean isUnsafeTail(String tail) {
        for (int i = 0; i < tail.length(); i++) {
            char c = tail.charAt(i);
            if (c == '?' || c == '\'' || c == '"' || c == '(' || c == '+' || c == '%' || c == '$') {
                return true;
            }
        }
        return false;
    }

    private static int commentMarker(String sql) {
        int dash = sql.indexOf("--");
        int slash = sql.indexOf("/*");
        if (dash < 0) {
            return slash;
        }
        if (slash < 0) {
            return dash;
        }
        return Math.min(dash, slash);
    }
}
