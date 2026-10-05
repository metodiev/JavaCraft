public class Main {
    public static boolean readValid(long stampBefore, long stampAfter, boolean writeObserved) {
        return stampBefore == stampAfter && !writeObserved;
    }
}
