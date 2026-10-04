import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class Main {
    public record VersionedValue<T>(long version, T value) {}

    public static boolean sameSnapshot(List<Long> versions) {
        if (versions == null || versions.isEmpty()) {
            return false;
        }
        Long first = versions.get(0);
        if (first == null) {
            return false;
        }
        for (Long version : versions) {
            if (!first.equals(version)) {
                return false;
            }
        }
        return true;
    }

    public static <T> Optional<List<T>> consistentRead(List<VersionedValue<T>> reads) {
        if (reads == null || reads.isEmpty()) {
            return Optional.empty();
        }
        long version = reads.get(0).version();
        List<T> values = new ArrayList<>();
        for (VersionedValue<T> read : reads) {
            if (read.version() != version) {
                return Optional.empty();
            }
            values.add(read.value());
        }
        return Optional.of(values);
    }
}
