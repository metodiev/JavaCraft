public class Main {
    private static final int ROW_LIMIT = 1000;

    public static String fetchFor(boolean neededEveryTime, boolean collection, int rowsExpected) {
        if (!neededEveryTime) {
            return "LAZY";
        }
        if (!collection) {
            return "EAGER";
        }
        return rowsExpected <= ROW_LIMIT ? "JOIN FETCH" : "LAZY";
    }
}
