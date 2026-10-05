public class Main {
    public static int maxValue(int[] weights, int[] values, int capacity) {
        if (weights == null || values == null || weights.length != values.length || capacity <= 0) {
            return 0;
        }
        int[] best = new int[capacity + 1];
        for (int item = 0; item < weights.length; item++) {
            int weight = weights[item];
            if (weight <= 0 || weight > capacity) {
                continue;
            }
            for (int room = capacity; room >= weight; room--) {
                best[room] = Math.max(best[room], best[room - weight] + values[item]);
            }
        }
        return best[capacity];
    }
}
