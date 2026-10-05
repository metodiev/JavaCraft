import java.util.*;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletableFuture;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("returns the completed value", () -> Main.valueOr(CompletableFuture.completedFuture("ok"), "fallback").equals("ok"));
        t.put("a null future yields the fallback", () -> Main.valueOr(null, "fallback").equals("fallback"));
        t.put("a failed future yields the fallback", () -> Main.valueOr(CompletableFuture.failedFuture(new IllegalStateException("boom")), "fallback").equals("fallback"));
        t.put("an exceptionally completed future yields the fallback", () -> {
            CompletableFuture<String> future = new CompletableFuture<>();
            future.completeExceptionally(new RuntimeException("boom"));
            return Main.valueOr(future, "fallback").equals("fallback");
        });
        t.put("an incomplete future yields the fallback without blocking", () -> Main.valueOr(new CompletableFuture<>(), "fallback").equals("fallback"));
        t.put("a null completed value yields the fallback", () -> Main.valueOr(CompletableFuture.completedFuture(null), "fallback").equals("fallback"));
        t.put("a cancelled future yields the fallback", () -> {
            CompletableFuture<String> future = new CompletableFuture<>();
            future.cancel(false);
            return Main.valueOr(future, "fallback").equals("fallback");
        });
        t.put("a present value wins over the fallback", () -> Main.valueOr(CompletableFuture.completedFuture("v"), "fallback").equals("v"));
        return t;
    }
}
