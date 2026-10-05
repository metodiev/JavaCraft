import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> signals(boolean mainFails, boolean fallbackAvailable) {
        List<String> trace = new ArrayList<>();
        trace.add("onErrorResume");
        if (!mainFails) {
            trace.add("next:main");
            trace.add("complete");
            return trace;
        }
        trace.add("error:main");
        if (fallbackAvailable) {
            trace.add("next:fallback");
        }
        trace.add("complete");
        return trace;
    }
}
