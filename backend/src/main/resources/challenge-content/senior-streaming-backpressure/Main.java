public class Main {
    public static long requested(long consumerDemand, long buffered, long limit) {
        // TODO: clamp the demand to the remaining buffer capacity, never negative
        return consumerDemand;
    }
}
