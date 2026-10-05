import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> limits(long heapMb, int cores) {
        if (heapMb < 1) {
            throw new IllegalArgumentException("heapMb must be at least 1");
        }
        if (cores < 1) {
            throw new IllegalArgumentException("cores must be at least 1");
        }
        long overhead = (heapMb + 3) / 4;
        Map<String, String> result = new LinkedHashMap<>();
        result.put("memory", (heapMb + overhead) + "Mi");
        result.put("cpu", (cores * 1000L) + "m");
        return result;
    }
}
