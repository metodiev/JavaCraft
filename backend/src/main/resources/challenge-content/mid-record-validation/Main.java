public class Main {
    public record Range(int low, int high) {
        public static Range of(int low, int high) {
            // TODO: reject low > high before constructing the range
            return new Range(low, high);
        }

        public boolean contains(int value) {
            // TODO: report whether value is inside the inclusive range
            return false;
        }
    }
}
