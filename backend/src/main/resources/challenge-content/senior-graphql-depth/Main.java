public class Main {
    public static int depth(String query) {
        // TODO: count the deepest selection set, ignoring braces inside strings and comments
        int max = 0;
        for (int i = 0; i < query.length(); i++) {
            if (query.charAt(i) == '{') {
                max++;
            }
        }
        return max;
    }
}
