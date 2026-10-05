public class Main {
    public static String scopeFor(boolean holdsMutableState, boolean expensiveToCreate, boolean requestScoped) {
        if (requestScoped) {
            return "request";
        }
        if (holdsMutableState) {
            return "prototype";
        }
        return "singleton";
    }
}
