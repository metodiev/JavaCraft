public class Main {
    public record Range(int low, int high) {
        public Range {
            if (low > high) {
                throw new IllegalArgumentException("low must not exceed high");
            }
        }

        public static Range of(int low, int high) {
            return new Range(low, high);
        }

        public boolean contains(int value) {
            return value >= low && value <= high;
        }
    }
}
