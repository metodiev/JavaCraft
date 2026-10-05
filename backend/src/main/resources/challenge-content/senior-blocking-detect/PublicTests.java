import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a pipeline without blocking calls reports nothing", () -> Main.blockingLines(List.of(
                "Flux<Order> orders = repository.findAll()",
                "        .map(this::enrich)",
                "        .filter(Order::isOpen);")).isEmpty());
        t.put("a terminal block call is flagged", () -> Main.blockingLines(List.of(
                "Order order = service.load(id)",
                "        .block();")).equals(List.of(2)));
        t.put("sleeping inside an operator is flagged", () -> Main.blockingLines(List.of(
                "return Flux.just(id)",
                "        .map(value -> { Thread.sleep(50); return value; })",
                "        .subscribe();")).equals(List.of(2)));
        t.put("flags are returned in ascending order", () -> Main.blockingLines(List.of(
                "value.block();",
                "Flux.just(1).map(v -> v)",
                "other.blockLast();")).equals(List.of(1, 3)));
        t.put("a commented blocking call is ignored", () -> Main.blockingLines(List.of(
                "// value.block();",
                "        // awaitTermination(1, SECONDS);",
                "value.blockFirst();")).equals(List.of(3)));
        t.put("a line is reported once", () -> Main.blockingLines(List.of(
                "value.block().blockLast();")).equals(List.of(1)));
        t.put("a null pipeline is rejected", () -> rejects(null));
        t.put("a null line is rejected", () -> rejects(Arrays.asList("a", null)));
        return t;
    }

    private static boolean rejects(List<String> pipeline) {
        try {
            Main.blockingLines(pipeline);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
