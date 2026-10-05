public class Main {
    public static boolean canAddItem(int currentItems, int maxItems, int requested) {
        if (requested < 1 || maxItems < 0 || currentItems < 0 || currentItems > maxItems) {
            return false;
        }
        return currentItems + requested <= maxItems;
    }
}
