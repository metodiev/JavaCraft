UPDATE challenge
SET description = 'Count whitespace-delimited words in a sentence while handling blank input and repeated whitespace.'
WHERE slug = 'junior-string-analyzer';

UPDATE challenge
SET starter_repository = jsonb_set(
    starter_repository,
    '{Main.java}',
    to_jsonb($code$public class Main {
    private final int capacity;
    private int available;

    public Main(int capacity) {
        // TODO: reject negative capacity and initialize both fields
        this.capacity = capacity;
    }

    public boolean checkout() {
        // TODO: decrement only when a copy is available
        return false;
    }

    public boolean returnCopy() {
        // TODO: increment only below the original capacity
        return false;
    }

    public int availableCopies() {
        return available;
    }
}
$code$::text),
    true
)
WHERE slug = 'junior-library-inventory';

UPDATE challenge
SET starter_repository = jsonb_set(
    starter_repository,
    '{Main.java}',
    to_jsonb($code$public class Main {
    private static final int MAX_PAGE_SIZE = 100;

    public record PageRequest(int page, int size) {}

    public static long offset(PageRequest request) {
        // TODO: enforce bounds before calculating the offset
        return 0;
    }
}
$code$::text),
    true
)
WHERE slug = 'mid-paginated-results';

UPDATE challenge
SET starter_repository = jsonb_set(
    starter_repository,
    '{Main.java}',
    to_jsonb($code$import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentMap;
import java.util.function.Supplier;

public class Main {
    public static CompletableFuture<String> refresh(
            ConcurrentMap<String, CompletableFuture<String>> inFlight, String key,
            Supplier<CompletableFuture<String>> loader) {
        // TODO: coordinate concurrent refreshes and clean up terminal entries
        Objects.requireNonNull(inFlight);
        Objects.requireNonNull(key);
        Objects.requireNonNull(loader);
        CompletableFuture<String> result = inFlight.computeIfAbsent(key, ignored -> loader.get());
        result.whenComplete((value, error) -> inFlight.remove(key, result));
        return result;
    }
}
$code$::text),
    true
)
WHERE slug = 'senior-cache-stampede';

UPDATE challenge
SET starter_repository = jsonb_set(
    starter_repository,
    '{Main.java}',
    to_jsonb($code$public class Main {
    public enum Phase { EXPAND, BACKFILL, SWITCH_READS, CONTRACT }

    public static boolean mayRemoveOldField(Phase phase, boolean oldWritersRemain,
                                            boolean backfillComplete,
                                            boolean allReadersSwitched) {
        // TODO: require all compatibility gates before the contract phase
        return false;
    }
}
$code$::text),
    true
)
WHERE slug = 'lead-schema-rollout';

UPDATE challenge_requirement r
SET description = requirement.description
FROM challenge c
JOIN (VALUES
    ('junior-string-analyzer', 1, 'Return zero for null or blank input and count whitespace-delimited words.'),
    ('junior-string-analyzer', 2, 'Do not count repeated whitespace as additional words.'),
    ('junior-string-analyzer', 3, 'Handle punctuation and non-ASCII letters without crashing.'),
    ('junior-grade-book', 2, 'Accept only non-null scores in the inclusive range zero through 100.'),
    ('mid-paginated-results', 1, 'Require a non-negative page and a size from one through 100.'),
    ('senior-cache-stampede', 1, 'Concurrent callers for one key share the same loader invocation and in-flight future.'),
    ('lead-schema-rollout', 2, 'Allow field removal only after backfill completion and all readers switch.')
) AS requirement(challenge_slug, sort_order, description)
    ON requirement.challenge_slug = c.slug
WHERE r.challenge_id = c.id
  AND r.sort_order = requirement.sort_order;
