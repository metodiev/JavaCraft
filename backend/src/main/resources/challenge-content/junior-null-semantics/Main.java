public class Main {
    public static Boolean equalsFilter(Integer stored, Integer requested) {
        // TODO: mirror SQL three-valued logic for NULL comparisons
        return stored.equals(requested);
    }
}
