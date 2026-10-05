import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> recombine(List<List<String>> chunks, String correlationId) {
        List<String> payloads = new ArrayList<>();
        if (chunks == null || correlationId == null) {
            return payloads;
        }
        for (List<String> chunk : chunks) {
            if (chunk == null || chunk.isEmpty() || !correlationId.equals(chunk.get(0))) {
                continue;
            }
            for (int i = 1; i < chunk.size(); i++) {
                payloads.add(chunk.get(i));
            }
        }
        return payloads;
    }
}
