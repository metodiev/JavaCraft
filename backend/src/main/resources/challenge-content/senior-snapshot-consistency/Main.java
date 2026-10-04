import java.util.List;
import java.util.Optional;

public class Main {
    public record VersionedValue<T>(long version, T value) {}

    public static boolean sameSnapshot(List<Long> versions) {
        // TODO: all versions must match
        return true;
    }

    public static <T> Optional<List<T>> consistentRead(List<VersionedValue<T>> reads) {
        // TODO: return values only if every read saw the same version
        return Optional.empty();
    }
}
