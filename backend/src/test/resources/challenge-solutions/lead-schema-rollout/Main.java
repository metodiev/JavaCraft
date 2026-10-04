public class Main {
    public enum Phase { EXPAND, MIGRATE, CONTRACT }

    public static boolean mayRemoveOldField(Phase phase, int oldWriters, boolean backfillComplete,
                                            boolean allReadersSwitched) {
        return phase == Phase.CONTRACT && oldWriters == 0 && backfillComplete && allReadersSwitched;
    }
}
