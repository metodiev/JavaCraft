import java.util.List;

public class Main {
    public static List<String> contractMethods(boolean needsLookupById, boolean needsSave, boolean needsQueryByOwner) {
        // TODO: return only the domain-language methods this aggregate really needs,
        // in the order findById, save, findByOwner
        return List.of("selectById", "insert", "selectByOwner");
    }
}
