public class Main {
    public static String impact(int partitions, int consumers, boolean cooperative, boolean statefulConsumer) {
        if (partitions < 1 || consumers < 1) {
            return "INVALID";
        }
        if (consumers > partitions) {
            return "IDLE_CONSUMERS";
        }
        if (cooperative) {
            return statefulConsumer ? "MODERATE" : "MINIMAL";
        }
        return statefulConsumer ? "SEVERE" : "HIGH";
    }
}
