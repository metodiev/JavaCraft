public class Main {
    public static String policy(boolean canDrop, boolean mustBeLossless, boolean slowConsumer) {
        if (mustBeLossless) {
            return "BUFFER";
        }
        if (!canDrop) {
            return "ERROR";
        }
        return slowConsumer ? "DROP_OLDEST" : "DROP_LATEST";
    }
}
