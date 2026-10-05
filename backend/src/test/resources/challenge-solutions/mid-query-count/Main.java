public class Main {
    public static int totalQueries(int parents, int childQueriesPerParent, boolean batched, int batchSize) {
        if (parents < 0 || childQueriesPerParent < 1 || batchSize < 1) {
            throw new IllegalArgumentException("invalid query counts");
        }
        long childQueries = (long) parents * childQueriesPerParent;
        long total;
        if (batched) {
            total = 1 + (childQueries + batchSize - 1) / batchSize;
        } else {
            total = 1 + childQueries;
        }
        return (int) total;
    }
}
