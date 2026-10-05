public class Main {
    public static String lifecycleFor(boolean needsMutableState, int testCount, long startupSeconds) {
        if (needsMutableState) {
            return "PER_TEST";
        }
        if (testCount >= 3 && startupSeconds >= 10) {
            return "PER_CLASS";
        }
        if (testCount >= 5 && startupSeconds >= 2) {
            return "PER_CLASS";
        }
        return "PER_METHOD";
    }
}
