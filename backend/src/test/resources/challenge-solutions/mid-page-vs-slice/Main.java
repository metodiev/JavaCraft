public class Main {
    private static final String PAGE = "Page";
    private static final String SLICE = "Slice";

    public static String chooseReturnType(boolean needsTotalCount, boolean largeTable, boolean infiniteScroll) {
        if (needsTotalCount) {
            return PAGE;
        }
        if (largeTable || infiniteScroll) {
            return SLICE;
        }
        return PAGE;
    }
}
