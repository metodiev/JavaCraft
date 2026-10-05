import java.util.List;

public class Main {
    public static final long SERIES_LIMIT = 10_000;

    public static long cardinality(List<Integer> tagSizes) {
        if (tagSizes == null) {
            throw new IllegalArgumentException("tagSizes must not be null");
        }
        for (Integer size : tagSizes) {
            if (size == null || size < 0) {
                throw new IllegalArgumentException("tag size must not be null or negative");
            }
            if (size == 0) {
                return 0;
            }
        }
        long result = 1L;
        for (int size : tagSizes) {
            if (result > Long.MAX_VALUE / size) {
                return Long.MAX_VALUE;
            }
            result *= size;
        }
        return result;
    }

    public static boolean risky(List<Integer> tagSizes) {
        return cardinality(tagSizes) > SERIES_LIMIT;
    }
}
