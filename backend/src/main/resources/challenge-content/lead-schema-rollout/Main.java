public class Main {
    public enum Phase { EXPAND, MIGRATE, CONTRACT }

    public static boolean mayRemoveOldField(Phase phase, int oldWriters, boolean backfillComplete,
                                            boolean allReadersSwitched) {
        // TODO: only contract when it is provably safe
        return true;
    }
}
