public class Main {
    public static boolean isNext(long previousSequence, long candidateSequence) {
        if (previousSequence < 0) {
            throw new IllegalArgumentException("previous sequence must not be negative");
        }
        return previousSequence != Long.MAX_VALUE && candidateSequence == previousSequence + 1;
    }
}
