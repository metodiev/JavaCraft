public class Main {
    public static String chooseReturnType(boolean needsTotalCount, boolean largeTable, boolean infiniteScroll) {
        // TODO: return "Page" when the total count is required or cheap,
        // and "Slice" when a large table or infinite scroll only needs the next-page check.
        return "Page";
    }
}
