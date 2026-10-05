public class Main {
    public static int partitions(long rows, int chunkSize, int targetWorkers) {
        if (rows < 0 || chunkSize < 1 || targetWorkers < 1) {
            throw new IllegalArgumentException("rows must be non-negative and sizes must be positive");
        }
        if (rows == 0) {
            return 0;
        }
        long chunks = (rows - 1) / chunkSize + 1;
        return (int) Math.min((long) targetWorkers, chunks);
    }
}
