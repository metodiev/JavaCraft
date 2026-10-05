import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> translate(Map<String, Object> external, Map<String, String> fieldMap) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (external == null || fieldMap == null) {
            return result;
        }
        for (Map.Entry<String, String> mapping : fieldMap.entrySet()) {
            String externalName = mapping.getKey();
            String internalName = mapping.getValue();
            if (externalName == null || internalName == null || internalName.isBlank()) {
                continue;
            }
            if (!external.containsKey(externalName) || result.containsKey(internalName)) {
                continue;
            }
            result.put(internalName, external.get(externalName));
        }
        return result;
    }
}
