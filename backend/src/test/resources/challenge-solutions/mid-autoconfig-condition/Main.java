public class Main {
    public static String decision(boolean missingBean, boolean propertyEnabled, boolean classPresent) {
        if (!classPresent) {
            return "BACK_OFF";
        }
        if (!propertyEnabled) {
            return "BACK_OFF";
        }
        if (!missingBean) {
            return "SKIP";
        }
        return "CREATE";
    }
}
