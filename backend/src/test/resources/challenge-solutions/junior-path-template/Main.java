import java.util.List;

public class Main {
    public static String path(String base, List<String> segments) {
        StringBuilder out = new StringBuilder();
        append(out, base);
        if (segments != null) {
            for (String segment : segments) {
                append(out, segment);
            }
        }
        return out.length() == 0 ? "/" : out.toString();
    }

    private static void append(StringBuilder out, String raw) {
        if (raw == null) {
            return;
        }
        for (String piece : raw.trim().split("/")) {
            if (piece.isEmpty()) {
                continue;
            }
            StringBuilder part = new StringBuilder();
            for (int i = 0; i < piece.length(); i++) {
                char c = piece.charAt(i);
                if (c == ' ') {
                    part.append("%20");
                } else {
                    part.append(c);
                }
            }
            out.append('/').append(part);
        }
    }
}
