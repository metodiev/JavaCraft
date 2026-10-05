import java.util.*;

public class Main {
    public static String normalise(String path) {
        if (path == null || path.isBlank()) {
            return "/";
        }
        String input = path.trim();
        String tail = "";
        int cut = indexOfAny(input, '?', '#');
        if (cut >= 0) {
            tail = input.substring(cut);
            input = input.substring(0, cut);
        }
        Deque<String> segments = new ArrayDeque<>();
        for (String segment : input.split("/")) {
            if (segment.isEmpty() || segment.equals(".")) {
                continue;
            }
            if (segment.equals("..")) {
                if (!segments.isEmpty()) {
                    segments.removeLast();
                }
            } else {
                segments.addLast(segment);
            }
        }
        StringBuilder out = new StringBuilder("/");
        boolean first = true;
        for (String segment : segments) {
            if (!first) {
                out.append('/');
            }
            out.append(segment);
            first = false;
        }
        return out.append(tail).toString();
    }

    private static int indexOfAny(String value, char a, char b) {
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (c == a || c == b) {
                return i;
            }
        }
        return -1;
    }
}
