public class Main {
    public static String verdict(boolean sequentialScan, long rowsScanned, long rowsReturned, boolean indexAvailable) {
        if (rowsScanned < 0 || rowsReturned < 0 || rowsReturned > rowsScanned) {
            throw new IllegalArgumentException("invalid row counts");
        }
        if (!sequentialScan) {
            return "INDEX_SCAN";
        }
        if (rowsScanned < 1000) {
            return "SMALL_TABLE";
        }
        if (rowsReturned * 2 >= rowsScanned) {
            return "FULL_SCAN";
        }
        return indexAvailable ? "STALE_STATISTICS" : "MISSING_INDEX";
    }
}
