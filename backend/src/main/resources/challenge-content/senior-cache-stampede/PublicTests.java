import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("concurrent refreshes share one load", () -> {
            ConcurrentHashMap<String, CompletableFuture<String>> inFlight = new ConcurrentHashMap<>();
            int[] loads = {0};
            CompletableFuture<String> pending = new CompletableFuture<>();
            Supplier<CompletableFuture<String>> loader = () -> { loads[0]++; return pending; };
            CompletableFuture<String> a = Main.refresh(inFlight, "k", loader);
            CompletableFuture<String> b = Main.refresh(inFlight, "k", loader);
            pending.complete("v");
            return loads[0] == 1 && a.get().equals("v") && b.get().equals("v");
        });
        t.put("different keys load separately", () -> {
            ConcurrentHashMap<String, CompletableFuture<String>> inFlight = new ConcurrentHashMap<>();
            int[] loads = {0};
            Supplier<CompletableFuture<String>> loader = () -> { loads[0]++; return new CompletableFuture<>(); };
            Main.refresh(inFlight, "a", loader);
            Main.refresh(inFlight, "b", loader);
            return loads[0] == 2;
        });
        t.put("completed load is removed so the next refresh reloads", () -> {
            ConcurrentHashMap<String, CompletableFuture<String>> inFlight = new ConcurrentHashMap<>();
            int[] loads = {0};
            Supplier<CompletableFuture<String>> loader = () -> { loads[0]++; return CompletableFuture.completedFuture("v"); };
            Main.refresh(inFlight, "k", loader);
            Main.refresh(inFlight, "k", loader);
            return loads[0] == 2 && inFlight.isEmpty();
        });
        t.put("failed load is removed too", () -> {
            ConcurrentHashMap<String, CompletableFuture<String>> inFlight = new ConcurrentHashMap<>();
            CompletableFuture<String> failed = Main.refresh(inFlight, "k", () -> CompletableFuture.failedFuture(new IllegalStateException("x")));
            return failed.isCompletedExceptionally() && inFlight.isEmpty();
        });
        return t;
    }
}
