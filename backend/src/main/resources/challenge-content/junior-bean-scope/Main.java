public class Main {
    public static String scopeFor(boolean holdsMutableState, boolean expensiveToCreate, boolean requestScoped) {
        // TODO: choose the documented scope instead of always returning the default
        return "singleton";
    }
}
