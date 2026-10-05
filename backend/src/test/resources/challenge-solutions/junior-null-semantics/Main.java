public class Main {
    public static Boolean equalsFilter(Integer stored, Integer requested) {
        if (stored == null || requested == null) {
            return null;
        }
        return stored.equals(requested);
    }
}
