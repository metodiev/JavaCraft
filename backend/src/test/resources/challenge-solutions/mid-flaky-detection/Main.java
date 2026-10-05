import java.util.List;

public class Main {
    public static boolean flaky(List<Boolean> historicalResults) {
        if (historicalResults == null || historicalResults.size() < 2) {
            return false;
        }
        boolean sawPass = false;
        boolean sawFailure = false;
        for (Boolean result : historicalResults) {
            if (result == null) {
                return false;
            }
            if (result) {
                sawPass = true;
            } else {
                sawFailure = true;
            }
        }
        return sawPass && sawFailure;
    }
}
