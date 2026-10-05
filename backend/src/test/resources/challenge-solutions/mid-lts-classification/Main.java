public class Main {
    public static boolean isLts(int featureVersion) {
        if (featureVersion == 8 || featureVersion == 11) {
            return true;
        }
        return featureVersion >= 17 && (featureVersion - 17) % 4 == 0;
    }
}
