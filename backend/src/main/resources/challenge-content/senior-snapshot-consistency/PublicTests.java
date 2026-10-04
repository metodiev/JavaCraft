import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equal versions are one snapshot", () -> Main.sameSnapshot(List.of(5L, 5L, 5L)));
        t.put("different versions are not", () -> !Main.sameSnapshot(List.of(5L, 6L)));
        t.put("empty or null is not a snapshot", () -> !Main.sameSnapshot(List.of()) && !Main.sameSnapshot(null));
        t.put("null version is not a snapshot", () -> !Main.sameSnapshot(Arrays.asList(1L, null)));
        t.put("consistent reads return values in order", () -> Main.consistentRead(List.of(
                new Main.VersionedValue<>(3, "a"), new Main.VersionedValue<>(3, "b"))).equals(Optional.of(List.of("a", "b"))));
        t.put("mixed versions return empty", () -> Main.consistentRead(List.of(
                new Main.VersionedValue<>(3, "a"), new Main.VersionedValue<>(4, "b"))).isEmpty());
        t.put("empty reads return empty", () -> Main.consistentRead(List.of()).isEmpty());
        return t;
    }
}
