import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> inconsistencies(Map<String, String> codeNames, Map<String, String> glossary) {
        // TODO: report every concept whose code name differs from the glossary,
        // ignoring case and surrounding spaces, sorted by concept
        List<String> result = new ArrayList<>();
        if (codeNames == null || glossary == null) {
            return result;
        }
        for (String concept : codeNames.keySet()) {
            if (glossary.containsKey(concept)) {
                result.add(concept + ": code uses '" + codeNames.get(concept)
                        + "' but glossary says '" + glossary.get(concept) + "'");
            }
        }
        return result;
    }
}
