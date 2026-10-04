public class Main {
    public static boolean isNext(long previousSequence, long candidateSequence) {
        // TODO: accept only the immediately following sequence number
        return candidateSequence > previousSequence;
    }
}
