public class Main {
    public static int limit(int dependencyCapacity, int dependencies, int reservePercent) {
        if (dependencyCapacity < 1) {
            throw new IllegalArgumentException("dependencyCapacity must be positive");
        }
        if (dependencies < 1) {
            throw new IllegalArgumentException("at least one dependency is required");
        }
        if (reservePercent < 0 || reservePercent > 99) {
            throw new IllegalArgumentException("reservePercent must be 0..99");
        }
        int usable = (int) ((long) dependencyCapacity * (100 - reservePercent) / 100);
        return Math.max(1, usable / dependencies);
    }
}
