import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> contractMethods(boolean needsLookupById, boolean needsSave, boolean needsQueryByOwner) {
        List<String> methods = new ArrayList<>();
        if (needsLookupById) {
            methods.add("findById");
        }
        if (needsSave) {
            methods.add("save");
        }
        if (needsQueryByOwner) {
            methods.add("findByOwner");
        }
        return methods;
    }
}
