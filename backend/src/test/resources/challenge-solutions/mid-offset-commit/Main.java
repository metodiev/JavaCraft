public class Main {
    public static String commitStrategy(boolean atLeastOnce, boolean exactlyOnce, boolean batchProcessing) {
        if (exactlyOnce) {
            return "TRANSACTIONAL";
        }
        if (atLeastOnce) {
            return batchProcessing ? "SYNC_AT_BATCH_BOUNDARY" : "SYNC_PER_RECORD";
        }
        return "AUTO_COMMIT";
    }
}
