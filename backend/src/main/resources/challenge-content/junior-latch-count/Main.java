public class Main {
    public static int latchCount(int workers, int alreadyDone) {
        // TODO: clamp the remaining count into [0, workers]
        return workers - alreadyDone;
    }
}
