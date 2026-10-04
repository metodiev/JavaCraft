public class Main {
    public enum Level { STRONG, BOUNDED_STALENESS, EVENTUAL }

    public static Level forOperation(Boolean invariantCritical, Boolean staleReadAcceptable) {
        if (invariantCritical == null || invariantCritical) {
            return Level.STRONG;
        }
        return Boolean.TRUE.equals(staleReadAcceptable) ? Level.EVENTUAL : Level.BOUNDED_STALENESS;
    }
}
