public class Main {
    public static String chooseThreadType(boolean ioBound, boolean longCpuBound, boolean usesThreadLocalHeavily, long tasksPerSecond) {
        if (longCpuBound || usesThreadLocalHeavily) {
            return "platform";
        }
        if (ioBound && tasksPerSecond >= 1000) {
            return "virtual";
        }
        return "platform";
    }
}
