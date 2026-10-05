public class Main {
    public static int admit(int permits, int waiting, int maxQueue) {
        if (permits < 0 || waiting < 0 || maxQueue < 0) {
            throw new IllegalArgumentException("permits, waiting, and maxQueue must not be negative");
        }
        return Math.min(Math.min(permits, waiting), maxQueue);
    }
}
