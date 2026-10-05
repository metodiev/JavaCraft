import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a successful main sequence completes without the fallback", () -> Main.signals(false, true)
                .equals(List.of("onErrorResume", "next:main", "complete")));
        t.put("a main failure is replaced by the fallback value", () -> Main.signals(true, true)
                .equals(List.of("onErrorResume", "error:main", "next:fallback", "complete")));
        t.put("an unavailable fallback completes empty after the error", () -> Main.signals(true, false)
                .equals(List.of("onErrorResume", "error:main", "complete")));
        t.put("success ignores an available fallback", () -> Main.signals(false, false)
                .equals(List.of("onErrorResume", "next:main", "complete")));
        t.put("the trace starts with the operator", () -> Main.signals(true, true).get(0).equals("onErrorResume"));
        t.put("the error signal precedes the fallback value", () -> {
            List<String> signals = Main.signals(true, true);
            return signals.indexOf("error:main") < signals.indexOf("next:fallback");
        });
        t.put("a failure without a fallback never emits a fallback value", () ->
                !Main.signals(true, false).contains("next:fallback"));
        return t;
    }
}
