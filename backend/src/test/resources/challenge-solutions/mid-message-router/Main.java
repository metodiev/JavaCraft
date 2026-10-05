import java.util.List;
import java.util.Map;

public class Main {
    public static String channelFor(String messageType, Map<String, List<String>> routing) {
        if (messageType != null && routing != null) {
            for (Map.Entry<String, List<String>> entry : routing.entrySet()) {
                List<String> accepted = entry.getValue();
                if (entry.getKey() != null && accepted != null && accepted.contains(messageType)) {
                    return entry.getKey();
                }
            }
        }
        return "default";
    }
}
