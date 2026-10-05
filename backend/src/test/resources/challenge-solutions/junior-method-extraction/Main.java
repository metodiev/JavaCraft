public class Main {
    public static boolean shouldExtract(int lines, int distinctResponsibilityCount, int usedVariables) {
        if (lines <= 6) {
            return false;
        }
        return distinctResponsibilityCount >= 2 || lines > 20 || usedVariables >= 8;
    }
}
