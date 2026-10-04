public class Main {
    public enum Level { STRONG, BOUNDED_STALENESS, EVENTUAL }

    public static Level forOperation(Boolean invariantCritical, Boolean staleReadAcceptable) {
        // TODO: choose the weakest safe level, defaulting to the safest
        return Level.EVENTUAL;
    }
}
