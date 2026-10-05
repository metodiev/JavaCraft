public class Main {
    public static int depth(String query) {
        if (query == null || query.isBlank()) {
            return -1;
        }
        int level = 0;
        int max = 0;
        boolean inString = false;
        boolean block = false;
        for (int i = 0; i < query.length(); i++) {
            char c = query.charAt(i);
            if (inString) {
                if (block) {
                    if (c == '"' && i + 2 < query.length() && query.charAt(i + 1) == '"' && query.charAt(i + 2) == '"') {
                        inString = false;
                        i += 2;
                    }
                } else if (c == '\\') {
                    i++;
                } else if (c == '"') {
                    inString = false;
                }
                continue;
            }
            if (c == '#') {
                while (i < query.length() && query.charAt(i) != '\n') {
                    i++;
                }
            } else if (c == '"') {
                if (i + 2 < query.length() && query.charAt(i + 1) == '"' && query.charAt(i + 2) == '"') {
                    block = true;
                    inString = true;
                    i += 2;
                } else {
                    block = false;
                    inString = true;
                }
            } else if (c == '{') {
                level++;
                max = Math.max(max, level);
            } else if (c == '}') {
                level--;
                if (level < 0) {
                    return -1;
                }
            }
        }
        return inString || level != 0 ? -1 : max;
    }
}
