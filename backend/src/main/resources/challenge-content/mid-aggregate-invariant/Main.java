public class Main {
    public static boolean canAddItem(int currentItems, int maxItems, int requested) {
        // TODO: allow only a positive request that still fits inside the aggregate invariant
        return requested > 0;
    }
}
