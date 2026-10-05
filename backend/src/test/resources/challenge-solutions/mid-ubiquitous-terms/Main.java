import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> inconsistencies(Map<String, String> codeNames, Map<String, String> glossary) {
        List<String> result = new ArrayList<>();
        if (codeNames == null || glossary == null) {
            return result;
        }
        List<String> concepts = new ArrayList<>();
        for (String concept : codeNames.keySet()) {
            if (concept != null && glossary.containsKey(concept)) {
                concepts.add(concept);
            }
        }
        concepts.sort(String::compareTo);
        for (String concept : concepts) {
            String code = codeNames.get(concept) == null ? "" : codeNames.get(concept).trim();
            String agreed = glossary.get(concept) == null ? "" : glossary.get(concept).trim();
            if (!code.equalsIgnoreCase(agreed)) {
                result.add(concept + ": code uses '" + code + "' but glossary says '" + agreed + "'");
            }
        }
        return result;
    }
}
