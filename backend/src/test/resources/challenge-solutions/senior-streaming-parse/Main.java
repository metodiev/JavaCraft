import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> parseChunks(List<String> chunks, int maxChunkBytes) {
        if (chunks == null) {
            throw new IllegalArgumentException("chunks must not be null");
        }
        if (maxChunkBytes < 1) {
            throw new IllegalArgumentException("maxChunkBytes must be at least 1");
        }
        List<String> records = new ArrayList<>();
        StringBuilder pending = new StringBuilder();
        for (String chunk : chunks) {
            if (chunk == null) {
                throw new IllegalArgumentException("chunks must not contain null");
            }
            for (int i = 0; i < chunk.length(); i++) {
                char c = chunk.charAt(i);
                if (c == '\n') {
                    if (pending.length() > 0) {
                        records.add(pending.toString());
                    }
                    pending.setLength(0);
                } else {
                    pending.append(c);
                    if (pending.length() > maxChunkBytes) {
                        throw new IllegalArgumentException("record exceeds maxChunkBytes");
                    }
                }
            }
        }
        if (pending.length() > 0) {
            records.add(pending.toString());
        }
        return records;
    }
}
