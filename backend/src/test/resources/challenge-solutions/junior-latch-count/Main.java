public class Main {
    public static int latchCount(int workers, int alreadyDone) {
        if (workers < 0) {
            throw new IllegalArgumentException("workers must not be negative");
        }
        if (alreadyDone < 0) {
            alreadyDone = 0;
        }
        int remaining = workers - alreadyDone;
        return Math.max(remaining, 0);
    }
}
