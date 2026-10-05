public class Main {
    public static String choose(boolean ioBound, boolean streamingSource, boolean teamKnowsReactor, int fanOut) {
        if (fanOut < 0) {
            throw new IllegalArgumentException("fanOut must not be negative");
        }
        if (streamingSource) {
            return "reactive";
        }
        if (ioBound && teamKnowsReactor && fanOut >= 1000) {
            return "reactive";
        }
        return "virtual-threads";
    }
}
