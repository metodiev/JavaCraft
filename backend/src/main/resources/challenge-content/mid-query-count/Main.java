public class Main {
    public static int totalQueries(int parents, int childQueriesPerParent, boolean batched, int batchSize) {
        // TODO: one query for the parents plus either N child queries or ceil(N / batchSize) batches
        return 1 + parents * childQueriesPerParent;
    }
}
