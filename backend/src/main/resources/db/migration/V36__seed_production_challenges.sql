-- V36 - Seed production challenges across every level and subject section.
--
-- Content files (starter, requirements, public tests, reference solutions) live under
-- challenge-content/ and test/resources/challenge-solutions/; this migration registers the
-- challenge metadata, requirements, skills and the tutorial that teaches the topic.
-- R__Challenge_content re-syncs starter code and the runnable test bundle afterwards.

CREATE TABLE tutorial_challenge (
    tutorial_id UUID NOT NULL REFERENCES tutorial (id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenge (id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL CHECK (sort_order > 0),
    PRIMARY KEY (tutorial_id, challenge_id)
);

CREATE INDEX tutorial_challenge_challenge_idx ON tutorial_challenge (challenge_id);

INSERT INTO challenge (slug, title, description, level, difficulty, category,
                       starter_repository, time_limit_seconds, memory_limit_mb, published)
VALUES
    ('junior-vowel-counter', 'Count Vowels in a Sentence', 'Count Vowels in a Sentence - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public static int countVowels(String text) {
        // TODO: count every lowercase and uppercase vowel, and return 0 for null or blank input
        return 0;
    }
}
'), 10, 256, true),
    ('junior-palindrome-phrase', 'Detect a Palindrome Phrase', 'Detect a Palindrome Phrase - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public static boolean isPalindrome(String text) {
        // TODO: ignore case, spaces and punctuation, and return false for null or blank input
        return false;
    }
}
'), 10, 256, true),
    ('junior-title-case', 'Convert Text to Title Case', 'Convert Text to Title Case - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public static String toTitleCase(String text) {
        // TODO: capitalise each word, collapse repeated spaces, and return an empty string for null
        return text == null ? "" : text;
    }
}
'), 10, 256, true),
    ('junior-number-grouping', 'Format Large Numbers with Grouping', 'Format Large Numbers with Grouping - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public static String groupDigits(long value) {
        // TODO: insert a comma every three digits, keeping the minus sign for negatives
        return Long.toString(value);
    }
}
'), 10, 256, true),
    ('junior-dedupe-preserving-order', 'Remove Duplicates but Keep Order', 'Remove Duplicates but Keep Order - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> uniqueInOrder(List<String> values) {
        // TODO: drop later duplicates, keep the first occurrence, and ignore null entries
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-map-merge-sum', 'Merge Two Maps by Summing Values', 'Merge Two Maps by Summing Values - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Integer> mergeSums(Map<String, Integer> left, Map<String, Integer> right) {
        // TODO: sum values from both maps, treating missing keys as zero and never returning null
        return null;
    }
}
'), 10, 256, true),
    ('junior-null-safe-join', 'Join Non-Blank Parts Safely', 'Join Non-Blank Parts Safely - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String joinNonBlank(List<String> parts, String separator) {
        // TODO: trim each part, skip null or blank parts, and never return null
        return null;
    }
}
'), 10, 256, true),
    ('junior-enum-from-text', 'Parse an Enum with a Fallback', 'Parse an Enum with a Fallback - practise the Java Core section with a runnable exercise.', 'Junior', 'Junior', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public enum Priority {
        LOW, NORMAL, HIGH
    }

    public static Priority parsePriority(String text) {
        // TODO: match the name case-insensitively and fall back to NORMAL for unknown or null text
        return Priority.NORMAL;
    }
}
'), 10, 256, true),
    ('mid-generic-max', 'Bounded Generic Maximum', 'Bounded Generic Maximum - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Optional;

public class Main {
    public static <T extends Comparable<T>> Optional<T> max(List<T> values) {
        // TODO: find the largest value, ignoring null entries, and return empty for empty or null lists
        return Optional.empty();
    }
}
'), 10, 256, true),
    ('mid-stream-group-count', 'Group and Count with Streams', 'Group and Count with Streams - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<Character, Long> countByInitial(List<String> words) {
        // TODO: group by the lowercased first letter and count, skipping null and blank words
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-record-validation', 'Validating Record Value Object', 'Validating Record Value Object - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public record Range(int low, int high) {
        public static Range of(int low, int high) {
            // TODO: reject low > high before constructing the range
            return new Range(low, high);
        }

        public boolean contains(int value) {
            // TODO: report whether value is inside the inclusive range
            return false;
        }
    }
}
'), 10, 256, true),
    ('mid-nested-optional-lookup', 'Chain Nested Optional Lookups', 'Chain Nested Optional Lookups - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'import java.util.Map;
import java.util.Optional;

public class Main {
    public static Optional<String> cityOf(Map<String, Map<String, String>> directory, String tenant, String user) {
        // TODO: chain the two lookups and never throw on null input
        return Optional.empty();
    }
}
'), 10, 256, true),
    ('mid-immutable-builder', 'Immutable Object Builder', 'Immutable Object Builder - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static final class ServerConfig {
        private final String host;
        private final int port;
        private final List<String> tags;

        private ServerConfig(Builder builder) {
            this.host = builder.host;
            this.port = builder.port;
            this.tags = builder.tags;
        }

        public String host() {
            return host;
        }

        public int port() {
            return port;
        }

        public List<String> tags() {
            return tags;
        }

        public static Builder builder() {
            return new Builder();
        }

        // TODO: reject a missing host, a non-positive port and a missing port, and keep a defensive copy of the tags
        public static final class Builder {
            private String host;
            private int port;
            private List<String> tags = List.of();

            public Builder host(String host) {
                this.host = host;
                return this;
            }

            public Builder port(int port) {
                this.port = port;
                return this;
            }

            public Builder tag(String tag) {
                this.tags = List.of(tag);
                return this;
            }

            public ServerConfig build() {
                return new ServerConfig(this);
            }
        }
    }
}
'), 10, 256, true),
    ('mid-multikey-comparator', 'Multi-Key Comparator with Nulls', 'Multi-Key Comparator with Nulls - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'import java.util.Comparator;

public class Main {
    public static Comparator<String> byLengthThenText() {
        // TODO: sort by length, then by natural order, with null entries last
        return null;
    }
}
'), 10, 256, true),
    ('mid-sealed-outcome', 'Model Outcomes with Sealed Types', 'Model Outcomes with Sealed Types - practise the Java Core section with a runnable exercise.', 'Mid', 'Mid', 'Java Core', jsonb_build_object('Main.java', E'public class Main {
    public interface Outcome {
        record Ok(String value) implements Outcome {
        }

        record Failed(String reason) implements Outcome {
        }

        static String describe(Outcome outcome) {
            // TODO: make the interface sealed and describe every case, including null
            return "";
        }
    }
}
'), 10, 256, true),
    ('senior-stream-partition-stats', 'Partition Streams with Summary Stats', 'Partition Streams with Summary Stats - practise the Java Core section with a runnable exercise.', 'Senior', 'Senior', 'Java Core', jsonb_build_object('Main.java', E'import java.util.IntSummaryStatistics;
import java.util.List;
import java.util.Map;

public class Main {
    public static Map<Boolean, IntSummaryStatistics> partitionByThreshold(List<Integer> values, int threshold) {
        // TODO: partition values into above-or-equal and below, then summarise each group
        return Map.of();
    }
}
'), 10, 256, true),
    ('senior-generic-repository', 'Typed In-Memory Repository', 'Typed In-Memory Repository - practise the Java Core section with a runnable exercise.', 'Senior', 'Senior', 'Java Core', jsonb_build_object('Main.java', E'import java.util.Map;
import java.util.Optional;

public class Main {
    public static final class Repository<T, ID> {
        public void save(ID id, T entity) {
            // TODO: store the entity under its id
        }

        public Optional<T> findById(ID id) {
            // TODO: return the stored entity or an empty optional
            return Optional.empty();
        }

        public boolean delete(ID id) {
            // TODO: remove the entity and report whether one was removed
            return false;
        }
    }
}
'), 10, 256, true),
    ('senior-functional-pipeline', 'Compose a Function Pipeline', 'Compose a Function Pipeline - practise the Java Core section with a runnable exercise.', 'Senior', 'Senior', 'Java Core', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.function.Function;

public class Main {
    public static <T> Function<T, T> pipeline(List<Function<T, T>> steps) {
        // TODO: compose the steps so they run in order, and return the identity when the list is empty
        return value -> value;
    }
}
'), 10, 256, true),
    ('junior-cli-flag-parser', 'Parse Command Line Flags', 'Parse Command Line Flags - practise the JDK and Toolchain section with a runnable exercise.', 'Junior', 'Junior', 'JDK and Toolchain', jsonb_build_object('Main.java', E'import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> parseFlags(String[] args) {
        // TODO: support --key=value and --flag, keep the last value for repeated keys,
        // and ignore tokens that are not well formed.
        return new LinkedHashMap<>();
    }
}
'), 10, 256, true),
    ('junior-exit-code-choice', 'Map Outcomes to Exit Codes', 'Map Outcomes to Exit Codes - practise the JDK and Toolchain section with a runnable exercise.', 'Junior', 'Junior', 'JDK and Toolchain', jsonb_build_object('Main.java', E'public class Main {
    public static int exitCode(boolean success, boolean retryable) {
        // TODO: map success to 0, a retryable failure to 75 and a permanent failure to 1
        return 0;
    }
}
'), 10, 256, true),
    ('junior-properties-parse', 'Parse a Properties Text', 'Parse a Properties Text - practise the JDK and Toolchain section with a runnable exercise.', 'Junior', 'Junior', 'JDK and Toolchain', jsonb_build_object('Main.java', E'import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> parseProperties(String text) {
        // TODO: skip blank lines and # comments, split each remaining line on its
        // first = or :, and trim the key and value.
        return new LinkedHashMap<>();
    }
}
'), 10, 256, true),
    ('junior-classpath-split', 'Split a Classpath Safely', 'Split a Classpath Safely - practise the JDK and Toolchain section with a runnable exercise.', 'Junior', 'Junior', 'JDK and Toolchain', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> classpathEntries(String path, boolean windows) {
        // TODO: split on ; when windows is true and on : otherwise,
        // dropping empty entries.
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-java-version-compare', 'Compare Java Release Versions', 'Compare Java Release Versions - practise the JDK and Toolchain section with a runnable exercise.', 'Mid', 'Mid', 'JDK and Toolchain', jsonb_build_object('Main.java', E'public class Main {
    public static int compareReleases(String left, String right) {
        // TODO: compare the major, minor and patch components in order,
        // tolerating a legacy 1. prefix and missing components.
        return 0;
    }
}
'), 10, 256, true),
    ('mid-lts-classification', 'Classify Releases as LTS', 'Classify Releases as LTS - practise the JDK and Toolchain section with a runnable exercise.', 'Mid', 'Mid', 'JDK and Toolchain', jsonb_build_object('Main.java', E'public class Main {
    public static boolean isLts(int featureVersion) {
        // TODO: encode the documented LTS set and the two-year cadence from Java 17 onwards
        return false;
    }
}
'), 10, 256, true),
    ('mid-module-requires', 'Derive Module Requirements', 'Derive Module Requirements - practise the JDK and Toolchain section with a runnable exercise.', 'Mid', 'Mid', 'JDK and Toolchain', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> requires(List<String> importedPackages) {
        // TODO: map each imported package to the JDK module that provides it,
        // keep java.base first, sort the rest and remove duplicates.
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-heap-from-percentage', 'Size the Heap from a Percentage', 'Size the Heap from a Percentage - practise the JVM Internals section with a runnable exercise.', 'Mid', 'Mid', 'JVM Internals', jsonb_build_object('Main.java', E'public class Main {
    public static long maxHeapBytes(long containerBytes, int percentage) {
        // TODO: clamp the percentage to the range 1..100 and return that share
        // of the container size in bytes.
        return 0L;
    }
}
'), 10, 256, true),
    ('mid-gc-pause-summary', 'Summarise GC Pauses', 'Summarise GC Pauses - practise the JVM Internals section with a runnable exercise.', 'Mid', 'Mid', 'JVM Internals', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String summarise(List<Integer> pauseMillis) {
        // TODO: report the number of pauses, their total and the worst pause as
        // "count=..., total=..., worst=..." with zeros for an empty or null list.
        return "count=0, total=0, worst=0";
    }
}
'), 10, 256, true),
    ('mid-allocation-budget', 'Check an Allocation Budget', 'Check an Allocation Budget - practise the JVM Internals section with a runnable exercise.', 'Mid', 'Mid', 'JVM Internals', jsonb_build_object('Main.java', E'public class Main {
    public static boolean withinBudget(long allocatedBytes, long budgetBytes, double tolerance) {
        // TODO: return true when the allocation is within the budget plus the
        // tolerance fraction of it, and false for negative input.
        return false;
    }
}
'), 10, 256, true),
    ('senior-collector-choice', 'Choose a Garbage Collector', 'Choose a Garbage Collector - practise the JVM Internals section with a runnable exercise.', 'Senior', 'Senior', 'JVM Internals', jsonb_build_object('Main.java', E'public class Main {
    public static String chooseCollector(int heapGb, int p99PauseMillis, boolean throughputCritical) {
        // TODO: apply the documented decision table and return the collector name
        return "";
    }
}
'), 10, 256, true),
    ('senior-warmup-strategy', 'Plan JIT Warmup', 'Plan JIT Warmup - practise the JVM Internals section with a runnable exercise.', 'Senior', 'Senior', 'JVM Internals', jsonb_build_object('Main.java', E'public class Main {
    public static int warmupInvocations(int targetMillis, int observedMillis, int step) {
        // TODO: estimate how many more invocations are needed, rounded up in
        // steps and bounded by 1_000_000; return 0 when already warm.
        return 0;
    }
}
'), 10, 256, true),
    ('senior-oom-classification', 'Classify an OutOfMemoryError', 'Classify an OutOfMemoryError - practise the JVM Internals section with a runnable exercise.', 'Senior', 'Senior', 'JVM Internals', jsonb_build_object('Main.java', E'public class Main {
    public static String classify(String message) {
        // TODO: map the common OutOfMemoryError messages to their documented categories
        return "UNKNOWN";
    }
}
'), 10, 256, true),
    ('junior-safe-counter-logic', 'Guard a Counter Increment', 'Guard a Counter Increment - practise the Concurrency section with a runnable exercise.', 'Junior', 'Junior', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static int nextValue(int current, int limit) {
        // TODO: wrap back to zero before the value would exceed limit
        return current + 1;
    }
}
'), 10, 256, true),
    ('junior-latch-count', 'Count Down a Latch Correctly', 'Count Down a Latch Correctly - practise the Concurrency section with a runnable exercise.', 'Junior', 'Junior', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static int latchCount(int workers, int alreadyDone) {
        // TODO: clamp the remaining count into [0, workers]
        return workers - alreadyDone;
    }
}
'), 10, 256, true),
    ('junior-completed-future', 'Read a Completed Future Safely', 'Read a Completed Future Safely - practise the Concurrency section with a runnable exercise.', 'Junior', 'Junior', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.concurrent.CompletableFuture;

public class Main {
    public static String valueOr(CompletableFuture<String> future, String fallback) {
        // TODO: fall back for a null, failed, incomplete, or null-valued future
        return future.getNow(fallback);
    }
}
'), 10, 256, true),
    ('mid-pool-size-calculation', 'Size a Thread Pool', 'Size a Thread Pool - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static int poolSize(double targetUtilisation, double waitTime, double serviceTime, int cores) {
        // TODO: apply cores * utilisation * (1 + wait/service), then clamp
        return cores;
    }
}
'), 10, 256, true),
    ('mid-cas-retry-loop', 'Model a CAS Retry Loop', 'Model a CAS Retry Loop - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.function.IntUnaryOperator;

public class Main {
    public static int casAttempts(int initial, int target, IntUnaryOperator observed) {
        // TODO: retry until the observed value reaches the target, bounded at 1000
        return 1;
    }
}
'), 10, 256, true),
    ('mid-atomic-compute-if-absent', 'Atomic Compute-If-Absent Semantics', 'Atomic Compute-If-Absent Semantics - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Supplier;

public class Main {
    public static String computeOnce(ConcurrentHashMap<String, String> cache, String key, Supplier<String> loader) {
        // TODO: replace the check-then-put with one atomic operation
        if (cache.get(key) == null) {
            cache.put(key, loader.get());
        }
        return cache.get(key);
    }
}
'), 10, 256, true),
    ('mid-deadlock-cycle', 'Detect a Lock Order Cycle', 'Detect a Lock Order Cycle - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static boolean hasCycle(Map<String, List<String>> waitingFor) {
        // TODO: walk the wait-for graph and detect any cycle
        return false;
    }
}
'), 10, 256, true),
    ('mid-semaphore-admission', 'Bounded Semaphore Admission', 'Bounded Semaphore Admission - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static int admit(int permits, int waiting, int maxQueue) {
        // TODO: grant at most the available permits and honour the queue bound
        return permits;
    }
}
'), 10, 256, true),
    ('mid-backoff-schedule', 'Compute a Backoff Schedule', 'Compute a Backoff Schedule - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<Long> backoffMillis(int attempts, long base, long cap) {
        // TODO: double each delay and clamp it to cap
        List<Long> delays = new ArrayList<>();
        for (int i = 0; i < attempts; i++) {
            delays.add(base);
        }
        return delays;
    }
}
'), 10, 256, true),
    ('mid-graceful-shutdown-order', 'Order a Graceful Shutdown', 'Order a Graceful Shutdown - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> shutdownOrder(List<String> resources) {
        // TODO: emit the phases in shutdown order, dropping duplicates and nulls
        return new ArrayList<>(resources);
    }
}
'), 10, 256, true),
    ('mid-stamped-read-valid', 'Validate an Optimistic Read', 'Validate an Optimistic Read - practise the Concurrency section with a runnable exercise.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static boolean readValid(long stampBefore, long stampAfter, boolean writeObserved) {
        // TODO: a read is valid only when the stamp is unchanged and no write was seen
        return true;
    }
}
'), 10, 256, true),
    ('senior-virtual-or-platform', 'Choose Virtual or Platform Threads', 'Choose Virtual or Platform Threads - practise the Concurrency section with a runnable exercise.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static String chooseThreadType(boolean ioBound, boolean longCpuBound, boolean usesThreadLocalHeavily, long tasksPerSecond) {
        // TODO: apply the documented decision order
        return "virtual";
    }
}
'), 10, 256, true),
    ('senior-deadline-budget', 'Propagate a Deadline Budget', 'Propagate a Deadline Budget - practise the Concurrency section with a runnable exercise.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static long remainingMillis(long deadlineNanos, long nowNanos, int hops) {
        // TODO: subtract the per-hop reserve and never return a negative budget
        return 0;
    }
}
'), 10, 256, true),
    ('senior-bounded-queue-policy', 'Pick a Bounded Queue Policy', 'Pick a Bounded Queue Policy - practise the Concurrency section with a runnable exercise.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static String rejectionPolicy(int latencyBudgetMillis, boolean lossTolerant, int queueDepth) {
        // TODO: apply the documented policy order
        return "block";
    }
}
'), 10, 256, true),
    ('senior-forkjoin-threshold', 'Choose a ForkJoin Threshold', 'Choose a ForkJoin Threshold - practise the Concurrency section with a runnable exercise.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', E'public class Main {
    public static int threshold(int elements, int cores, int perElementCostMicros) {
        // TODO: size the task by total cost and clamp into [1000, 100000]
        return 1000;
    }
}
'), 10, 256, true),
    ('senior-threadlocal-leak', 'Spot a ThreadLocal Leak', 'Spot a ThreadLocal Leak - practise the Concurrency section with a runnable exercise.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> suspiciousFields(List<String> fieldDeclarations) {
        // TODO: flag static ThreadLocal fields without any removal handling
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-concurrency-standard', 'Set a Concurrency Standard', 'Set a Concurrency Standard - practise the Concurrency section with a runnable exercise.', 'Lead', 'Lead', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> mandatoryControls(boolean publicApi, boolean sharedPool, boolean hasTimeouts) {
        // TODO: add the controls the team is missing, in the documented order
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-virtual-thread-migration', 'Plan a Virtual Thread Migration', 'Plan a Virtual Thread Migration - practise the Concurrency section with a runnable exercise.', 'Lead', 'Lead', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> migrationSteps(boolean usesSynchronizedBlocks, boolean poolsBoundedAtDb, boolean reliesOnThreadLocalCaches) {
        // TODO: assemble the migration plan in the documented order
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-gav-parse', 'Parse a Maven Coordinate', 'Parse a Maven Coordinate - practise the Build Engineering section with a runnable exercise.', 'Junior', 'Junior', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static String[] parse(String coordinate) {
        // TODO: split the coordinate on colons and default the missing parts to empty strings
        return new String[] {"", "", ""};
    }
}
'), 10, 256, true),
    ('junior-scope-choice', 'Choose a Dependency Scope', 'Choose a Dependency Scope - practise the Build Engineering section with a runnable exercise.', 'Junior', 'Junior', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static String scopeFor(String usage) {
        // TODO: map the documented usage keys to Maven scopes
        return "compile";
    }
}
'), 10, 256, true),
    ('junior-version-compare', 'Compare Semantic Versions', 'Compare Semantic Versions - practise the Build Engineering section with a runnable exercise.', 'Junior', 'Junior', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static int compare(String left, String right) {
        // TODO: compare the numeric components first, then let a qualifier sort before the bare version
        return 0;
    }
}
'), 10, 256, true),
    ('junior-property-substitution', 'Substitute Build Properties', 'Substitute Build Properties - practise the Build Engineering section with a runnable exercise.', 'Junior', 'Junior', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static String substitute(String template, Map<String, String> properties) {
        // TODO: replace each known placeholder token with its value and leave unknown tokens untouched
        return template;
    }
}
'), 10, 256, true),
    ('junior-plugin-goal-parse', 'Parse a Plugin Goal', 'Parse a Plugin Goal - practise the Build Engineering section with a runnable exercise.', 'Junior', 'Junior', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static String[] parseGoal(String goal) {
        // TODO: split into groupId, artifactId, version, and goal, defaulting the version when it is omitted
        return new String[] {"", "", "", goal == null ? "" : goal};
    }
}
'), 10, 256, true),
    ('junior-module-direct-deps', 'List Direct Module Dependencies', 'List Direct Module Dependencies - practise the Build Engineering section with a runnable exercise.', 'Junior', 'Junior', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> directDependencies(Map<String, List<String>> graph, String module) {
        // TODO: return the module''s direct dependencies sorted, or an empty list when the module is unknown
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-nearest-wins', 'Resolve a Dependency Version Conflict', 'Resolve a Dependency Version Conflict - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String resolve(List<String> paths) {
        // TODO: pick the version from the shortest path, breaking ties by declaration order
        return "";
    }
}
'), 10, 256, true),
    ('mid-exclusion-set', 'Compute Effective Exclusions', 'Compute Effective Exclusions - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static Set<String> excluded(Set<String> declared, Set<String> inherited, boolean inheritEnabled) {
        // TODO: union the declared exclusions with the inherited ones when inheritance is enabled
        return declared == null ? Set.of() : declared;
    }
}
'), 10, 256, true),
    ('mid-bom-alignment', 'Align Versions from a BOM', 'Align Versions from a BOM - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> misaligned(Map<String, String> declared, Map<String, String> bom) {
        // TODO: list the BOM-managed artifacts whose declared version differs, sorted
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-profile-activation', 'Evaluate Profile Activation', 'Evaluate Profile Activation - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Set;

public class Main {
    public static List<String> activeProfiles(List<String> requiredProperties, Set<String> present,
            String requiredOs, String currentOs) {
        // TODO: parse each "name[:prop1,prop2]" descriptor, apply the property and OS rules, and sort the active names
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-lifecycle-order', 'Order Maven Lifecycle Phases', 'Order Maven Lifecycle Phases - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> phasesUpTo(String phase) {
        // TODO: return the ordered default lifecycle phases through the requested phase, or an empty list
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-gradle-task-order', 'Order Gradle Task Execution', 'Order Gradle Task Execution - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> executionOrder(Map<String, List<String>> dependsOn, String task) {
        // TODO: return the dependency-first execution order, or an empty list when the graph has a cycle
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-configuration-choice', 'Pick a Gradle Dependency Configuration', 'Pick a Gradle Dependency Configuration - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static String configurationFor(String usage, boolean publishedLibrary) {
        // TODO: map the dependency usage to the Gradle configuration that should declare it
        return "";
    }
}
'), 10, 256, true),
    ('mid-catalog-alias', 'Resolve a Version Catalog Alias', 'Resolve a Version Catalog Alias - practise the Build Engineering section with a runnable exercise.', 'Mid', 'Mid', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static String toAccessor(String alias) {
        // TODO: build the dotted libs.<alias> accessor Gradle generates for a catalog alias
        return "";
    }
}
'), 10, 256, true),
    ('senior-build-cache-key', 'Compute a Build Cache Key', 'Compute a Build Cache Key - practise the Build Engineering section with a runnable exercise.', 'Senior', 'Senior', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String cacheKey(String taskName, List<String> inputs, String jdkVersion) {
        // TODO: fingerprint the task inputs so identical builds reuse the same key
        return "";
    }
}
'), 10, 256, true),
    ('senior-reproducible-timestamp', 'Normalise Build Timestamps', 'Normalise Build Timestamps - practise the Build Engineering section with a runnable exercise.', 'Senior', 'Senior', 'Build Engineering', jsonb_build_object('Main.java', E'public class Main {
    public static String sourceDateEpoch(Long epochSeconds) {
        // TODO: render the build timestamp in ISO-8601 UTC, using the reproducible fallback when no value is supplied
        return "";
    }
}
'), 10, 256, true),
    ('senior-toolchain-matrix', 'Select Build Toolchains', 'Select Build Toolchains - practise the Build Engineering section with a runnable exercise.', 'Senior', 'Senior', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, String> selectToolchains(List<String> neededReleases, Map<String, List<String>> installed) {
        // TODO: bind each needed Java release to the highest matching vendor, or return an empty map when a release is missing
        return Map.of();
    }
}
'), 10, 256, true),
    ('senior-configuration-cache-safe', 'Audit for Configuration Cache Safety', 'Audit for Configuration Cache Safety - practise the Build Engineering section with a runnable exercise.', 'Senior', 'Senior', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> violations(List<String> taskLines) {
        // TODO: return the trimmed lines that capture the Project or read the environment inside a task action
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-enforcer-rules', 'Evaluate Build Rule Violations', 'Evaluate Build Rule Violations - practise the Build Engineering section with a runnable exercise.', 'Senior', 'Senior', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, String> rules, Map<String, String> actual) {
        // TODO: report the banned dependencies that are present and any Java version mismatch, sorted
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-build-standard', 'Define an Organisation Build Standard', 'Define an Organisation Build Standard - practise the Build Engineering section with a runnable exercise.', 'Lead', 'Lead', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> requiredPractices(boolean publishesLibraries, boolean regulatedDomain) {
        // TODO: return the practices an organisation build must adopt, in the order they should be introduced
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-gradle-migration', 'Plan an Incremental Build Migration', 'Plan an Incremental Build Migration - practise the Build Engineering section with a runnable exercise.', 'Lead', 'Lead', 'Build Engineering', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> migrationOrder(Map<String, List<String>> moduleDeps) {
        // TODO: return a leaf-to-root migration order, or an empty list when the module graph has a cycle
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-bean-scope', 'Choose a Spring Bean Scope', 'Choose a Spring Bean Scope - practise the Spring Framework section with a runnable exercise.', 'Junior', 'Junior', 'Spring Framework', jsonb_build_object('Main.java', E'public class Main {
    public static String scopeFor(boolean holdsMutableState, boolean expensiveToCreate, boolean requestScoped) {
        // TODO: choose the documented scope instead of always returning the default
        return "singleton";
    }
}
'), 10, 256, true),
    ('junior-property-bind', 'Bind Configuration Values', 'Bind Configuration Values - practise the Spring Framework section with a runnable exercise.', 'Junior', 'Junior', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static int portFrom(Map<String, String> environment, int fallback) {
        // TODO: bind app.port with relaxed name matching, validate 1..65535 and fall back
        return fallback;
    }
}
'), 10, 256, true),
    ('junior-status-mapping', 'Map Results to HTTP Status Codes', 'Map Results to HTTP Status Codes - practise the Spring Framework section with a runnable exercise.', 'Junior', 'Junior', 'Spring Framework', jsonb_build_object('Main.java', E'public class Main {
    public static int statusFor(String outcome) {
        // TODO: map each documented outcome to its HTTP status code
        return 200;
    }
}
'), 10, 256, true),
    ('mid-autoconfig-condition', 'Decide a Conditional Bean', 'Decide a Conditional Bean - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'public class Main {
    public static String decision(boolean missingBean, boolean propertyEnabled, boolean classPresent) {
        // TODO: apply the documented condition precedence: class, property, then missing bean
        return "SKIP";
    }
}
'), 10, 256, true),
    ('mid-profile-override-merge', 'Merge Profile Overrides', 'Merge Profile Overrides - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, String> effective(Map<String, String> base, List<Map<String, String>> overrides) {
        // TODO: merge profile overrides in order, later profiles win, keys are preserved
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-problem-detail-build', 'Build a Problem Detail Response', 'Build a Problem Detail Response - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, Object> problem(String type, String title, int status, Map<String, List<String>> fieldErrors) {
        // TODO: build the RFC 9457 problem detail document with an errors extension
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-validation-fields', 'Validate Request Fields', 'Validate Request Fields - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, List<String>> validate(String reference, int quantity, String currency) {
        // TODO: collect every violation per field instead of failing fast
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-cache-key-compose', 'Compose a Cache Key', 'Compose a Cache Key - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String cacheKey(String prefix, String tenant, List<String> args) {
        // TODO: build a deterministic, tenant scoped key that escapes its separator
        return "";
    }
}
'), 10, 256, true),
    ('mid-transaction-boundary', 'Place Transaction Boundaries', 'Place Transaction Boundaries - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> transactionalOperations(List<String> steps) {
        // TODO: mark only steps that both read and write persistent state
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-retry-delay', 'Compute a Retry Delay', 'Compute a Retry Delay - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'public class Main {
    public static long delayMillis(int attempt, long initial, double multiplier, long max) {
        // TODO: grow the delay exponentially, then bound it by max
        return initial;
    }
}
'), 10, 256, true),
    ('mid-health-aggregate', 'Aggregate Health Indicators', 'Aggregate Health Indicators - practise the Spring Framework section with a runnable exercise.', 'Mid', 'Mid', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String aggregate(List<String> indicatorStatuses) {
        // TODO: return the worst status using the documented precedence
        return "UP";
    }
}
'), 10, 256, true),
    ('senior-aop-order', 'Order Aspects Deterministically', 'Order Aspects Deterministically - practise the Spring Framework section with a runnable exercise.', 'Senior', 'Senior', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> executionOrder(Map<String, Integer> aspectOrders) {
        // TODO: order aspects by their order value on the way in, and reverse them on the way out
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-propagation-choice', 'Choose a Transaction Propagation', 'Choose a Transaction Propagation - practise the Spring Framework section with a runnable exercise.', 'Senior', 'Senior', 'Spring Framework', jsonb_build_object('Main.java', E'public class Main {
    public static String propagationFor(String scenario) {
        // TODO: apply the documented propagation decision table
        return "REQUIRED";
    }
}
'), 10, 256, true),
    ('senior-api-version-route', 'Route by API Version', 'Route by API Version - practise the Spring Framework section with a runnable exercise.', 'Senior', 'Senior', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String handler(String requestedVersion, List<String> supportedVersions, String baseline) {
        // TODO: pick the highest supported version not above the request, baseline when none match
        return baseline;
    }
}
'), 10, 256, true),
    ('senior-filter-chain-order', 'Order the Security Filter Chain', 'Order the Security Filter Chain - practise the Spring Framework section with a runnable exercise.', 'Senior', 'Senior', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> orderedFilters() {
        // TODO: return the documented Spring Security filter order
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-modulith-boundary', 'Check a Module Boundary', 'Check a Module Boundary - practise the Spring Framework section with a runnable exercise.', 'Senior', 'Senior', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, List<String>> dependencies) {
        // TODO: flag cross-module references that bypass the target module''s api package
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-native-hint-need', 'Identify Native Image Hints', 'Identify Native Image Hints - practise the Spring Framework section with a runnable exercise.', 'Senior', 'Senior', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> requiredHints(List<String> codePatterns) {
        // TODO: map each code pattern to the reachability metadata file it needs
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-upgrade-plan', 'Plan a Spring 6 to 7 Upgrade', 'Plan a Spring 6 to 7 Upgrade - practise the Spring Framework section with a runnable exercise.', 'Lead', 'Lead', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> upgradeSteps(boolean usesJavaxAnnotations, boolean usesListenableFuture, boolean usesRestTemplate) {
        // TODO: build the ordered remediation plan for a Spring 6 to 7 upgrade
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-service-template', 'Design a Service Template', 'Design a Service Template - practise the Spring Framework section with a runnable exercise.', 'Lead', 'Lead', 'Spring Framework', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> baselineComponents(boolean exposesApi, boolean writesData, boolean runsInProduction) {
        // TODO: return the components a new service must include
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-query-method-parse', 'Derive a Query from a Method Name', 'Derive a Query from a Method Name - practise the Spring Data and Security section with a runnable exercise.', 'Mid', 'Mid', 'Spring Data and Security', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String describe(String methodName) {
        // TODO: strip the query prefix, split the criteria on And/Or and map
        // each keyword suffix to its operator.
        List<String> ignored = List.of();
        return String.join("", ignored);
    }
}
'), 10, 256, true),
    ('mid-page-vs-slice', 'Choose Between Page and Slice', 'Choose Between Page and Slice - practise the Spring Data and Security section with a runnable exercise.', 'Mid', 'Mid', 'Spring Data and Security', jsonb_build_object('Main.java', E'public class Main {
    public static String chooseReturnType(boolean needsTotalCount, boolean largeTable, boolean infiniteScroll) {
        // TODO: return "Page" when the total count is required or cheap,
        // and "Slice" when a large table or infinite scroll only needs the next-page check.
        return "Page";
    }
}
'), 10, 256, true),
    ('mid-scope-authorisation', 'Check an OAuth Scope', 'Check an OAuth Scope - practise the Spring Data and Security section with a runnable exercise.', 'Mid', 'Mid', 'Spring Data and Security', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static boolean authorised(Set<String> granted, String required, boolean adminBypass) {
        // TODO: an admin scope or admin bypass grants everything; otherwise the
        // granted set must contain the required scope exactly.
        return true;
    }
}
'), 10, 256, true),
    ('mid-password-policy', 'Evaluate a Password Policy', 'Evaluate a Password Policy - practise the Spring Data and Security section with a runnable exercise.', 'Mid', 'Mid', 'Spring Data and Security', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> violations(String password, int minLength) {
        // TODO: report one message per rule the password breaks, in the
        // documented order, and report every rule for a null password.
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-jwt-claims', 'Validate JWT Claims', 'Validate JWT Claims - practise the Spring Data and Security section with a runnable exercise.', 'Senior', 'Senior', 'Spring Data and Security', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> claims, long nowEpochSeconds, String expectedAudience) {
        // TODO: report "missing <claim>" for absent sub/exp/aud claims and
        // "expired" or "audience mismatch" for the values that fail validation.
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-method-security', 'Evaluate a Method Security Expression', 'Evaluate a Method Security Expression - practise the Spring Data and Security section with a runnable exercise.', 'Senior', 'Senior', 'Spring Data and Security', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static boolean permit(String expression, Set<String> authorities, String ownerId, String callerId) {
        // TODO: support hasRole(''X''), hasAuthority(''X''), isOwner and the
        // ! / && / || operators over those atoms.
        return false;
    }
}
'), 10, 256, true),
    ('senior-audit-write', 'Record an Audit Entry', 'Record an Audit Entry - practise the Spring Data and Security section with a runnable exercise.', 'Senior', 'Senior', 'Spring Data and Security', jsonb_build_object('Main.java', E'import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> auditEntry(String actor, String action, String target, String outcome) {
        // TODO: build the entry with the documented field order, replace blank
        // values with "unknown", redact secrets and normalise the outcome.
        return new LinkedHashMap<>();
    }
}
'), 10, 256, true),
    ('junior-where-builder', 'Build a Parameterised WHERE Clause', 'Build a Parameterised WHERE Clause - practise the Databases and SQL section with a runnable exercise.', 'Junior', 'Junior', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static final List<String> ALLOWED_COLUMNS = List.of("id", "email", "status", "created_at");
    public static final List<String> ALLOWED_OPERATORS = List.of("=", "<>", "<", "<=", ">", ">=");

    public static String whereFor(String column, String operator, int parameterIndex) {
        // TODO: reject anything that is not allowlisted and bind the value as a placeholder
        return column + " " + operator + " " + parameterIndex;
    }
}
'), 10, 256, true),
    ('junior-row-count', 'Count Matching Rows', 'Count Matching Rows - practise the Databases and SQL section with a runnable exercise.', 'Junior', 'Junior', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static int countMatching(List<Integer> values, int threshold, boolean inclusive) {
        // TODO: count values above, or at least, the threshold
        return 0;
    }
}
'), 10, 256, true),
    ('junior-null-semantics', 'Apply SQL Null Semantics', 'Apply SQL Null Semantics - practise the Databases and SQL section with a runnable exercise.', 'Junior', 'Junior', 'Databases and SQL', jsonb_build_object('Main.java', E'public class Main {
    public static Boolean equalsFilter(Integer stored, Integer requested) {
        // TODO: mirror SQL three-valued logic for NULL comparisons
        return stored.equals(requested);
    }
}
'), 10, 256, true),
    ('junior-order-clause', 'Validate an ORDER BY Clause', 'Validate an ORDER BY Clause - practise the Databases and SQL section with a runnable exercise.', 'Junior', 'Junior', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static final List<String> ALLOWED_COLUMNS = List.of("id", "email", "status", "created_at", "score");

    public static String orderBy(List<String> columns, boolean descending) {
        // TODO: allowlist every column and append the direction
        List<String> parts = new ArrayList<>(columns);
        return String.join(", ", parts);
    }
}
'), 10, 256, true),
    ('mid-index-column-order', 'Order Composite Index Columns', 'Order Composite Index Columns - practise the Databases and SQL section with a runnable exercise.', 'Mid', 'Mid', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> indexColumns(List<String> equalityColumns, List<String> rangeColumns, List<String> sortColumns) {
        // TODO: order the columns for one composite index
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-join-fanout', 'Detect Join Fan-out', 'Detect Join Fan-out - practise the Databases and SQL section with a runnable exercise.', 'Mid', 'Mid', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static boolean hasFanout(Map<String, Integer> parentRows, Map<String, Integer> childRows) {
        // TODO: compare the rows a join produces with the number of parent rows
        return false;
    }
}
'), 10, 256, true),
    ('mid-query-count', 'Count Queries for a Load', 'Count Queries for a Load - practise the Databases and SQL section with a runnable exercise.', 'Mid', 'Mid', 'Databases and SQL', jsonb_build_object('Main.java', E'public class Main {
    public static int totalQueries(int parents, int childQueriesPerParent, boolean batched, int batchSize) {
        // TODO: one query for the parents plus either N child queries or ceil(N / batchSize) batches
        return 1 + parents * childQueriesPerParent;
    }
}
'), 10, 256, true),
    ('mid-isolation-choice', 'Choose an Isolation Level', 'Choose an Isolation Level - practise the Databases and SQL section with a runnable exercise.', 'Mid', 'Mid', 'Databases and SQL', jsonb_build_object('Main.java', E'public class Main {
    public static String isolationFor(String scenario) {
        // TODO: map each documented anomaly scenario to the isolation level that prevents it
        return "READ COMMITTED";
    }
}
'), 10, 256, true),
    ('mid-lock-order', 'Order Lock Acquisition', 'Order Lock Acquisition - practise the Databases and SQL section with a runnable exercise.', 'Mid', 'Mid', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> lockOrder(List<String> tables) {
        // TODO: produce one deterministic lock order shared by all transactions
        return new ArrayList<>(tables);
    }
}
'), 10, 256, true),
    ('mid-explain-verdict', 'Read an EXPLAIN Plan', 'Read an EXPLAIN Plan - practise the Databases and SQL section with a runnable exercise.', 'Mid', 'Mid', 'Databases and SQL', jsonb_build_object('Main.java', E'public class Main {
    public static String verdict(boolean sequentialScan, long rowsScanned, long rowsReturned, boolean indexAvailable) {
        // TODO: diagnose the plan from the scan type and row counts
        return "OK";
    }
}
'), 10, 256, true),
    ('senior-partition-key', 'Choose a Partition Key', 'Choose a Partition Key - practise the Databases and SQL section with a runnable exercise.', 'Senior', 'Senior', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static String partitionKey(List<String> candidateColumns, Map<String, Integer> cardinality) {
        // TODO: require the highest-cardinality time or tenant column
        return candidateColumns.isEmpty() ? null : candidateColumns.get(0);
    }
}
'), 10, 256, true),
    ('senior-vacuum-settings', 'Tune Autovacuum for a Hot Table', 'Tune Autovacuum for a Hot Table - practise the Databases and SQL section with a runnable exercise.', 'Senior', 'Senior', 'Databases and SQL', jsonb_build_object('Main.java', E'import java.util.HashMap;
import java.util.Map;

public class Main {
    public static Map<String, Double> autovacuumSettings(long tableRows, double updateRatio) {
        // TODO: scale the vacuum settings down as churn rises
        Map<String, Double> settings = new HashMap<>();
        settings.put("vacuum_scale_factor", 0.2);
        settings.put("vacuum_threshold", 50.0);
        settings.put("vacuum_trigger_rows", 50 + 0.2 * tableRows);
        settings.put("analyze_scale_factor", 0.1);
        return settings;
    }
}
'), 10, 256, true),
    ('senior-replica-routing', 'Route Reads by Replica Lag', 'Route Reads by Replica Lag - practise the Databases and SQL section with a runnable exercise.', 'Senior', 'Senior', 'Databases and SQL', jsonb_build_object('Main.java', E'public class Main {
    public static String route(long lagMillis, long maxLagMillis, boolean readYourWrites) {
        // TODO: fall back to the primary when the replica is too far behind
        return "REPLICA";
    }
}
'), 10, 256, true),
    ('senior-migration-safety', 'Classify a Migration as Safe', 'Classify a Migration as Safe - practise the Databases and SQL section with a runnable exercise.', 'Senior', 'Senior', 'Databases and SQL', jsonb_build_object('Main.java', E'public class Main {
    public static String classify(String statement, boolean largeTable) {
        // TODO: classify the statement by what it does to a running table
        return "SAFE";
    }
}
'), 10, 256, true),
    ('mid-fetch-strategy', 'Choose a Fetch Strategy', 'Choose a Fetch Strategy - practise the JPA and Hibernate section with a runnable exercise.', 'Mid', 'Mid', 'JPA and Hibernate', jsonb_build_object('Main.java', E'public class Main {
    public static String fetchFor(boolean neededEveryTime, boolean collection, int rowsExpected) {
        // TODO: pick LAZY, EAGER or JOIN FETCH using the documented rules.
        return "LAZY";
    }
}
'), 10, 256, true),
    ('mid-batch-size', 'Choose a JDBC Batch Size', 'Choose a JDBC Batch Size - practise the JPA and Hibernate section with a runnable exercise.', 'Mid', 'Mid', 'JPA and Hibernate', jsonb_build_object('Main.java', E'public class Main {
    public static int batchSize(int rowWidthBytes, int memoryBudgetKb) {
        // TODO: derive a batch size from the memory budget and clamp it to 1..1000.
        return 1;
    }
}
'), 10, 256, true),
    ('mid-optimistic-conflict', 'Handle an Optimistic Lock Conflict', 'Handle an Optimistic Lock Conflict - practise the JPA and Hibernate section with a runnable exercise.', 'Mid', 'Mid', 'JPA and Hibernate', jsonb_build_object('Main.java', E'public class Main {
    public static String action(String exceptionType, int attempts, int maxAttempts, boolean replaysSafe) {
        // TODO: retry only safe and replayable optimistic-lock conflicts that
        // still have an attempt left; otherwise surface the error.
        return "SURFACE";
    }
}
'), 10, 256, true),
    ('mid-dto-projection', 'Project an Entity to a DTO', 'Project an Entity to a DTO - practise the JPA and Hibernate section with a runnable exercise.', 'Mid', 'Mid', 'JPA and Hibernate', jsonb_build_object('Main.java', E'import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, Object> projection(List<String> requestedFields, Map<String, Object> entity) {
        // TODO: copy only the requested fields that the entity has, skipping
        // nulls, and never copy a password.
        return new LinkedHashMap<>();
    }
}
'), 10, 256, true),
    ('mid-entity-mapping-review', 'Review an Entity Mapping', 'Review an Entity Mapping - practise the JPA and Hibernate section with a runnable exercise.', 'Mid', 'Mid', 'JPA and Hibernate', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> problems(Map<String, String> mappings) {
        // TODO: report one message per mapping problem, sorted, and an empty
        // list when every mapping is sound.
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('senior-second-level-cache', 'Decide on a Second-Level Cache', 'Decide on a Second-Level Cache - practise the JPA and Hibernate section with a runnable exercise.', 'Senior', 'Senior', 'JPA and Hibernate', jsonb_build_object('Main.java', E'public class Main {
    public static String cacheRegion(String entityName, boolean readMostly, boolean sharedAcrossNodes) {
        // TODO: choose the documented cache region for the entity.
        return "none";
    }
}
'), 10, 256, true),
    ('senior-statistics-triage', 'Triage Hibernate Statistics', 'Triage Hibernate Statistics - practise the JPA and Hibernate section with a runnable exercise.', 'Senior', 'Senior', 'JPA and Hibernate', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> findings(Map<String, Long> stats) {
        // TODO: report one finding per suspicious statistic, sorted.
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('senior-nplusone-detect', 'Detect the N+1 Problem', 'Detect the N+1 Problem - practise the JPA and Hibernate section with a runnable exercise.', 'Senior', 'Senior', 'JPA and Hibernate', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> offenders(List<String> sqlLog) {
        // TODO: normalise each statement, count executions, and flag statements
        // executed at least once per parent row.
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-partition-key-choice', 'Choose a Kafka Partition Key', 'Choose a Kafka Partition Key - practise the Messaging and Events section with a runnable exercise.', 'Mid', 'Mid', 'Messaging and Events', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String partitionKey(String orderingRequirement, boolean hotKeyRisk, List<String> candidates) {
        // TODO: keep required ordering and spread hot keys without breaking it
        return null;
    }
}
'), 10, 256, true),
    ('mid-offset-commit', 'Choose an Offset Commit Strategy', 'Choose an Offset Commit Strategy - practise the Messaging and Events section with a runnable exercise.', 'Mid', 'Mid', 'Messaging and Events', jsonb_build_object('Main.java', E'public class Main {
    public static String commitStrategy(boolean atLeastOnce, boolean exactlyOnce, boolean batchProcessing) {
        // TODO: map the requested delivery guarantees to a commit strategy
        return "AUTO_COMMIT";
    }
}
'), 10, 256, true),
    ('mid-dlq-route', 'Route a Poison Message', 'Route a Poison Message - practise the Messaging and Events section with a runnable exercise.', 'Mid', 'Mid', 'Messaging and Events', jsonb_build_object('Main.java', E'public class Main {
    public static String route(int attempts, int maxAttempts, boolean permanentFailure) {
        // TODO: apply the documented retry and dead-letter rules
        return permanentFailure ? "DISCARD" : "RETRY";
    }
}
'), 10, 256, true),
    ('mid-consumer-dedupe', 'Deduplicate Consumed Events', 'Deduplicate Consumed Events - practise the Messaging and Events section with a runnable exercise.', 'Mid', 'Mid', 'Messaging and Events', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static boolean isDuplicate(Set<String> seenIds, String eventId) {
        // TODO: record first deliveries and treat null ids as duplicates
        return false;
    }
}
'), 10, 256, true),
    ('mid-schema-compat', 'Check Event Schema Compatibility', 'Check Event Schema Compatibility - practise the Messaging and Events section with a runnable exercise.', 'Mid', 'Mid', 'Messaging and Events', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String compatibility(List<String> removedFields, List<String> addedOptional, List<String> addedRequired) {
        // TODO: classify the schema change per the documented compatibility rules
        return "NONE";
    }
}
'), 10, 256, true),
    ('senior-exactly-once-decision', 'Decide on Exactly-Once Processing', 'Decide on Exactly-Once Processing - practise the Messaging and Events section with a runnable exercise.', 'Senior', 'Senior', 'Messaging and Events', jsonb_build_object('Main.java', E'public class Main {
    public static String advise(boolean idempotentConsumer, boolean transactionalSink, boolean crossSystemWrites) {
        // TODO: recommend the documented exactly-once mechanism
        return "AT_LEAST_ONCE";
    }
}
'), 10, 256, true),
    ('senior-rebalance-impact', 'Assess a Rebalance', 'Assess a Rebalance - practise the Messaging and Events section with a runnable exercise.', 'Senior', 'Senior', 'Messaging and Events', jsonb_build_object('Main.java', E'public class Main {
    public static String impact(int partitions, int consumers, boolean cooperative, boolean statefulConsumer) {
        // TODO: assess the disruption caused by the next rebalance
        return "MINIMAL";
    }
}
'), 10, 256, true),
    ('senior-outbox-claim', 'Claim an Outbox Row Safely', 'Claim an Outbox Row Safely - practise the Messaging and Events section with a runnable exercise.', 'Senior', 'Senior', 'Messaging and Events', jsonb_build_object('Main.java', E'public class Main {
    public static boolean claim(String workerId, String owner, long leaseExpiresAt, long now) {
        // TODO: allow only unowned, expired or self-owned rows
        return owner != null && leaseExpiresAt <= now;
    }
}
'), 10, 256, true),
    ('senior-event-version-route', 'Route an Event by Version', 'Route an Event by Version - practise the Messaging and Events section with a runnable exercise.', 'Senior', 'Senior', 'Messaging and Events', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String handlerFor(int eventVersion, List<Integer> supportedVersions) {
        // TODO: prefer an exact version, otherwise fall back to the highest compatible handler
        return "v" + eventVersion;
    }
}
'), 10, 256, true),
    ('lead-event-governance', 'Define Event Governance Rules', 'Define Event Governance Rules - practise the Messaging and Events section with a runnable exercise.', 'Lead', 'Lead', 'Messaging and Events', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> governanceRules(boolean publiclyConsumed, boolean regulated) {
        // TODO: return the ordered governance rules for this event contract
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-saga-compensation', 'Order Saga Compensations', 'Order Saga Compensations - practise the Messaging and Events section with a runnable exercise.', 'Lead', 'Lead', 'Messaging and Events', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> compensationOrder(List<String> completedSteps) {
        // TODO: compensate in reverse completion order, skipping non-compensatable steps
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-message-router', 'Route Messages by Type', 'Route Messages by Type - practise the Enterprise Integration section with a runnable exercise.', 'Mid', 'Mid', 'Enterprise Integration', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static String channelFor(String messageType, Map<String, List<String>> routing) {
        // TODO: return the first channel that routes this message type, or the fallback
        return null;
    }
}
'), 10, 256, true),
    ('mid-splitter-aggregate', 'Aggregate Split Messages', 'Aggregate Split Messages - practise the Enterprise Integration section with a runnable exercise.', 'Mid', 'Mid', 'Enterprise Integration', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> recombine(List<List<String>> chunks, String correlationId) {
        // TODO: concatenate the payloads of every chunk carrying this correlation id
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-cron-next-run', 'Compute the Next Cron Fire Time', 'Compute the Next Cron Fire Time - practise the Enterprise Integration section with a runnable exercise.', 'Mid', 'Mid', 'Enterprise Integration', jsonb_build_object('Main.java', E'import java.time.LocalDateTime;

public class Main {
    public static String nextRun(String cron, LocalDateTime after) {
        // TODO: parse the five cron fields and find the first matching minute strictly after the given time
        return after.plusMinutes(1).toString();
    }
}
'), 10, 256, true),
    ('senior-batch-partition', 'Plan Batch Partitioning', 'Plan Batch Partitioning - practise the Enterprise Integration section with a runnable exercise.', 'Senior', 'Senior', 'Enterprise Integration', jsonb_build_object('Main.java', E'public class Main {
    public static int partitions(long rows, int chunkSize, int targetWorkers) {
        // TODO: bound the worker count by the target and by the number of whole chunks
        return targetWorkers;
    }
}
'), 10, 256, true),
    ('senior-file-idempotency', 'Detect Duplicate File Ingestion', 'Detect Duplicate File Ingestion - practise the Enterprise Integration section with a runnable exercise.', 'Senior', 'Senior', 'Enterprise Integration', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static boolean alreadyImported(String name, long size, Map<String, Long> imported) {
        // TODO: treat the same name and size as an already imported file
        return imported.containsKey(name);
    }
}
'), 10, 256, true),
    ('junior-path-template', 'Build a Resource Path', 'Build a Resource Path - practise the API Design section with a runnable exercise.', 'Junior', 'Junior', 'API Design', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String path(String base, List<String> segments) {
        // TODO: join the segments with single slashes and encode spaces
        StringBuilder out = new StringBuilder(base == null ? "" : base);
        if (segments != null) {
            for (String segment : segments) {
                out.append(''/'').append(segment);
            }
        }
        return out.toString();
    }
}
'), 10, 256, true),
    ('junior-status-code-choice', 'Choose a Success Status Code', 'Choose a Success Status Code - practise the API Design section with a runnable exercise.', 'Junior', 'Junior', 'API Design', jsonb_build_object('Main.java', E'public class Main {
    public static int statusFor(String action) {
        // TODO: map each action to the success status code it should return
        return 200;
    }
}
'), 10, 256, true),
    ('junior-query-filter-parse', 'Parse Filter Query Parameters', 'Parse Filter Query Parameters - practise the API Design section with a runnable exercise.', 'Junior', 'Junior', 'API Design', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static Map<String, String> parseFilters(String query) {
        // TODO: decode every key=value pair and ignore blanks and duplicates
        Map<String, String> filters = new HashMap<>();
        if (query == null) {
            return filters;
        }
        for (String pair : query.split("&")) {
            String[] parts = pair.split("=");
            if (parts.length == 2) {
                filters.put(parts[0], parts[1]);
            }
        }
        return filters;
    }
}
'), 10, 256, true),
    ('mid-etag-compute', 'Compute a Strong ETag', 'Compute a Strong ETag - practise the API Design section with a runnable exercise.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'public class Main {
    public static String etag(byte[] body, int version) {
        // TODO: hash the body together with the version into a strong quoted ETag
        return "\"" + (body == null ? 0 : body.length) + "\"";
    }
}
'), 10, 256, true),
    ('mid-cursor-pagination', 'Encode and Decode a Page Cursor', 'Encode and Decode a Page Cursor - practise the API Design section with a runnable exercise.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'public class Main {
    public static String encode(String sortKey, String id) {
        // TODO: produce a URL-safe, unpadded base64url cursor
        return sortKey + ":" + id;
    }

    public static String[] decode(String cursor) {
        // TODO: reverse encode, returning an empty array for malformed input
        return cursor.split(":");
    }
}
'), 10, 256, true),
    ('mid-problem-json', 'Build an RFC 9457 Problem Response', 'Build an RFC 9457 Problem Response - practise the API Design section with a runnable exercise.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static Map<String, Object> problem(int status, String detail, String instance) {
        // TODO: build the RFC 9457 members with the standard title for the status
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("status", status);
        body.put("detail", detail);
        body.put("instance", instance);
        return body;
    }
}
'), 10, 256, true),
    ('mid-content-negotiation', 'Negotiate a Response Format', 'Negotiate a Response Format - practise the API Design section with a runnable exercise.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String negotiate(String acceptHeader, List<String> supported) {
        // TODO: score the accepted types and pick the supported type with the highest quality
        return supported.get(0);
    }
}
'), 10, 256, true),
    ('mid-rate-limit-headers', 'Build Rate Limit Headers', 'Build Rate Limit Headers - practise the API Design section with a runnable exercise.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static Map<String, String> headers(int limit, int remaining, long resetEpochSeconds) {
        // TODO: build the standard rate limit headers and clamp remaining
        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("RateLimit-Limit", String.valueOf(limit));
        headers.put("RateLimit-Remaining", String.valueOf(remaining));
        headers.put("RateLimit-Reset", String.valueOf(resetEpochSeconds));
        return headers;
    }
}
'), 10, 256, true),
    ('senior-breaking-change', 'Detect a Breaking API Change', 'Detect a Breaking API Change - practise the API Design section with a runnable exercise.', 'Senior', 'Senior', 'API Design', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static List<String> breakingChanges(Map<String, String> before, Map<String, String> after) {
        // TODO: report removed fields, narrowed numeric types and new required fields
        List<String> changes = new ArrayList<>();
        if (before == null || after == null) {
            return changes;
        }
        for (String field : before.keySet()) {
            if (!after.containsKey(field)) {
                changes.add(field);
            }
        }
        return changes;
    }
}
'), 10, 256, true),
    ('senior-graphql-depth', 'Limit GraphQL Query Depth', 'Limit GraphQL Query Depth - practise the API Design section with a runnable exercise.', 'Senior', 'Senior', 'API Design', jsonb_build_object('Main.java', E'public class Main {
    public static int depth(String query) {
        // TODO: count the deepest selection set, ignoring braces inside strings and comments
        int max = 0;
        for (int i = 0; i < query.length(); i++) {
            if (query.charAt(i) == ''{'') {
                max++;
            }
        }
        return max;
    }
}
'), 10, 256, true),
    ('senior-grpc-field-safety', 'Check Protobuf Field Number Safety', 'Check Protobuf Field Number Safety - practise the API Design section with a runnable exercise.', 'Senior', 'Senior', 'API Design', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static List<Integer> unsafeFields(List<Integer> fieldNumbers) {
        // TODO: flag the reserved range and numbers above the protobuf maximum
        List<Integer> unsafe = new ArrayList<>();
        return unsafe;
    }
}
'), 10, 256, true),
    ('junior-header-parse', 'Parse HTTP Headers', 'Parse HTTP Headers - practise the HTTP and Networking section with a runnable exercise.', 'Junior', 'Junior', 'HTTP and Networking', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static Map<String, String> parse(String rawHeaders) {
        // TODO: split the block into lines and keep the last value per lower-cased key
        Map<String, String> headers = new HashMap<>();
        if (rawHeaders == null) {
            return headers;
        }
        for (String line : rawHeaders.split("\n")) {
            headers.put(line, "");
        }
        return headers;
    }
}
'), 10, 256, true),
    ('junior-uri-normalise', 'Normalise a Request URI', 'Normalise a Request URI - practise the HTTP and Networking section with a runnable exercise.', 'Junior', 'Junior', 'HTTP and Networking', jsonb_build_object('Main.java', E'public class Main {
    public static String normalise(String path) {
        // TODO: collapse slashes, resolve dot segments and drop the trailing slash
        if (path == null || path.isEmpty()) {
            return "/";
        }
        return path;
    }
}
'), 10, 256, true),
    ('junior-status-class', 'Classify an HTTP Status', 'Classify an HTTP Status - practise the HTTP and Networking section with a runnable exercise.', 'Junior', 'Junior', 'HTTP and Networking', jsonb_build_object('Main.java', E'public class Main {
    public static String classify(int status) {
        // TODO: map the numeric status to its standard class name
        return status == 200 ? "SUCCESS" : "UNKNOWN";
    }
}
'), 10, 256, true),
    ('mid-cache-freshness', 'Compute Response Freshness', 'Compute Response Freshness - practise the HTTP and Networking section with a runnable exercise.', 'Mid', 'Mid', 'HTTP and Networking', jsonb_build_object('Main.java', E'public class Main {
    public static boolean usable(long ageSeconds, long maxAgeSeconds, boolean mustRevalidate) {
        // TODO: an entry is usable only while it is fresh and revalidation is not required
        return true;
    }
}
'), 10, 256, true),
    ('mid-retry-safety', 'Decide Whether a Request May Retry', 'Decide Whether a Request May Retry - practise the HTTP and Networking section with a runnable exercise.', 'Mid', 'Mid', 'HTTP and Networking', jsonb_build_object('Main.java', E'public class Main {
    public static boolean retryable(String method, int status, boolean idempotencyKeyPresent) {
        // TODO: retry safe methods and idempotency-keyed requests on retryable statuses
        return true;
    }
}
'), 10, 256, true),
    ('mid-timeout-budget', 'Split a Request Timeout Budget', 'Split a Request Timeout Budget - practise the HTTP and Networking section with a runnable exercise.', 'Mid', 'Mid', 'HTTP and Networking', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static Map<String, Long> budget(long totalMillis, int attempts) {
        // TODO: split the total into a per-attempt connect and read budget
        Map<String, Long> plan = new LinkedHashMap<>();
        plan.put("budget", totalMillis);
        plan.put("connect", totalMillis);
        plan.put("read", totalMillis);
        return plan;
    }
}
'), 10, 256, true),
    ('mid-cors-decision', 'Decide a CORS Response', 'Decide a CORS Response - practise the HTTP and Networking section with a runnable exercise.', 'Mid', 'Mid', 'HTTP and Networking', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static List<String> headers(String origin, String method, Set<String> allowedOrigins, boolean credentials) {
        // TODO: allow only listed origins and never combine a wildcard with credentials
        List<String> headers = new ArrayList<>();
        headers.add("Access-Control-Allow-Origin: " + origin);
        return headers;
    }
}
'), 10, 256, true),
    ('senior-tls-policy', 'Evaluate a TLS Policy', 'Evaluate a TLS Policy - practise the HTTP and Networking section with a runnable exercise.', 'Senior', 'Senior', 'HTTP and Networking', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static List<String> violations(String protocol, String cipherSuite, boolean verifyHostname, boolean verifyChain) {
        // TODO: collect and sort every policy violation
        List<String> findings = new ArrayList<>();
        return findings;
    }
}
'), 10, 256, true),
    ('senior-http2-decision', 'Decide on HTTP/2 Multiplexing', 'Decide on HTTP/2 Multiplexing - practise the HTTP and Networking section with a runnable exercise.', 'Senior', 'Senior', 'HTTP and Networking', jsonb_build_object('Main.java', E'public class Main {
    public static String advise(int concurrentRequests, boolean headOfLineBlocking, boolean serverPush) {
        // TODO: return the documented protocol recommendation
        return "keep http/1.1";
    }
}
'), 10, 256, true),
    ('mid-circuit-state', 'Advance a Circuit Breaker', 'Advance a Circuit Breaker - practise the Microservices section with a runnable exercise.', 'Mid', 'Mid', 'Microservices', jsonb_build_object('Main.java', E'public class Main {
    public static String nextState(String state, boolean callSucceeded, int failureRate, int threshold) {
        // TODO: advance CLOSED, OPEN and HALF_OPEN using the failure rate and the threshold
        return state;
    }
}
'), 10, 256, true),
    ('mid-bulkhead-limit', 'Size a Bulkhead', 'Size a Bulkhead - practise the Microservices section with a runnable exercise.', 'Mid', 'Mid', 'Microservices', jsonb_build_object('Main.java', E'public class Main {
    public static int limit(int dependencyCapacity, int dependencies, int reservePercent) {
        // TODO: keep the reserve, divide the rest, and give every dependency at least one permit
        return 0;
    }
}
'), 10, 256, true),
    ('mid-discovery-cache', 'Handle Stale Service Discovery Data', 'Handle Stale Service Discovery Data - practise the Microservices section with a runnable exercise.', 'Mid', 'Mid', 'Microservices', jsonb_build_object('Main.java', E'public class Main {
    public static String action(long cachedAgeMillis, long ttlMillis, boolean registryAvailable) {
        // TODO: USE_CACHE while fresh, REFRESH when stale and the registry is reachable, FAIL_FAST otherwise
        return "USE_CACHE";
    }
}
'), 10, 256, true),
    ('mid-correlation-id', 'Propagate a Correlation ID', 'Propagate a Correlation ID - practise the Microservices section with a runnable exercise.', 'Mid', 'Mid', 'Microservices', jsonb_build_object('Main.java', E'import java.util.function.Supplier;

public class Main {
    public static String resolve(String inboundHeader, Supplier<String> generator) {
        // TODO: keep a valid inbound id, otherwise generate one
        return "";
    }
}
'), 10, 256, true),
    ('mid-error-budget', 'Track an Error Budget', 'Track an Error Budget - practise the Microservices section with a runnable exercise.', 'Mid', 'Mid', 'Microservices', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Object> budget(double target, long totalRequests, long failedRequests) {
        // TODO: report allowedFraction, consumedFraction, remainingFraction and exhausted
        return Map.of();
    }
}
'), 10, 256, true),
    ('senior-saga-compensate', 'Compensate a Failed Saga Step', 'Compensate a Failed Saga Step - practise the Microservices section with a runnable exercise.', 'Senior', 'Senior', 'Microservices', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> compensate(List<String> completed, String failedStep) {
        // TODO: return the compensation actions in reverse completion order
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-tenant-routing', 'Route a Request by Tenant', 'Route a Request by Tenant - practise the Microservices section with a runnable exercise.', 'Senior', 'Senior', 'Microservices', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static String datasourceFor(String tenantId, Map<String, String> tenantTier) {
        // TODO: route regulated tenants to their own datasource
        return "pooled";
    }
}
'), 10, 256, true),
    ('senior-strangler-route', 'Route Traffic During a Strangler Migration', 'Route Traffic During a Strangler Migration - practise the Microservices section with a runnable exercise.', 'Senior', 'Senior', 'Microservices', jsonb_build_object('Main.java', E'public class Main {
    public static String target(int rolloutPercent, String userId, boolean legacyHealthy) {
        // TODO: route by user bucket and fall over when legacy is unhealthy
        return "LEGACY";
    }
}
'), 10, 256, true),
    ('senior-contract-compat', 'Check Consumer Contract Compatibility', 'Check Consumer Contract Compatibility - practise the Microservices section with a runnable exercise.', 'Senior', 'Senior', 'Microservices', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, String> provided, Map<String, String> required) {
        // TODO: report missing or type-mismatched required fields
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-resilience-standard', 'Set a Resilience Standard', 'Set a Resilience Standard - practise the Microservices section with a runnable exercise.', 'Lead', 'Lead', 'Microservices', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> mandatoryPatterns(boolean callsRemoteDependency, boolean writesData, boolean userFacing) {
        // TODO: list the mandatory resilience patterns in their canonical order
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-monolith-split', 'Plan a Monolith Split', 'Plan a Monolith Split - practise the Microservices section with a runnable exercise.', 'Lead', 'Lead', 'Microservices', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;
import java.util.Set;

public class Main {
    public static List<String> splitOrder(Map<String, Set<String>> coupling) {
        // TODO: extract the least-coupled module first, and detect cycles
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-quality-tactic', 'Pick a Quality Attribute Tactic', 'Pick a Quality Attribute Tactic - practise the Architecture section with a runnable exercise.', 'Senior', 'Senior', 'Architecture', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> tactics(String attribute, boolean latencyCritical) {
        // TODO: return the documented tactics for availability, performance, modifiability or security
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-adr-review', 'Review an Architecture Decision Record', 'Review an Architecture Decision Record - practise the Architecture section with a runnable exercise.', 'Senior', 'Senior', 'Architecture', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> missingSections(Map<String, String> record) {
        // TODO: flag absent context, options, decision, consequences or revisit criteria
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-instability-metric', 'Compute Component Instability', 'Compute Component Instability - practise the Architecture section with a runnable exercise.', 'Senior', 'Senior', 'Architecture', jsonb_build_object('Main.java', E'public class Main {
    public static double instability(int afferent, int efferent) {
        // TODO: compute efferent / (afferent + efferent), treating no coupling as zero
        return 0;
    }
}
'), 10, 256, true),
    ('lead-roadmap-sequence', 'Sequence a Platform Roadmap', 'Sequence a Platform Roadmap - practise the Architecture section with a runnable exercise.', 'Lead', 'Lead', 'Architecture', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Main {
    public static List<String> sequence(List<String> items, Map<String, Set<String>> blockedBy) {
        // TODO: order items so blockers come first, and return an empty list on cycles
        return items == null ? List.of() : new ArrayList<>(items);
    }
}
'), 10, 256, true),
    ('lead-cost-capacity', 'Balance Cost and Capacity', 'Balance Cost and Capacity - practise the Architecture section with a runnable exercise.', 'Lead', 'Lead', 'Architecture', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> recommendations(double utilisation, double p99Millis, double budgetUtilisation) {
        // TODO: recommend scaling and cost actions from the documented thresholds
        return List.of();
    }
}
'), 10, 256, true),
    ('principal-system-shape', 'Choose a System Shape', 'Choose a System Shape - practise the Architecture section with a runnable exercise.', 'Principal', 'Principal', 'Architecture', jsonb_build_object('Main.java', E'public class Main {
    public static String shape(int teamCount, boolean independentDeployNeeded, boolean strongConsistencyRequired) {
        // TODO: choose MODULAR_MONOLITH, SERVICES or EVENT_DRIVEN from the documented rules
        return "MODULAR_MONOLITH";
    }
}
'), 10, 256, true),
    ('principal-governance', 'Choose a Governance Model', 'Choose a Governance Model - practise the Architecture section with a runnable exercise.', 'Principal', 'Principal', 'Architecture', jsonb_build_object('Main.java', E'public class Main {
    public static String governance(boolean regulated, int teamCount, boolean centralPlatformTeam) {
        // TODO: choose CENTRAL_REVIEW, FEDERATED or PLATFORM_TEAM from the documented rules
        return "CENTRAL_REVIEW";
    }
}
'), 10, 256, true),
    ('mid-value-object-equality', 'Implement Value Object Equality', 'Implement Value Object Equality - practise the Domain-Driven Design section with a runnable exercise.', 'Mid', 'Mid', 'Domain-Driven Design', jsonb_build_object('Main.java', E'public class Main {
    public record Money(long cents, String currency) {
        // TODO: normalise the currency to upper case in a compact constructor,
        // treating a null currency as an empty string
        public Money {
        }

        public boolean sameValue(Money other) {
            // TODO: compare cents and the normalised currency, returning false for null
            return false;
        }
    }
}
'), 10, 256, true),
    ('mid-aggregate-invariant', 'Enforce an Aggregate Invariant', 'Enforce an Aggregate Invariant - practise the Domain-Driven Design section with a runnable exercise.', 'Mid', 'Mid', 'Domain-Driven Design', jsonb_build_object('Main.java', E'public class Main {
    public static boolean canAddItem(int currentItems, int maxItems, int requested) {
        // TODO: allow only a positive request that still fits inside the aggregate invariant
        return requested > 0;
    }
}
'), 10, 256, true),
    ('mid-domain-event-name', 'Name a Domain Event', 'Name a Domain Event - practise the Domain-Driven Design section with a runnable exercise.', 'Mid', 'Mid', 'Domain-Driven Design', jsonb_build_object('Main.java', E'public class Main {
    public static String eventName(String aggregate, String action) {
        // TODO: build a past-tense PascalCase event name such as OrderPlaced
        return aggregate + action;
    }
}
'), 10, 256, true),
    ('mid-repository-contract', 'Define a Repository Contract', 'Define a Repository Contract - practise the Domain-Driven Design section with a runnable exercise.', 'Mid', 'Mid', 'Domain-Driven Design', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> contractMethods(boolean needsLookupById, boolean needsSave, boolean needsQueryByOwner) {
        // TODO: return only the domain-language methods this aggregate really needs,
        // in the order findById, save, findByOwner
        return List.of("selectById", "insert", "selectByOwner");
    }
}
'), 10, 256, true),
    ('mid-ubiquitous-terms', 'Check Ubiquitous Language Consistency', 'Check Ubiquitous Language Consistency - practise the Domain-Driven Design section with a runnable exercise.', 'Mid', 'Mid', 'Domain-Driven Design', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> inconsistencies(Map<String, String> codeNames, Map<String, String> glossary) {
        // TODO: report every concept whose code name differs from the glossary,
        // ignoring case and surrounding spaces, sorted by concept
        List<String> result = new ArrayList<>();
        if (codeNames == null || glossary == null) {
            return result;
        }
        for (String concept : codeNames.keySet()) {
            if (glossary.containsKey(concept)) {
                result.add(concept + ": code uses ''" + codeNames.get(concept)
                        + "'' but glossary says ''" + glossary.get(concept) + "''");
            }
        }
        return result;
    }
}
'), 10, 256, true),
    ('senior-context-map', 'Map Bounded Context Relationships', 'Map Bounded Context Relationships - practise the Domain-Driven Design section with a runnable exercise.', 'Senior', 'Senior', 'Domain-Driven Design', jsonb_build_object('Main.java', E'public class Main {
    public static String relationship(boolean upstreamControlsModel, boolean downstreamAdoptsUpstream,
            boolean translationLayer) {
        // TODO: derive the context mapping pattern from the three facts
        return "CUSTOMER_SUPPLIER";
    }
}
'), 10, 256, true),
    ('senior-anticorruption-translate', 'Translate Across an Anticorruption Layer', 'Translate Across an Anticorruption Layer - practise the Domain-Driven Design section with a runnable exercise.', 'Senior', 'Senior', 'Domain-Driven Design', jsonb_build_object('Main.java', E'import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> translate(Map<String, Object> external, Map<String, String> fieldMap) {
        // TODO: copy the mapped fields into the internal model and drop everything else
        return external == null ? new LinkedHashMap<>() : new LinkedHashMap<>(external);
    }
}
'), 10, 256, true),
    ('senior-event-replay', 'Rebuild State by Replaying Events', 'Rebuild State by Replaying Events - practise the Domain-Driven Design section with a runnable exercise.', 'Senior', 'Senior', 'Domain-Driven Design', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static int replay(List<String> events, int initialBalance) {
        // TODO: apply CREDIT and DEBIT events to the starting balance,
        // throwing when a debit would take the balance below zero
        return initialBalance;
    }
}
'), 10, 256, true),
    ('junior-assertion-choice', 'Choose the Right Assertion', 'Choose the Right Assertion - practise the Testing section with a runnable exercise.', 'Junior', 'Junior', 'Testing', jsonb_build_object('Main.java', E'public class Main {
    public static String assertionFor(String check) {
        // TODO: return the AssertJ method name that expresses the requested check
        return "unknown";
    }
}
'), 10, 256, true),
    ('junior-test-name-quality', 'Judge a Test Name', 'Judge a Test Name - practise the Testing section with a runnable exercise.', 'Junior', 'Junior', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> problems(String testName) {
        // TODO: judge the name and report every problem you find
        return List.of("missing-condition");
    }
}
'), 10, 256, true),
    ('junior-test-structure', 'Order an Arrange-Act-Assert Test', 'Order an Arrange-Act-Assert Test - practise the Testing section with a runnable exercise.', 'Junior', 'Junior', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> phases(List<String> lines) {
        // TODO: classify every line as SETUP, EXERCISE, VERIFY or NOISE, in order
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-parameterised-cases', 'Build Parameterised Test Cases', 'Build Parameterised Test Cases - practise the Testing section with a runnable exercise.', 'Mid', 'Mid', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<Object[]> cases(List<String> inputs) {
        // TODO: turn each input into a name/input/expected row that covers edge cases
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-interaction-verify', 'Verify an Interaction', 'Verify an Interaction - practise the Testing section with a runnable exercise.', 'Mid', 'Mid', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> verifyPlan(boolean sendCalled, int sendCount, boolean idempotencyRequired) {
        // TODO: list every verification the test must perform
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-container-lifecycle', 'Choose a Test Container Lifecycle', 'Choose a Test Container Lifecycle - practise the Testing section with a runnable exercise.', 'Mid', 'Mid', 'Testing', jsonb_build_object('Main.java', E'public class Main {
    public static String lifecycleFor(boolean needsMutableState, int testCount, long startupSeconds) {
        // TODO: pick a lifecycle using only the documented rules
        return "PER_CLASS";
    }
}
'), 10, 256, true),
    ('mid-flaky-detection', 'Detect a Flaky Test', 'Detect a Flaky Test - practise the Testing section with a runnable exercise.', 'Mid', 'Mid', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static boolean flaky(List<Boolean> historicalResults) {
        // TODO: decide whether the recorded results prove flakiness
        return false;
    }
}
'), 10, 256, true),
    ('senior-contract-verify', 'Verify a Consumer Contract', 'Verify a Consumer Contract - practise the Testing section with a runnable exercise.', 'Senior', 'Senior', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> contract, Map<String, Object> actual) {
        // TODO: report missing keys and type mismatches, sorted
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-mutation-score', 'Interpret a Mutation Score', 'Interpret a Mutation Score - practise the Testing section with a runnable exercise.', 'Senior', 'Senior', 'Testing', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> findings(int killed, int survived, int noCoverage) {
        // TODO: report the mutation score and the weakest category
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-pyramid-allocation', 'Allocate Tests Across the Pyramid', 'Allocate Tests Across the Pyramid - practise the Testing section with a runnable exercise.', 'Senior', 'Senior', 'Testing', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Integer> allocate(int totalTests, boolean logicHeavy, boolean ioHeavy) {
        // TODO: split the tests across unit, integration and end-to-end
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-coverage-threshold', 'Set a Coverage Threshold', 'Set a Coverage Threshold - practise the Quality and Static Analysis section with a runnable exercise.', 'Mid', 'Mid', 'Quality and Static Analysis', jsonb_build_object('Main.java', E'public class Main {
    public static int thresholdFor(String moduleKind) {
        // TODO: return the documented line-coverage threshold for the module kind
        return 0;
    }
}
'), 10, 256, true),
    ('mid-severity-mapping', 'Map Static Analysis Severity', 'Map Static Analysis Severity - practise the Quality and Static Analysis section with a runnable exercise.', 'Mid', 'Mid', 'Quality and Static Analysis', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static String gate(List<String> severities, int blockerThreshold) {
        // TODO: apply the documented quality gate rules
        return "PASS";
    }
}
'), 10, 256, true),
    ('senior-benchmark-validity', 'Validate a Benchmark Design', 'Validate a Benchmark Design - practise the Quality and Static Analysis section with a runnable exercise.', 'Senior', 'Senior', 'Quality and Static Analysis', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> problems(Map<String, String> benchmark) {
        // TODO: audit the benchmark setup and report every configuration problem
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-load-model', 'Choose a Load Test Model', 'Choose a Load Test Model - practise the Quality and Static Analysis section with a runnable exercise.', 'Senior', 'Senior', 'Quality and Static Analysis', jsonb_build_object('Main.java', E'public class Main {
    public static String model(double arrivalRate, boolean constantTraffic, int maxConcurrency) {
        // TODO: choose OPEN or CLOSED using only the documented rules
        return "";
    }
}
'), 10, 256, true),
    ('junior-log-level', 'Choose a Log Level', 'Choose a Log Level - practise the Observability section with a runnable exercise.', 'Junior', 'Junior', 'Observability', jsonb_build_object('Main.java', E'public class Main {
    public static String levelFor(String event) {
        // TODO: map the event category to the level a responder would act on
        return "INFO";
    }
}
'), 10, 256, true),
    ('junior-metric-name', 'Validate a Metric Name', 'Validate a Metric Name - practise the Observability section with a runnable exercise.', 'Junior', 'Junior', 'Observability', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> problems(String name) {
        // TODO: report every naming convention violation, in the documented order
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-alert-condition', 'Write an Alert Condition', 'Write an Alert Condition - practise the Observability section with a runnable exercise.', 'Junior', 'Junior', 'Observability', jsonb_build_object('Main.java', E'public class Main {
    public static String condition(String metric, double threshold, String window) {
        // TODO: reject cause-based metrics and build the symptom condition
        return "";
    }
}
'), 10, 256, true),
    ('mid-cardinality-risk', 'Assess Metric Cardinality', 'Assess Metric Cardinality - practise the Observability section with a runnable exercise.', 'Mid', 'Mid', 'Observability', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static long cardinality(List<Integer> tagSizes) {
        // TODO: multiply the tag cardinalities, clamping instead of overflowing
        return 0;
    }

    public static boolean risky(List<Integer> tagSizes) {
        // TODO: compare the cardinality with the documented series limit
        return false;
    }
}
'), 10, 256, true),
    ('mid-histogram-buckets', 'Choose Histogram Buckets', 'Choose Histogram Buckets - practise the Observability section with a runnable exercise.', 'Mid', 'Mid', 'Observability', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<Double> buckets(double sloMillis) {
        // TODO: build ascending buckets that resolve the SLO region finely
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-trace-sampling', 'Choose a Trace Sampling Strategy', 'Choose a Trace Sampling Strategy - practise the Observability section with a runnable exercise.', 'Mid', 'Mid', 'Observability', jsonb_build_object('Main.java', E'public class Main {
    public static String strategy(double requestsPerSecond, boolean errorsMatter) {
        // TODO: choose ALWAYS_ON, PROBABILISTIC or TAIL_BASED
        return "PROBABILISTIC";
    }
}
'), 10, 256, true),
    ('mid-burn-rate-alert', 'Compute a Burn Rate Alert', 'Compute a Burn Rate Alert - practise the Observability section with a runnable exercise.', 'Mid', 'Mid', 'Observability', jsonb_build_object('Main.java', E'public class Main {
    public static boolean alert(double errorBudgetConsumedFraction, double timeWindowFraction, double factor) {
        // TODO: compare the burn rate with the alert factor
        return false;
    }
}
'), 10, 256, true),
    ('senior-tail-sampling', 'Configure Tail-Based Sampling', 'Configure Tail-Based Sampling - practise the Observability section with a runnable exercise.', 'Senior', 'Senior', 'Observability', jsonb_build_object('Main.java', E'public class Main {
    public static int sampleCount(int traces, int errors, double errorSampleRate, double baselineRate) {
        // TODO: keep the error sample, add a baseline sample, and stay within traces
        return 0;
    }
}
'), 10, 256, true),
    ('senior-incident-triage', 'Triage an Incident', 'Triage an Incident - practise the Observability section with a runnable exercise.', 'Senior', 'Senior', 'Observability', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> triageOrder(boolean recentChange, boolean errorSpike,
                                           boolean latencySpike, boolean saturation) {
        // TODO: order the investigation steps, symptom first
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-slo-alert-design', 'Design an SLO Alert', 'Design an SLO Alert - practise the Observability section with a runnable exercise.', 'Senior', 'Senior', 'Observability', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Object> alert(String sli, double target,
                                            int fastWindowMinutes, int slowWindowMinutes) {
        // TODO: build the multi-window burn-rate alert definition
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-cache-ttl', 'Choose a Cache TTL', 'Choose a Cache TTL - practise the Performance and Caching section with a runnable exercise.', 'Mid', 'Mid', 'Performance and Caching', jsonb_build_object('Main.java', E'public class Main {
    public static int ttlSeconds(String dataVolatility, int acceptableStalenessSeconds, int sourceLatencyMillis) {
        // TODO: bound the TTL by accepted staleness and by ten times the source latency
        return 0;
    }
}
'), 10, 256, true),
    ('mid-invalidation-set', 'Compute Cache Keys to Invalidate', 'Compute Cache Keys to Invalidate - practise the Performance and Caching section with a runnable exercise.', 'Mid', 'Mid', 'Performance and Caching', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static Set<String> invalidate(String entity, String id, Set<String> knownKeys) {
        // TODO: return exactly the known keys affected by a write to entity id
        return Set.of();
    }
}
'), 10, 256, true),
    ('mid-pool-sizing', 'Size a Connection Pool', 'Size a Connection Pool - practise the Performance and Caching section with a runnable exercise.', 'Mid', 'Mid', 'Performance and Caching', jsonb_build_object('Main.java', E'public class Main {
    public static int poolSize(int databaseCores, double serviceTimeMillis, double waitBudgetMillis) {
        // TODO: size the pool from cores, service time and the wait budget
        return 2;
    }
}
'), 10, 256, true),
    ('senior-target-choice', 'Choose a Performance Target', 'Choose a Performance Target - practise the Performance and Caching section with a runnable exercise.', 'Senior', 'Senior', 'Performance and Caching', jsonb_build_object('Main.java', E'public class Main {
    public static String target(boolean userFacing, boolean batch, double p99BudgetMillis) {
        // TODO: choose THROUGHPUT or LATENCY from the documented cutoffs
        return "LATENCY";
    }
}
'), 10, 256, true),
    ('senior-format-choice', 'Choose a Serialisation Format', 'Choose a Serialisation Format - practise the Performance and Caching section with a runnable exercise.', 'Senior', 'Senior', 'Performance and Caching', jsonb_build_object('Main.java', E'public class Main {
    public static String format(boolean humanReadable, boolean schemaEvolution,
                                boolean highVolume, boolean browserClient) {
        // TODO: choose JSON, PROTOBUF or AVRO from the documented rules
        return "JSON";
    }
}
'), 10, 256, true),
    ('senior-regression-gate', 'Gate on a Performance Regression', 'Gate on a Performance Regression - practise the Performance and Caching section with a runnable exercise.', 'Senior', 'Senior', 'Performance and Caching', jsonb_build_object('Main.java', E'public class Main {
    public static String verdict(double baselineP99, double candidateP99, double tolerance) {
        // TODO: compare the change against the tolerance and report the percentage
        return "";
    }
}
'), 10, 256, true),
    ('mid-error-fallback', 'Add a Reactive Fallback', 'Add a Reactive Fallback - practise the Reactive Programming section with a runnable exercise.', 'Mid', 'Mid', 'Reactive Programming', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> signals(boolean mainFails, boolean fallbackAvailable) {
        // TODO: model onErrorResume: the fallback runs only when the main sequence fails,
        // and an empty fallback completes without emitting a value.
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-backpressure-policy', 'Choose a Reactive Backpressure Policy', 'Choose a Reactive Backpressure Policy - practise the Reactive Programming section with a runnable exercise.', 'Mid', 'Mid', 'Reactive Programming', jsonb_build_object('Main.java', E'public class Main {
    public static String policy(boolean canDrop, boolean mustBeLossless, boolean slowConsumer) {
        // TODO: choose the overflow policy using the documented priority order
        return "BUFFER";
    }
}
'), 10, 256, true),
    ('mid-scheduler-choice', 'Choose a Reactive Scheduler', 'Choose a Reactive Scheduler - practise the Reactive Programming section with a runnable exercise.', 'Mid', 'Mid', 'Reactive Programming', jsonb_build_object('Main.java', E'public class Main {
    public static String scheduler(String workload) {
        // TODO: map the workload to immediate, single, parallel, elastic or boundedElastic
        return "parallel";
    }
}
'), 10, 256, true),
    ('mid-context-value', 'Propagate a Reactive Context Value', 'Propagate a Reactive Context Value - practise the Reactive Programming section with a runnable exercise.', 'Mid', 'Mid', 'Reactive Programming', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static boolean visible(String readerKey, Set<String> contextKeys) {
        // TODO: a reader sees only the keys written by its own subscription
        return contextKeys != null;
    }
}
'), 10, 256, true),
    ('senior-blocking-detect', 'Detect Blocking in a Reactive Pipeline', 'Detect Blocking in a Reactive Pipeline - practise the Reactive Programming section with a runnable exercise.', 'Senior', 'Senior', 'Reactive Programming', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<Integer> blockingLines(List<String> pipeline) {
        // TODO: scan the pipeline and report the 1-based lines that call blocking apis
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-reactive-or-thread', 'Choose Reactive or Virtual Threads', 'Choose Reactive or Virtual Threads - practise the Reactive Programming section with a runnable exercise.', 'Senior', 'Senior', 'Reactive Programming', jsonb_build_object('Main.java', E'public class Main {
    public static String choose(boolean ioBound, boolean streamingSource, boolean teamKnowsReactor, int fanOut) {
        // TODO: recommend reactive or virtual threads using the documented decision rules
        return "virtual-threads";
    }
}
'), 10, 256, true),
    ('senior-streaming-backpressure', 'Handle Streaming Backpressure', 'Handle Streaming Backpressure - practise the Reactive Programming section with a runnable exercise.', 'Senior', 'Senior', 'Reactive Programming', jsonb_build_object('Main.java', E'public class Main {
    public static long requested(long consumerDemand, long buffered, long limit) {
        // TODO: clamp the demand to the remaining buffer capacity, never negative
        return consumerDemand;
    }
}
'), 10, 256, true),
    ('junior-dockerfile-order', 'Order Dockerfile Instructions', 'Order Dockerfile Instructions - practise the Containers and Kubernetes section with a runnable exercise.', 'Junior', 'Junior', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> optimise(List<String> instructions) {
        // TODO: return a new list with dependency resolution moved before copying sources
        return instructions;
    }
}
'), 10, 256, true),
    ('junior-env-injection', 'Inject Configuration as Environment', 'Inject Configuration as Environment - practise the Containers and Kubernetes section with a runnable exercise.', 'Junior', 'Junior', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, String> toEnvironment(Map<String, String> config) {
        // TODO: convert every key to its environment variable form
        return null;
    }
}
'), 10, 256, true),
    ('junior-probe-choice', 'Choose a Kubernetes Probe', 'Choose a Kubernetes Probe - practise the Containers and Kubernetes section with a runnable exercise.', 'Junior', 'Junior', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'public class Main {
    public static String probeFor(String purpose) {
        // TODO: map the purpose to LIVENESS, READINESS, STARTUP or NONE
        return "NONE";
    }
}
'), 10, 256, true),
    ('mid-resource-limits', 'Set Pod Resource Limits', 'Set Pod Resource Limits - practise the Containers and Kubernetes section with a runnable exercise.', 'Mid', 'Mid', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, String> limits(long heapMb, int cores) {
        // TODO: size the memory limit and the CPU request
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-hpa-target', 'Choose an HPA Target Metric', 'Choose an HPA Target Metric - practise the Containers and Kubernetes section with a runnable exercise.', 'Mid', 'Mid', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'public class Main {
    public static String metric(boolean cpuBound, boolean queueConsumer, boolean latencySensitive) {
        // TODO: choose the documented HPA target metric
        return "CPU_UTILIZATION";
    }
}
'), 10, 256, true),
    ('mid-config-merge', 'Merge Layered Configuration', 'Merge Layered Configuration - practise the Containers and Kubernetes section with a runnable exercise.', 'Mid', 'Mid', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, String> effective(List<Map<String, String>> layers) {
        // TODO: merge the layers, letting secrets win over plain config
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-shutdown-grace', 'Choose a Shutdown Grace Period', 'Choose a Shutdown Grace Period - practise the Containers and Kubernetes section with a runnable exercise.', 'Mid', 'Mid', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'public class Main {
    public static int graceSeconds(int longestRequestSeconds, int drainSeconds, int terminationGraceSeconds) {
        // TODO: choose a grace period that fits inside the pod termination budget
        return 0;
    }
}
'), 10, 256, true),
    ('senior-image-reduction', 'Reduce an Image Size', 'Reduce an Image Size - practise the Containers and Kubernetes section with a runnable exercise.', 'Senior', 'Senior', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> measures(boolean hasBuildToolsInRuntime, boolean multiStage, String baseImage) {
        // TODO: recommend the documented reduction measures
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-pod-security', 'Harden a Pod Security Context', 'Harden a Pod Security Context - practise the Containers and Kubernetes section with a runnable exercise.', 'Senior', 'Senior', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> securityContext) {
        // TODO: flag root user, privileged mode and a writable root filesystem
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-rollout-strategy', 'Choose a Deployment Strategy', 'Choose a Deployment Strategy - practise the Containers and Kubernetes section with a runnable exercise.', 'Senior', 'Senior', 'Containers and Kubernetes', jsonb_build_object('Main.java', E'public class Main {
    public static String strategy(boolean schemaChange, boolean breakingApi, int replicas) {
        // TODO: choose ROLLING, BLUE_GREEN or CANARY
        return "ROLLING";
    }
}
'), 10, 256, true),
    ('junior-secret-source', 'Choose a Secret Source', 'Choose a Secret Source - practise the Cloud and Delivery section with a runnable exercise.', 'Junior', 'Junior', 'Cloud and Delivery', jsonb_build_object('Main.java', E'public class Main {
    public static String sourceFor(boolean production, boolean local, boolean shortLived) {
        // TODO: choose the documented secret source
        return "SOURCE_CONTROL";
    }
}
'), 10, 256, true),
    ('junior-release-tag', 'Parse a Release Tag', 'Parse a Release Tag - practise the Cloud and Delivery section with a runnable exercise.', 'Junior', 'Junior', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, String> parse(String tag) {
        // TODO: extract version and optional build metadata
        return Map.of();
    }
}
'), 10, 256, true),
    ('junior-parity-check', 'Check Environment Parity', 'Check Environment Parity - practise the Cloud and Delivery section with a runnable exercise.', 'Junior', 'Junior', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> differences(Map<String, String> local, Map<String, String> deployed) {
        // TODO: report keys whose values differ
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-pipeline-gate', 'Order CI Pipeline Gates', 'Order CI Pipeline Gates - practise the Cloud and Delivery section with a runnable exercise.', 'Mid', 'Mid', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> gateOrder(boolean hasIntegrationTests, boolean securityScanRequired) {
        // TODO: order the gates from cheapest and most critical to slowest
        return List.of();
    }
}
'), 10, 256, true),
    ('mid-canary-percent', 'Choose a Canary Percentage', 'Choose a Canary Percentage - practise the Cloud and Delivery section with a runnable exercise.', 'Mid', 'Mid', 'Cloud and Delivery', jsonb_build_object('Main.java', E'public class Main {
    public static int percent(int totalUsers, int minimumSample, boolean highRisk) {
        // TODO: pick a bounded rollout percentage that keeps a meaningful sample
        return 0;
    }
}
'), 10, 256, true),
    ('mid-flag-evaluation', 'Evaluate a Feature Flag', 'Evaluate a Feature Flag - practise the Cloud and Delivery section with a runnable exercise.', 'Mid', 'Mid', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static boolean enabled(String userId, int rolloutPercent, boolean killSwitch, Set<String> allowedUsers) {
        // TODO: kill switch first, then the allowlist, then the stable hash bucket
        return false;
    }
}
'), 10, 256, true),
    ('mid-autoscale-signal', 'Choose an Autoscaling Signal', 'Choose an Autoscaling Signal - practise the Cloud and Delivery section with a runnable exercise.', 'Mid', 'Mid', 'Cloud and Delivery', jsonb_build_object('Main.java', E'public class Main {
    public static String signal(boolean queueBacklog, boolean cpuBound, boolean latencySensitive) {
        // TODO: choose the documented autoscaling signal
        return "CONCURRENCY";
    }
}
'), 10, 256, true),
    ('senior-database-compatibility', 'Check Blue-Green Database Compatibility', 'Check Blue-Green Database Compatibility - practise the Cloud and Delivery section with a runnable exercise.', 'Senior', 'Senior', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> blockers(List<String> migrations) {
        // TODO: flag destructive or non-additive statements
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-cost-triage', 'Triage Cloud Cost', 'Triage Cloud Cost - practise the Cloud and Delivery section with a runnable exercise.', 'Senior', 'Senior', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> actions(Map<String, Double> spendByArea) {
        // TODO: order cost actions by largest recoverable spend
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-iac-drift', 'Detect Infrastructure Drift', 'Detect Infrastructure Drift - practise the Cloud and Delivery section with a runnable exercise.', 'Senior', 'Senior', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> drift(Map<String, String> desired, Map<String, String> actual) {
        // TODO: report added, removed and changed attributes
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-delivery-standard', 'Set a Delivery Standard', 'Set a Delivery Standard - practise the Cloud and Delivery section with a runnable exercise.', 'Lead', 'Lead', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> standards(boolean regulated, int servicesOwned) {
        // TODO: order the delivery practices for this context
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-secret-rotation', 'Plan a Secret Rotation', 'Plan a Secret Rotation - practise the Cloud and Delivery section with a runnable exercise.', 'Lead', 'Lead', 'Cloud and Delivery', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> rotationOrder(int consumers, boolean dualWriteSupported) {
        // TODO: return the zero-downtime rotation sequence
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-password-strength', 'Score Password Strength', 'Score Password Strength - practise the Security section with a runnable exercise.', 'Junior', 'Junior', 'Security', jsonb_build_object('Main.java', E'public class Main {
    public static String strength(String password) {
        // TODO: score the password as WEAK, FAIR, GOOD or STRONG using the documented rules
        return "WEAK";
    }
}
'), 10, 256, true),
    ('junior-secret-detection', 'Detect a Committed Secret', 'Detect a Committed Secret - practise the Security section with a runnable exercise.', 'Junior', 'Junior', 'Security', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> findings(List<String> lines) {
        // TODO: flag assignments to password, token, apiKey or secret with their 1-based line numbers
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('junior-header-hardening', 'Add Security Response Headers', 'Add Security Response Headers - practise the Security section with a runnable exercise.', 'Junior', 'Junior', 'Security', jsonb_build_object('Main.java', E'import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> headers(boolean httpsOnly) {
        Map<String, String> headers = new LinkedHashMap<>();
        // TODO: add the documented hardening headers; Strict-Transport-Security only when httpsOnly
        headers.put("Strict-Transport-Security", "max-age=31536000");
        return headers;
    }
}
'), 10, 256, true),
    ('junior-input-sanitise', 'Sanitise Untrusted Input', 'Sanitise Untrusted Input - practise the Security section with a runnable exercise.', 'Junior', 'Junior', 'Security', jsonb_build_object('Main.java', E'public class Main {
    public static String normalise(String input) {
        // TODO: trim, collapse runs of whitespace and control characters, and return an empty string for null
        return input == null ? "" : input.trim();
    }
}
'), 10, 256, true),
    ('mid-parameterised-query', 'Parameterise a Query Safely', 'Parameterise a Query Safely - practise the Security section with a runnable exercise.', 'Mid', 'Mid', 'Security', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> violations(String sql) {
        // TODO: flag string concatenation, unsafe ORDER BY interpolation and comment injection markers
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-output-encoding', 'Encode Output for HTML', 'Encode Output for HTML - practise the Security section with a runnable exercise.', 'Mid', 'Mid', 'Security', jsonb_build_object('Main.java', E'public class Main {
    public static String encode(String value) {
        // TODO: escape &, <, >, double quote and single quote; null yields an empty string
        return value == null ? "" : value;
    }
}
'), 10, 256, true),
    ('mid-csrf-token-check', 'Verify a CSRF Token', 'Verify a CSRF Token - practise the Security section with a runnable exercise.', 'Mid', 'Mid', 'Security', jsonb_build_object('Main.java', E'public class Main {
    public static boolean valid(String sessionToken, String requestToken, String method) {
        // TODO: safe methods pass; every other method needs an equal, non-blank token pair
        return true;
    }
}
'), 10, 256, true),
    ('mid-jwt-validation', 'Validate a JSON Web Token', 'Validate a JSON Web Token - practise the Security section with a runnable exercise.', 'Mid', 'Mid', 'Security', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> header, Map<String, Object> claims, long nowEpochSeconds) {
        // TODO: flag alg none, missing or expired exp, and a missing subject
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-scope-check', 'Check API Scopes', 'Check API Scopes - practise the Security section with a runnable exercise.', 'Mid', 'Mid', 'Security', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Set;

public class Main {
    public static boolean permits(Set<String> granted, List<String> required, boolean requireAll) {
        // TODO: demand every scope when requireAll is true, otherwise any single scope
        return false;
    }
}
'), 10, 256, true),
    ('senior-crypto-choice', 'Choose a Cryptographic Primitive', 'Choose a Cryptographic Primitive - practise the Security section with a runnable exercise.', 'Senior', 'Senior', 'Security', jsonb_build_object('Main.java', E'public class Main {
    public static String primitive(String purpose) {
        // TODO: map the documented purpose to hashing, symmetric encryption, MAC or key exchange
        return "";
    }
}
'), 10, 256, true),
    ('senior-key-rotation', 'Rotate an Encryption Key', 'Rotate an Encryption Key - practise the Security section with a runnable exercise.', 'Senior', 'Senior', 'Security', jsonb_build_object('Main.java', E'public class Main {
    public static String selectKey(int keyVersion, int activeVersion, int retainVersions) {
        // TODO: the active key encrypts and decrypts, retained older keys decrypt only, older keys are refused
        return "decrypt only";
    }
}
'), 10, 256, true),
    ('senior-audit-events', 'Design Audit Events', 'Design Audit Events - practise the Security section with a runnable exercise.', 'Senior', 'Senior', 'Security', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> entry) {
        // TODO: require actor, action, target and timestamp, and reject secret material
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('senior-sbom-gate', 'Gate a Build on Vulnerability Findings', 'Gate a Build on Vulnerability Findings - practise the Security section with a runnable exercise.', 'Senior', 'Senior', 'Security', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static String gate(List<Map<String, Object>> findings, int severityThreshold) {
        // TODO: FAIL on reachable findings at or above the threshold, WARN on other findings, PASS when clean
        return "WARN";
    }
}
'), 10, 256, true),
    ('principal-threat-model', 'Produce a Threat Model', 'Produce a Threat Model - practise the Security section with a runnable exercise.', 'Principal', 'Principal', 'Security', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> mitigations(List<String> threats) {
        // TODO: map each STRIDE category to its documented control, ordered by risk
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('principal-security-policy', 'Set an Organisation Security Policy', 'Set an Organisation Security Policy - practise the Security section with a runnable exercise.', 'Principal', 'Principal', 'Security', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> controls(boolean regulatedData, boolean publicApi, int teamCount) {
        // TODO: add the documented conditional controls for regulated data, public APIs and team size
        return List.of(
                "assign a security owner for every system",
                "require two-person review for production changes",
                "keep an incident response runbook up to date");
    }
}
'), 10, 256, true),
    ('junior-json-field-read', 'Read a Nested JSON Field', 'Read a Nested JSON Field - practise the Data Formats section with a runnable exercise.', 'Junior', 'Junior', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.Optional;

public class Main {
    public static Optional<String> field(String json, String path) {
        // TODO: resolve the dot-separated path and return the string value it points at
        return Optional.empty();
    }
}
'), 10, 256, true),
    ('junior-csv-row-parse', 'Parse a CSV Row', 'Parse a CSV Row - practise the Data Formats section with a runnable exercise.', 'Junior', 'Junior', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> fields(String row) {
        // TODO: split the row into fields, honouring quoted fields and escaped quotes
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-yaml-flatten', 'Flatten YAML Configuration', 'Flatten YAML Configuration - practise the Data Formats section with a runnable exercise.', 'Junior', 'Junior', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, String> flatten(Map<String, Object> yaml) {
        // TODO: flatten nested maps into dot-separated keys and stringify scalar values
        return Map.of();
    }
}
'), 10, 256, true),
    ('mid-polymorphic-write', 'Serialise a Polymorphic Type', 'Serialise a Polymorphic Type - practise the Data Formats section with a runnable exercise.', 'Mid', 'Mid', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Object> envelope(String type, Map<String, Object> body) {
        // TODO: return a new map that starts with the type discriminator and keeps every body entry
        return body;
    }
}
'), 10, 256, true),
    ('mid-format-compatibility', 'Check Format Compatibility', 'Check Format Compatibility - practise the Data Formats section with a runnable exercise.', 'Mid', 'Mid', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.Set;

public class Main {
    public static String compatibility(Set<String> before, Set<String> after, Set<String> required) {
        // TODO: classify the schema change as BACKWARD, FORWARD, FULL or BREAKING
        return "BREAKING";
    }
}
'), 10, 256, true),
    ('mid-number-precision', 'Preserve Numeric Precision', 'Preserve Numeric Precision - practise the Data Formats section with a runnable exercise.', 'Mid', 'Mid', 'Data Formats', jsonb_build_object('Main.java', E'import java.math.BigDecimal;

public class Main {
    public static String render(BigDecimal value) {
        // TODO: render the decimal without an exponent and without losing its scale
        return value == null ? "" : value.toString();
    }
}
'), 10, 256, true),
    ('mid-datetime-format', 'Format an Instant as ISO-8601', 'Format an Instant as ISO-8601 - practise the Data Formats section with a runnable exercise.', 'Mid', 'Mid', 'Data Formats', jsonb_build_object('Main.java', E'import java.time.Instant;

public class Main {
    public static String format(Instant instant) {
        // TODO: format in UTC with ISO-8601 seconds precision
        return instant == null ? "" : instant.toString();
    }
}
'), 10, 256, true),
    ('senior-deserialisation-safety', 'Harden Deserialisation', 'Harden Deserialisation - practise the Data Formats section with a runnable exercise.', 'Senior', 'Senior', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Set;

public class Main {
    public static List<String> violations(String className, Set<String> allowedPackages) {
        // TODO: report native serialisation, known gadgets and classes outside the allowlist
        return List.of();
    }
}
'), 10, 256, true),
    ('senior-streaming-parse', 'Parse a Large Document Incrementally', 'Parse a Large Document Incrementally - practise the Data Formats section with a runnable exercise.', 'Senior', 'Senior', 'Data Formats', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> parseChunks(List<String> chunks, int maxChunkBytes) {
        // TODO: reassemble newline separated records that may be split across chunks
        return List.of();
    }
}
'), 10, 256, true),
    ('junior-reverse-array', 'Reverse an Array In Place', 'Reverse an Array In Place - practise the Algorithms and Data Structures section with a runnable exercise.', 'Junior', 'Junior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'public class Main {
    public static void reverse(int[] values) {
        // TODO: reverse the array in place; leave null, empty and single-element arrays untouched
    }
}
'), 10, 256, true),
    ('junior-find-maximum', 'Find the Maximum Value', 'Find the Maximum Value - practise the Algorithms and Data Structures section with a runnable exercise.', 'Junior', 'Junior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.OptionalInt;

public class Main {
    public static OptionalInt maximum(int[] values) {
        // TODO: return the largest value, or OptionalInt.empty() for null and empty input
        return OptionalInt.empty();
    }
}
'), 10, 256, true),
    ('junior-count-occurrences', 'Count Occurrences of a Value', 'Count Occurrences of a Value - practise the Algorithms and Data Structures section with a runnable exercise.', 'Junior', 'Junior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static int occurrences(List<String> values, String target) {
        // TODO: count how many times target appears; skip null entries and return 0 for a null target
        return 0;
    }
}
'), 10, 256, true),
    ('junior-remove-duplicates', 'Remove Duplicates from a Sorted Array', 'Remove Duplicates from a Sorted Array - practise the Algorithms and Data Structures section with a runnable exercise.', 'Junior', 'Junior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'public class Main {
    public static int uniqueCount(int[] values) {
        // TODO: compact distinct values to the front of the array and return how many there are
        return 0;
    }
}
'), 10, 256, true),
    ('junior-sort-by-key', 'Sort Records by a Key', 'Sort Records by a Key - practise the Algorithms and Data Structures section with a runnable exercise.', 'Junior', 'Junior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> byLength(List<String> values) {
        // TODO: return a new list sorted by length ascending, keeping the original order for equal lengths, with nulls last
        return new java.util.ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-two-sum', 'Find Two Numbers that Sum to a Target', 'Find Two Numbers that Sum to a Target - practise the Algorithms and Data Structures section with a runnable exercise.', 'Mid', 'Mid', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'public class Main {
    public static int[] twoSum(int[] values, int target) {
        // TODO: return the first pair of indices whose values add up to target, or an empty array
        return new int[0];
    }
}
'), 10, 256, true),
    ('mid-sliding-window', 'Maximum Sum of a Fixed Window', 'Maximum Sum of a Fixed Window - practise the Algorithms and Data Structures section with a runnable exercise.', 'Mid', 'Mid', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'public class Main {
    public static int maxWindowSum(int[] values, int window) {
        // TODO: return the largest sum of any window of the given size, or 0 for an invalid window
        return 0;
    }
}
'), 10, 256, true),
    ('mid-lru-cache', 'Implement an LRU Cache', 'Implement an LRU Cache - practise the Algorithms and Data Structures section with a runnable exercise.', 'Mid', 'Mid', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static final class LruCache<K, V> {
        private final int capacity;

        public LruCache(int capacity) {
            this.capacity = capacity;
        }

        public V get(K key) {
            // TODO: return the value, marking the entry as most recently used
            return null;
        }

        public void put(K key, V value) {
            // TODO: insert or update, evicting the least recently used entry when full
        }

        public int size() {
            // TODO: report how many entries are cached
            return 0;
        }
    }
}
'), 10, 256, true),
    ('mid-top-k-frequent', 'Find the Top K Frequent Words', 'Find the Top K Frequent Words - practise the Algorithms and Data Structures section with a runnable exercise.', 'Mid', 'Mid', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> topK(List<String> words, int k) {
        // TODO: return the k most frequent words, most frequent first, ties broken alphabetically
        return java.util.List.of();
    }
}
'), 10, 256, true),
    ('mid-graph-bfs', 'Traverse a Graph Breadth First', 'Traverse a Graph Breadth First - practise the Algorithms and Data Structures section with a runnable exercise.', 'Mid', 'Mid', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> bfs(Map<String, List<String>> graph, String start) {
        // TODO: return the breadth-first visit order from start, using sorted neighbours and tolerating cycles
        return java.util.List.of();
    }
}
'), 10, 256, true),
    ('mid-merge-intervals', 'Merge Overlapping Intervals', 'Merge Overlapping Intervals - practise the Algorithms and Data Structures section with a runnable exercise.', 'Mid', 'Mid', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<int[]> merge(List<int[]> intervals) {
        // TODO: sort and merge overlapping or touching intervals, returning a new list
        return java.util.List.of();
    }
}
'), 10, 256, true),
    ('senior-dijkstra', 'Compute Shortest Paths', 'Compute Shortest Paths - practise the Algorithms and Data Structures section with a runnable exercise.', 'Senior', 'Senior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Integer> shortestPaths(Map<String, Map<String, Integer>> graph, String source) {
        // TODO: compute the shortest distance from source to every reachable node
        return java.util.Map.of();
    }
}
'), 10, 256, true),
    ('senior-knapsack', 'Solve the 0/1 Knapsack Problem', 'Solve the 0/1 Knapsack Problem - practise the Algorithms and Data Structures section with a runnable exercise.', 'Senior', 'Senior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'public class Main {
    public static int maxValue(int[] weights, int[] values, int capacity) {
        // TODO: return the best total value for the capacity, or 0 for invalid input
        return 0;
    }
}
'), 10, 256, true),
    ('senior-lru-threadsafe', 'Make an LRU Cache Thread-Safe', 'Make an LRU Cache Thread-Safe - practise the Algorithms and Data Structures section with a runnable exercise.', 'Senior', 'Senior', 'Algorithms and Data Structures', jsonb_build_object('Main.java', E'public class Main {
    public static final class ConcurrentLruCache<K, V> {
        private final int capacity;

        public ConcurrentLruCache(int capacity) {
            this.capacity = capacity;
        }

        public V get(K key) {
            // TODO: return the value, marking the entry as most recently used
            return null;
        }

        public void put(K key, V value) {
            // TODO: insert or update, evicting the least recently used entry when full
        }

        public int size() {
            // TODO: report how many entries are cached
            return 0;
        }
    }
}
'), 10, 256, true),
    ('junior-guard-clause', 'Flatten Nested Conditionals', 'Flatten Nested Conditionals - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Junior', 'Junior', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static int nestingDepth(List<String> lines) {
        // TODO: report the maximum nesting depth of if statements across all lines
        return 0;
    }
}
'), 10, 256, true),
    ('junior-method-extraction', 'Detect a Method Worth Extracting', 'Detect a Method Worth Extracting - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Junior', 'Junior', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'public class Main {
    public static boolean shouldExtract(int lines, int distinctResponsibilityCount, int usedVariables) {
        // TODO: apply the documented heuristic for extracting a method
        return false;
    }
}
'), 10, 256, true),
    ('mid-duplication-detect', 'Detect True Duplication', 'Detect True Duplication - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Mid', 'Mid', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> duplicatedBlocks(List<String> lines, int minimumLines) {
        // TODO: report normalised blocks of at least minimumLines that appear more than once,
        // sorted, for example "3-5"
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-strategy-extraction', 'Replace a Conditional with Polymorphism', 'Replace a Conditional with Polymorphism - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Mid', 'Mid', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, String> extract(Map<String, String> switchCases) {
        // TODO: name one handler method per case key, matching the domain language
        return switchCases == null ? Map.of() : new java.util.LinkedHashMap<>(switchCases);
    }
}
'), 10, 256, true),
    ('mid-test-seam', 'Introduce a Test Seam', 'Introduce a Test Seam - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Mid', 'Mid', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> seams(List<String> lines) {
        // TODO: flag static calls, direct constructors and clock reads that block testing
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-legacy-risk', 'Rank Legacy Change Risk', 'Rank Legacy Change Risk - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Mid', 'Mid', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'public class Main {
    public static String risk(int complexity, int testCoveragePercent, boolean hasRecentIncidents) {
        // TODO: classify change risk from complexity, coverage and incident history
        return "MEDIUM";
    }
}
'), 10, 256, true),
    ('senior-characterisation', 'Capture Characterisation Tests', 'Capture Characterisation Tests - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Senior', 'Senior', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> cases(List<String> inputs) {
        // TODO: add boundary and legacy-quirk cases that pin the current behaviour
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('senior-module-extraction', 'Extract a Module Boundary', 'Extract a Module Boundary - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Senior', 'Senior', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.*;

public class Main {
    public static List<String> extractionOrder(Map<String, Set<String>> moduleDeps) {
        // TODO: return leaf-first module order, or an empty list when a cycle exists
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('senior-dead-code', 'Find Dead Code', 'Find Dead Code - practise the Refactoring and Legacy Code section with a runnable exercise.', 'Senior', 'Senior', 'Refactoring and Legacy Code', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Main {
    public static List<String> unreachable(Set<String> declared, Set<String> referenced, Set<String> entryPoints) {
        // TODO: report unreferenced symbols, excluding entry points, sorted
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('junior-review-checklist', 'Apply a Code Review Checklist', 'Apply a Code Review Checklist - practise the Engineering Practice section with a runnable exercise.', 'Junior', 'Junior', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> checks(int changedLines, boolean hasTests, boolean touchesConfig) {
        // TODO: return the documented review focus areas for the change
        return List.of("readability and naming");
    }
}
'), 10, 256, true),
    ('junior-question-quality', 'Improve a Technical Question', 'Improve a Technical Question - practise the Engineering Practice section with a runnable exercise.', 'Junior', 'Junior', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> missingParts(String question) {
        // TODO: report which parts of a good technical question are absent
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('mid-estimate-range', 'Produce an Estimate Range', 'Produce an Estimate Range - practise the Engineering Practice section with a runnable exercise.', 'Mid', 'Mid', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.Map;

public class Main {
    public static Map<String, Integer> estimate(int optimisticDays, double uncertaintyFactor) {
        // TODO: best, likely and worst case with the documented bounds
        return Map.of("best", optimisticDays, "likely", optimisticDays, "worst", optimisticDays);
    }
}
'), 10, 256, true),
    ('mid-incident-timeline', 'Build an Incident Timeline', 'Build an Incident Timeline - practise the Engineering Practice section with a runnable exercise.', 'Mid', 'Mid', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> timeline(List<String> events) {
        // TODO: sort chronologically, breaking ties detection then mitigation then resolution
        return new ArrayList<>(events == null ? List.of() : events);
    }
}
'), 10, 256, true),
    ('mid-onboarding-path', 'Design an Onboarding Path', 'Design an Onboarding Path - practise the Engineering Practice section with a runnable exercise.', 'Mid', 'Mid', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> firstWeek(boolean javaBackground, boolean hasProductionAccess) {
        // TODO: build the ordered first-week plan, adding the documented conditional steps
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('lead-growth-plan', 'Build a Growth Plan', 'Build a Growth Plan - practise the Engineering Practice section with a runnable exercise.', 'Lead', 'Lead', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> actions(String currentLevel, String targetLevel) {
        // TODO: return the documented competency actions for the promotion step
        return List.of();
    }
}
'), 10, 256, true),
    ('lead-metrics-choice', 'Choose Delivery Metrics', 'Choose Delivery Metrics - practise the Engineering Practice section with a runnable exercise.', 'Lead', 'Lead', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> metrics(boolean deliveryFocused, boolean reliabilityFocused) {
        // TODO: choose the documented metric set, never vanity metrics
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('lead-stakeholder-brief', 'Write a Stakeholder Brief', 'Write a Stakeholder Brief - practise the Engineering Practice section with a runnable exercise.', 'Lead', 'Lead', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.List;

public class Main {
    public static List<String> outline(String decision) {
        // TODO: build the impact-first outline, echoing the decision in the opening line
        return List.of("summary", "recommendation");
    }
}
'), 10, 256, true),
    ('principal-tech-strategy', 'Draft a Technical Strategy', 'Draft a Technical Strategy - practise the Engineering Practice section with a runnable exercise.', 'Principal', 'Principal', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> sections(int horizonYears) {
        // TODO: return the strategy sections in order, inserting the horizon section
        return new ArrayList<>();
    }
}
'), 10, 256, true),
    ('principal-org-design', 'Design a Team Topology', 'Design a Team Topology - practise the Engineering Practice section with a runnable exercise.', 'Principal', 'Principal', 'Engineering Practice', jsonb_build_object('Main.java', E'import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> review(boolean clearOwnership, int servicesPerTeam, boolean platformTeamExists) {
        // TODO: report findings and recommendations for the team topology
        return new ArrayList<>();
    }
}
'), 10, 256, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO challenge_requirement (challenge_id, description, sort_order)
SELECT c.id, r.description, r.sort_order
FROM (VALUES
    ('junior-vowel-counter', 1, 'Count both lowercase and uppercase vowels (a, e, i, o, u).'),
    ('junior-vowel-counter', 2, 'Other letters, digits and punctuation are not vowels.'),
    ('junior-vowel-counter', 3, 'Return zero for null or blank input.'),
    ('junior-palindrome-phrase', 1, 'Compare only letters and digits, ignoring case, spaces and punctuation.'),
    ('junior-palindrome-phrase', 2, 'Return true when the cleaned text reads the same forwards and backwards.'),
    ('junior-palindrome-phrase', 3, 'Return false for null or blank input.'),
    ('junior-palindrome-phrase', 4, 'A single letter or digit is a palindrome.'),
    ('junior-title-case', 1, 'Return an empty string for null or blank input.'),
    ('junior-title-case', 2, 'Remove leading and trailing whitespace and collapse every whitespace run to a single space.'),
    ('junior-title-case', 3, 'Start each word with an uppercase letter and lowercase its remaining letters.'),
    ('junior-title-case', 4, 'Digits and punctuation stay attached to their word and never start a new one.'),
    ('junior-number-grouping', 1, 'Insert a comma between every group of three digits, counting from the right.'),
    ('junior-number-grouping', 2, 'Values with fewer than four digits are returned unchanged.'),
    ('junior-number-grouping', 3, 'Negative values keep their leading minus sign.'),
    ('junior-number-grouping', 4, 'Long.MIN_VALUE and Long.MAX_VALUE are formatted exactly, without overflow.'),
    ('junior-dedupe-preserving-order', 1, 'Return the first occurrence of each value in its original position and drop every later duplicate.'),
    ('junior-dedupe-preserving-order', 2, 'Skip null entries entirely instead of storing them.'),
    ('junior-dedupe-preserving-order', 3, 'A null input list returns an empty list, never null.'),
    ('junior-dedupe-preserving-order', 4, 'Comparison is case sensitive and blank strings are ordinary values.'),
    ('junior-map-merge-sum', 1, 'Merge both maps into one result whose value is the sum of the matching entries.'),
    ('junior-map-merge-sum', 2, 'Keys that appear in only one map are kept with their existing value.'),
    ('junior-map-merge-sum', 3, 'A null map is treated as an empty map and the result is never null.'),
    ('junior-map-merge-sum', 4, 'Neither input map may be modified.'),
    ('junior-null-safe-join', 1, 'Trim every non-null part before joining and skip parts that are null or blank.'),
    ('junior-null-safe-join', 2, 'Join the remaining parts with the separator exactly as given, including an empty separator.'),
    ('junior-null-safe-join', 3, 'Return an empty string for a null list or when no part survives the filter.'),
    ('junior-null-safe-join', 4, 'Never return null.'),
    ('junior-enum-from-text', 1, 'Match the enum constant name without regard to case and ignore surrounding whitespace.'),
    ('junior-enum-from-text', 2, 'Unknown, null or blank text returns Priority.NORMAL instead of throwing.'),
    ('junior-enum-from-text', 3, 'Valid names are LOW, NORMAL and HIGH.'),
    ('mid-generic-max', 1, 'Return the largest value using the natural comparison of T.'),
    ('mid-generic-max', 2, 'Ignore null entries and return an empty Optional for an empty, null or all-null list.'),
    ('mid-generic-max', 3, 'An empty Optional is also the result when no value can be compared.'),
    ('mid-stream-group-count', 1, 'Group words by their first character converted to lowercase and count how many words share it.'),
    ('mid-stream-group-count', 2, 'Skip null and blank words, and never return null.'),
    ('mid-stream-group-count', 3, 'An empty or null list returns an empty map.'),
    ('mid-stream-group-count', 4, 'Digits and symbols are valid group keys.'),
    ('mid-record-validation', 1, 'A Range is valid only when low is less than or equal to high.'),
    ('mid-record-validation', 2, 'Both the canonical constructor and the static factory reject an invalid range with IllegalArgumentException.'),
    ('mid-record-validation', 3, 'contains is inclusive of both bounds.'),
    ('mid-record-validation', 4, 'A range whose bounds are equal is valid and contains exactly that value.'),
    ('mid-nested-optional-lookup', 1, 'Look up the tenant map first and then the user''s city inside it.'),
    ('mid-nested-optional-lookup', 2, 'Every missing step, including a null or blank city value, produces Optional.empty().'),
    ('mid-nested-optional-lookup', 3, 'No null input may throw: a null directory, tenant or user all give Optional.empty().'),
    ('mid-immutable-builder', 1, 'ServerConfig is immutable and only a Builder can create it.'),
    ('mid-immutable-builder', 2, 'Building without a host, or with a port that is zero or negative, throws IllegalStateException.'),
    ('mid-immutable-builder', 3, 'Builder.tag appends tags in order and build stores a defensive copy of them.'),
    ('mid-immutable-builder', 4, 'The tags returned by the config are an unmodifiable list that defaults to empty.'),
    ('mid-multikey-comparator', 1, 'Order text by increasing length and break equal lengths with natural ordering.'),
    ('mid-multikey-comparator', 2, 'Place null entries after every non-null entry, and treat two nulls as equal.'),
    ('mid-multikey-comparator', 3, 'The comparator must stay consistent so sorting the same list twice gives the same result.'),
    ('mid-sealed-outcome', 1, 'Outcome is a sealed interface whose only permitted implementations are the records Ok(String value) and Failed(String reason).'),
    ('mid-sealed-outcome', 2, 'describe returns "ok: " plus the value for Ok, and "failed: " plus the reason for Failed.'),
    ('mid-sealed-outcome', 3, 'A null or blank value or reason is rendered as (none), and a null outcome gives "unknown outcome".'),
    ('senior-stream-partition-stats', 1, 'Partition values with the key true for values greater than or equal to the threshold and false for the rest.'),
    ('senior-stream-partition-stats', 2, 'Return a summary statistics object for each group so callers can read count, sum, min, max and average.'),
    ('senior-stream-partition-stats', 3, 'Ignore null entries, and produce two empty groups for an empty or null list.'),
    ('senior-stream-partition-stats', 4, 'The result must always contain both keys.'),
    ('senior-generic-repository', 1, 'save stores an entity under its identifier and replaces any previous value for the same id.'),
    ('senior-generic-repository', 2, 'findById returns the stored entity in an Optional and never null.'),
    ('senior-generic-repository', 3, 'delete removes the entity and returns true only when something was actually removed.'),
    ('senior-generic-repository', 4, 'A repository never exposes entities saved to a different repository instance.'),
    ('senior-functional-pipeline', 1, 'Return a function that applies every step in the order they appear in the list.'),
    ('senior-functional-pipeline', 2, 'An empty list returns the identity function, and a single step is applied unchanged.'),
    ('senior-functional-pipeline', 3, 'The returned function is reusable and applies the same steps on every call.'),
    ('junior-cli-flag-parser', 1, 'Return an empty map for a null or empty argument array.'),
    ('junior-cli-flag-parser', 2, 'Parse each token of the form --key=value into a key/value entry, splitting on the first =.'),
    ('junior-cli-flag-parser', 3, 'Parse each token of the form --flag into an entry with the value "true".'),
    ('junior-cli-flag-parser', 4, 'Ignore tokens that do not start with --, the bare token --, and tokens with an empty key.'),
    ('junior-cli-flag-parser', 5, 'When the same key appears more than once, the last value wins.'),
    ('junior-exit-code-choice', 1, 'Return 0 when the operation succeeded, ignoring the retryable flag.'),
    ('junior-exit-code-choice', 2, 'Return 75 when the operation failed and the failure is retryable, following the EX_TEMPFAIL convention.'),
    ('junior-exit-code-choice', 3, 'Return 1 when the operation failed and the failure is permanent.'),
    ('junior-properties-parse', 1, 'Return an empty map for null or empty text.'),
    ('junior-properties-parse', 2, 'Skip lines that are blank or whose first non-blank character is #.'),
    ('junior-properties-parse', 3, 'Split every other line on its first = or :, whichever comes first, and trim the key and the value.'),
    ('junior-properties-parse', 4, 'Ignore lines without a separator and lines whose key is blank.'),
    ('junior-properties-parse', 5, 'When the same key appears more than once, the last value wins.'),
    ('junior-classpath-split', 1, 'Return an empty list for a null or empty path.'),
    ('junior-classpath-split', 2, 'Split on the semicolon when the windows flag is true, otherwise split on the colon.'),
    ('junior-classpath-split', 3, 'Drop empty entries, including entries created by leading, trailing or repeated separators.'),
    ('junior-classpath-split', 4, 'Preserve the order of the remaining entries and do not otherwise trim or modify them.'),
    ('mid-java-version-compare', 1, 'A null or blank version is treated as 0.0.0.'),
    ('mid-java-version-compare', 2, 'Split a version into major, minor and patch components on dots and underscores; missing components are 0 and non-numeric components are 0.'),
    ('mid-java-version-compare', 3, 'A leading 1. is a legacy prefix: 1.8.0_292 denotes 8.0.292 and is newer than 8.0.0.'),
    ('mid-java-version-compare', 4, 'Compare the major component first, then the minor, then the patch.'),
    ('mid-java-version-compare', 5, 'Return a negative number when the left version is older, zero when both are equal, and a positive number when the left version is newer.'),
    ('mid-lts-classification', 1, 'Return true for 8 and 11, the LTS releases before the two-year cadence.'),
    ('mid-lts-classification', 2, 'From 17 onwards an LTS release appears every four feature versions, so 17, 21, 25 and 29 are LTS.'),
    ('mid-lts-classification', 3, 'Return false for every other version, including 9, 10, 12, 18, 22 and 23.'),
    ('mid-module-requires', 1, 'Return a list that always contains java.base first, whatever the input.'),
    ('mid-module-requires', 2, 'Map java.sql and javax.sql to java.sql, java.awt and javax.swing to java.desktop, java.util.logging to java.logging, javax.xml and org.w3c.dom to java.xml, java.lang.management and javax.management to java.management, java.net.http to java.net.http, and everything else to java.base.'),
    ('mid-module-requires', 3, 'Match a package against a known package when it equals it or starts with it followed by a dot.'),
    ('mid-module-requires', 4, 'After java.base, list every other required module once, in alphabetical order.'),
    ('mid-module-requires', 5, 'A null list, null elements or an empty list are allowed and still return java.base.'),
    ('mid-heap-from-percentage', 1, 'Return the number of bytes of the container that the percentage represents, truncating any fraction.'),
    ('mid-heap-from-percentage', 2, 'Clamp the percentage into the range 1 to 100, so 0 and negative values mean 1 percent and values above 100 mean the whole container.'),
    ('mid-heap-from-percentage', 3, 'A container size of zero or less returns 0 bytes.'),
    ('mid-heap-from-percentage', 4, 'Do not overflow for container sizes close to Long.MAX_VALUE.'),
    ('mid-gc-pause-summary', 1, 'Format the result as "count=<n>, total=<sum>, worst=<max>" where <n> is the number of pauses, <sum> their total and <max> the worst pause.'),
    ('mid-gc-pause-summary', 2, 'A null or empty list reports "count=0, total=0, worst=0".'),
    ('mid-gc-pause-summary', 3, 'Sum the totals in a long so large lists do not overflow.'),
    ('mid-gc-pause-summary', 4, 'Null elements inside the list are treated as a pause of 0 milliseconds.'),
    ('mid-allocation-budget', 1, 'Return true when the allocated bytes are less than or equal to the budget plus the tolerance fraction of the budget, so a tolerance of 0.1 permits 10 percent overshoot.'),
    ('mid-allocation-budget', 2, 'Treat a tolerance of 1.0 as allowing up to double the budget.'),
    ('mid-allocation-budget', 3, 'Reject any negative allocated bytes, budget or tolerance by returning false.'),
    ('mid-allocation-budget', 4, 'A zero budget accepts only an allocation of zero when the tolerance is zero.'),
    ('senior-collector-choice', 1, 'A heap of zero or less returns "Serial".'),
    ('senior-collector-choice', 2, 'For a heap of at least 16 GB return "ZGC" when the p99 pause target is at most 100 ms, otherwise "G1".'),
    ('senior-collector-choice', 3, 'For a heap below 16 GB return "G1" when the p99 pause target is at most 200 ms, otherwise "Parallel".'),
    ('senior-collector-choice', 4, 'A throughput critical workload never uses "ZGC" and falls back to "G1" for large heaps with a tight pause target.'),
    ('senior-warmup-strategy', 1, 'Return 0 when the observed time is at least the target time, because the code is already warm.'),
    ('senior-warmup-strategy', 2, 'Otherwise estimate the remaining invocations as the missing time divided by the step, rounded up to a whole number of steps.'),
    ('senior-warmup-strategy', 3, 'Treat a step of zero or less as one invocation.'),
    ('senior-warmup-strategy', 4, 'Never return more than 1,000,000 invocations and never return a negative number.'),
    ('senior-oom-classification', 1, 'Map "Java heap space" to HEAP, "Metaspace" to METASPACE, "GC overhead limit exceeded" to GC_OVERHEAD, "Direct buffer memory" to DIRECT, and "Map failed" to MAP.'),
    ('senior-oom-classification', 2, 'Map "unable to create new native thread", "Cannot reserve" and "Out of swap space?" to NATIVE.'),
    ('senior-oom-classification', 3, 'Return UNKNOWN for a null, blank or unrecognised message.'),
    ('senior-oom-classification', 4, 'Matching is case insensitive and looks for the keyword inside the message.'),
    ('junior-safe-counter-logic', 1, 'nextValue(current, limit) returns current + 1 when that value does not exceed limit.'),
    ('junior-safe-counter-logic', 2, 'When current + 1 would exceed limit the method returns 0 instead.'),
    ('junior-safe-counter-logic', 3, 'A current value at or above limit returns 0.'),
    ('junior-safe-counter-logic', 4, 'A negative current or a negative limit throws IllegalArgumentException.'),
    ('junior-latch-count', 1, 'latchCount(workers, alreadyDone) returns how many workers must still complete: workers - alreadyDone.'),
    ('junior-latch-count', 2, 'An alreadyDone value below zero is treated as zero, so the result never exceeds workers.'),
    ('junior-latch-count', 3, 'When alreadyDone is at or above workers the result is zero, never negative.'),
    ('junior-latch-count', 4, 'A negative workers value throws IllegalArgumentException.'),
    ('junior-completed-future', 1, 'valueOr(future, fallback) returns the completed value when the future completed normally with a non-null value.'),
    ('junior-completed-future', 2, 'A null future, an incomplete future, or a future that completed exceptionally or was cancelled yields the fallback.'),
    ('junior-completed-future', 3, 'A completed value of null also yields the fallback.'),
    ('junior-completed-future', 4, 'The method must never block waiting for the future to complete.'),
    ('mid-pool-size-calculation', 1, 'poolSize = ceil(cores * targetUtilisation * (1 + waitTime / serviceTime)), clamped to at least 1 and at most 200.'),
    ('mid-pool-size-calculation', 2, 'targetUtilisation must be greater than 0 and at most 1; anything else throws IllegalArgumentException.'),
    ('mid-pool-size-calculation', 3, 'waitTime must not be negative, serviceTime must be positive, and cores must be at least 1; violations throw IllegalArgumentException.'),
    ('mid-cas-retry-loop', 1, 'casAttempts(initial, target, observed) models a CAS retry loop and returns how many attempts it takes to observe the target value.'),
    ('mid-cas-retry-loop', 2, 'When initial already equals target the loop makes zero attempts and never calls observed.'),
    ('mid-cas-retry-loop', 3, 'Each attempt calls observed with the previous observed value (or initial on the first attempt) and stops as soon as the returned value equals target.'),
    ('mid-cas-retry-loop', 4, 'An unreachable target stops after at most 1000 attempts and returns 1000.'),
    ('mid-cas-retry-loop', 5, 'A null observed operator throws IllegalArgumentException.'),
    ('mid-atomic-compute-if-absent', 1, 'computeOnce(cache, key, loader) returns the value already mapped to key, or loads and stores one when the key is absent.'),
    ('mid-atomic-compute-if-absent', 2, 'A single call to computeIfAbsent must perform the lookup and the store so the loader runs at most once per key.'),
    ('mid-atomic-compute-if-absent', 3, 'When the loader returns null nothing is cached and a later call loads again.'),
    ('mid-atomic-compute-if-absent', 4, 'A null cache, key, or loader throws IllegalArgumentException.'),
    ('mid-deadlock-cycle', 1, 'hasCycle(waitingFor) reports whether the wait-for graph contains a cycle.'),
    ('mid-deadlock-cycle', 2, 'Each key is a waiting thread and each value lists the threads it waits for; a thread waiting on itself is a cycle.'),
    ('mid-deadlock-cycle', 3, 'Targets that are not keys in the map are leaves and end the walk without a cycle.'),
    ('mid-deadlock-cycle', 4, 'A null map, an empty map, or an empty list for a key means no cycle; null entries inside a list are ignored.'),
    ('mid-semaphore-admission', 1, 'admit(permits, waiting, maxQueue) returns how many waiting callers can be admitted right now.'),
    ('mid-semaphore-admission', 2, 'A caller needs one permit, so no more than permits callers are admitted.'),
    ('mid-semaphore-admission', 3, 'No more than maxQueue callers are admitted, even when more permits and waiters are available.'),
    ('mid-semaphore-admission', 4, 'Negative permits, waiting, or maxQueue values throw IllegalArgumentException.'),
    ('mid-semaphore-admission', 5, 'The result is never negative.'),
    ('mid-backoff-schedule', 1, 'backoffMillis(attempts, base, cap) returns attempts delays where the first delay is base and every later delay doubles the previous one.'),
    ('mid-backoff-schedule', 2, 'Every delay is clamped to cap, including the first when cap is smaller than base.'),
    ('mid-backoff-schedule', 3, 'Doubling must saturate at cap instead of overflowing.'),
    ('mid-backoff-schedule', 4, 'attempts at or below zero returns an empty list.'),
    ('mid-backoff-schedule', 5, 'A base or cap that is not positive throws IllegalArgumentException.'),
    ('mid-graceful-shutdown-order', 1, 'shutdownOrder(resources) returns the shutdown phase names in the fixed order stop-accepting, drain, pools, connections.'),
    ('mid-graceful-shutdown-order', 2, 'Only the phases present in the input are returned, and duplicates collapse to a single entry.'),
    ('mid-graceful-shutdown-order', 3, 'Unknown resource names and null entries are ignored.'),
    ('mid-graceful-shutdown-order', 4, 'A null or empty input returns an empty list.'),
    ('mid-stamped-read-valid', 1, 'readValid(stampBefore, stampAfter, writeObserved) reports whether an optimistic read can be trusted.'),
    ('mid-stamped-read-valid', 2, 'The read is valid only when stampBefore equals stampAfter and writeObserved is false.'),
    ('mid-stamped-read-valid', 3, 'Any stamp difference or an observed write makes the read invalid.'),
    ('senior-virtual-or-platform', 1, 'chooseThreadType(ioBound, longCpuBound, usesThreadLocalHeavily, tasksPerSecond) returns "platform" or "virtual".'),
    ('senior-virtual-or-platform', 2, 'longCpuBound or usesThreadLocalHeavily always selects "platform".'),
    ('senior-virtual-or-platform', 3, 'Otherwise "virtual" is selected only when ioBound is true and tasksPerSecond is at least 1000.'),
    ('senior-virtual-or-platform', 4, 'Every other combination selects "platform".'),
    ('senior-deadline-budget', 1, 'remainingMillis(deadlineNanos, nowNanos, hops) converts the time left until the deadline into whole milliseconds.'),
    ('senior-deadline-budget', 2, 'Each hop consumes a reserve of 10 milliseconds, so the result is (deadlineNanos - nowNanos) / 1_000_000 minus 10 * hops.'),
    ('senior-deadline-budget', 3, 'A deadline equal to or earlier than now returns zero, and the result is never negative.'),
    ('senior-deadline-budget', 4, 'A deadline of Long.MAX_VALUE means no deadline is set and returns zero; negative hops count as zero.'),
    ('senior-bounded-queue-policy', 1, 'rejectionPolicy(latencyBudgetMillis, lossTolerant, queueDepth) returns "shed", "evict-oldest", or "block".'),
    ('senior-bounded-queue-policy', 2, 'Return "shed" when lossTolerant is true, or when the latency budget is under 200 milliseconds and the queue depth exceeds 200.'),
    ('senior-bounded-queue-policy', 3, 'Otherwise return "evict-oldest" when the queue depth exceeds 200.'),
    ('senior-bounded-queue-policy', 4, 'Otherwise return "block".'),
    ('senior-forkjoin-threshold', 1, 'threshold(elements, cores, perElementCostMicros) returns the chunk size for a divide-and-conquer task.'),
    ('senior-forkjoin-threshold', 2, 'The total work is elements * perElementCostMicros, and each chunk should hold about total work / (cores * 100) elements.'),
    ('senior-forkjoin-threshold', 3, 'The result is clamped to at least 1000 and at most 100000.'),
    ('senior-forkjoin-threshold', 4, 'Zero or negative elements, cores, or per-element cost fall back to the 1000 minimum.'),
    ('senior-threadlocal-leak', 1, 'suspiciousFields(fieldDeclarations) flags static ThreadLocal fields that may leak thread state.'),
    ('senior-threadlocal-leak', 2, 'A declaration is suspicious when it contains both "static" and "ThreadLocal".'),
    ('senior-threadlocal-leak', 3, 'A field is cleared when any declaration contains a remove call for that field''s name, such as NAME.remove().'),
    ('senior-threadlocal-leak', 4, 'Instance fields, non-ThreadLocal statics, null entries, and blank entries are ignored; flagged declarations are returned in input order.'),
    ('lead-concurrency-standard', 1, 'mandatoryControls(publicApi, sharedPool, hasTimeouts) returns the controls a team must adopt, in the fixed order timeouts, bounded-queues, bulkheads, rate-limiting.'),
    ('lead-concurrency-standard', 2, 'bounded-queues is always mandatory.'),
    ('lead-concurrency-standard', 3, 'timeouts is added when hasTimeouts is false, bulkheads when sharedPool is true, and rate-limiting when publicApi is true.'),
    ('lead-concurrency-standard', 4, 'Each control appears at most once.'),
    ('lead-virtual-thread-migration', 1, 'migrationSteps(usesSynchronizedBlocks, poolsBoundedAtDb, reliesOnThreadLocalCaches) returns an ordered migration plan for moving a service to virtual threads.'),
    ('lead-virtual-thread-migration', 2, 'The plan always starts with confirm-java21-runtime, always contains switch-to-virtual-executors, and always ends with load-test.'),
    ('lead-virtual-thread-migration', 3, 'remove-pinning is inserted when usesSynchronizedBlocks is true, bound-db-connections when poolsBoundedAtDb is false, and scope-threadlocals when reliesOnThreadLocalCaches is true.'),
    ('lead-virtual-thread-migration', 4, 'Conditional steps appear in the order remove-pinning, bound-db-connections, scope-threadlocals and no step is repeated.'),
    ('junior-gav-parse', 1, 'parse splits a Maven coordinate on colons into groupId, artifactId, and version in that order.'),
    ('junior-gav-parse', 2, 'A coordinate with fewer than three segments leaves the missing parts as empty strings.'),
    ('junior-gav-parse', 3, 'Every segment is trimmed and must contain at least one non-whitespace character.'),
    ('junior-gav-parse', 4, 'A coordinate with more than three segments is rejected with IllegalArgumentException.'),
    ('junior-gav-parse', 5, 'A null or blank coordinate is rejected with IllegalArgumentException.'),
    ('junior-scope-choice', 1, 'scopeFor maps the usage compile-only to compile, runtime-only to runtime, test-only to test, and provided-by-container to provided.'),
    ('junior-scope-choice', 2, 'The usage string is trimmed before matching and compared exactly and case-sensitively.'),
    ('junior-scope-choice', 3, 'Any other value, including an empty string, an unknown usage, or null, throws IllegalArgumentException.'),
    ('junior-version-compare', 1, 'compare returns a negative number, zero, or a positive number when left is lower, equal, or higher than right.'),
    ('junior-version-compare', 2, 'Versions are dot-separated numeric components, and a missing component counts as zero, so 1.2 equals 1.2.0.'),
    ('junior-version-compare', 3, 'A qualifier after the first hyphen is compared separately from the numeric components, and a qualifier never overrides a numeric difference.'),
    ('junior-version-compare', 4, 'When the numeric components are equal, a version with a qualifier sorts before the same version without one, so 1.0-beta is older than 1.0.'),
    ('junior-version-compare', 5, 'When both versions carry a qualifier, the qualifiers are compared lexically, so 1.0-alpha is older than 1.0-beta.'),
    ('junior-version-compare', 6, 'Null, blank, or non-numeric versions are rejected with IllegalArgumentException.'),
    ('junior-property-substitution', 1, 'substitute replaces every ${name} token whose name is a key of properties with the matching value.'),
    ('junior-property-substitution', 2, 'Token names are matched exactly and case-sensitively.'),
    ('junior-property-substitution', 3, 'A token whose name is unknown, empty, or unterminated is left untouched, including its braces.'),
    ('junior-property-substitution', 4, 'Substituted values are inserted literally and never rescanned for further tokens.'),
    ('junior-property-substitution', 5, 'A null template or null properties map is rejected with IllegalArgumentException.'),
    ('junior-plugin-goal-parse', 1, 'parseGoal splits groupId:artifactId:version:goal into its four segments in that order.'),
    ('junior-plugin-goal-parse', 2, 'When only groupId:artifactId:goal is given, the version segment defaults to RELEASE.'),
    ('junior-plugin-goal-parse', 3, 'Every segment is trimmed and must be non-empty.'),
    ('junior-plugin-goal-parse', 4, 'A goal with two or with more than four segments, a null or blank goal, and any empty segment are rejected with IllegalArgumentException.'),
    ('junior-module-direct-deps', 1, 'directDependencies returns the modules that the given module depends on directly, sorted naturally.'),
    ('junior-module-direct-deps', 2, 'Repeated entries appear once and null entries are ignored.'),
    ('junior-module-direct-deps', 3, 'An unknown module, a null module, a null graph, or a module without dependencies yields an empty list.'),
    ('mid-nearest-wins', 1, 'Each path is an arrow-separated chain of groupId:artifactId:version coordinates, and the candidate version is the version of the last coordinate.'),
    ('mid-nearest-wins', 2, 'The version from the path with the fewest coordinates wins, which is Maven''s nearest-wins rule.'),
    ('mid-nearest-wins', 3, 'When two paths have the same length, the one declared first wins.'),
    ('mid-nearest-wins', 4, 'An empty or null list yields an empty string.'),
    ('mid-nearest-wins', 5, 'A coordinate without exactly three non-empty colon-separated segments, or a blank path, is rejected with IllegalArgumentException.'),
    ('mid-exclusion-set', 1, 'excluded returns the effective exclusion set: the declared exclusions plus the inherited ones when inheritEnabled is true.'),
    ('mid-exclusion-set', 2, 'Inherited exclusions are ignored when inheritEnabled is false.'),
    ('mid-exclusion-set', 3, 'Null sets count as empty, and null entries are ignored.'),
    ('mid-exclusion-set', 4, 'Exclusion strings are exact literals, so wildcard characters such as * are kept as written.'),
    ('mid-exclusion-set', 5, 'The returned set is sorted in natural order.'),
    ('mid-bom-alignment', 1, 'misaligned compares the declared versions with the versions managed by the BOM.'),
    ('mid-bom-alignment', 2, 'An artifact is reported when the BOM manages it and the two version strings differ exactly, including whitespace.'),
    ('mid-bom-alignment', 3, 'Artifacts that the BOM does not manage are never reported.'),
    ('mid-bom-alignment', 4, 'The result is sorted in natural order, and null maps count as empty and report nothing.'),
    ('mid-profile-activation', 1, 'Each entry of requiredProperties is a profile descriptor "name" or "name:prop1,prop2", where the properties are the ones the profile requires.'),
    ('mid-profile-activation', 2, 'A profile activates when every required property it names is present in present, and the OS condition is satisfied.'),
    ('mid-profile-activation', 3, 'A property requirement prefixed with ! is satisfied when that property is absent instead.'),
    ('mid-profile-activation', 4, 'The OS condition is satisfied when requiredOs is null or blank, which matches any OS, or when requiredOs equals currentOs ignoring case.'),
    ('mid-profile-activation', 5, 'Return the names of the active profiles sorted alphabetically; a null list, blank entries and descriptors without a usable name contribute nothing.'),
    ('mid-lifecycle-order', 1, 'phasesUpTo returns the default Maven lifecycle phases from validate through the requested phase inclusive, in their documented order.'),
    ('mid-lifecycle-order', 2, 'The documented order is validate, initialize, generate-sources, process-sources, generate-resources, process-resources, compile, process-classes, generate-test-sources, process-test-sources, generate-test-resources, process-test-resources, test-compile, process-test-classes, test, prepare-package, package, pre-integration-test, integration-test, post-integration-test, verify, install, deploy.'),
    ('mid-lifecycle-order', 3, 'The requested phase is matched exactly, so an unknown, empty, null or differently cased name yields an empty list.'),
    ('mid-gradle-task-order', 1, 'executionOrder returns the tasks Gradle would run for the requested task, in dependency-first order.'),
    ('mid-gradle-task-order', 2, 'Dependencies are visited in the order they are listed, and each task appears once.'),
    ('mid-gradle-task-order', 3, 'A dependency without an entry in the map is treated as a leaf task that runs first, and a missing or empty dependency list means the task runs alone.'),
    ('mid-gradle-task-order', 4, 'Null tasks, null entries and null lists are ignored, so a null graph simply has no dependencies.'),
    ('mid-gradle-task-order', 5, 'When the graph containing the requested task has a cycle, the result is an empty list.'),
    ('mid-configuration-choice', 1, 'configurationFor maps a dependency usage to the Gradle configuration that should declare it.'),
    ('mid-configuration-choice', 2, 'Usage tokens are matched exactly and must be one of: api, internal, runtime, test.'),
    ('mid-configuration-choice', 3, 'An api usage returns api when the module publishes a library and implementation otherwise, since an unpublished module has no consumer that could compile against the leaked dependency.'),
    ('mid-configuration-choice', 4, 'An internal usage returns implementation, a runtime usage returns runtimeOnly and a test usage returns testImplementation, whatever the publishing flag says.'),
    ('mid-configuration-choice', 5, 'A null or unknown usage, including a configuration name or a differently cased token, is rejected with IllegalArgumentException.'),
    ('mid-catalog-alias', 1, 'toAccessor converts a Gradle version catalog alias into the typed accessor a build script uses.'),
    ('mid-catalog-alias', 2, 'The alias is trimmed, then every dash and underscore becomes a dot, and the result is prefixed with libs.'),
    ('mid-catalog-alias', 3, 'Existing dots are kept, so commons.io becomes libs.commons.io and spring-boot_starter-web becomes libs.spring.boot.starter.web.'),
    ('mid-catalog-alias', 4, 'A null or blank alias, an alias with an empty segment from a leading, trailing, doubled or mixed separator, or any upper-case letter is rejected with IllegalArgumentException.'),
    ('senior-build-cache-key', 1, 'cacheKey fingerprints a Gradle task so that identical inputs share a cache entry.'),
    ('senior-build-cache-key', 2, 'The SHA-256 payload is exactly three newline separated lines: the trimmed task name, the trimmed JDK version, then the task inputs.'),
    ('senior-build-cache-key', 3, 'Inputs are trimmed, blanks and nulls dropped, repeats counted once and the rest sorted naturally then joined with newlines, so the payload ends with a newline when there are no inputs.'),
    ('senior-build-cache-key', 4, 'The result is the 64 character lower-case hexadecimal digest, which ignores input order but changes with the task name, the input set or the JDK version.'),
    ('senior-build-cache-key', 5, 'Inputs may be null, but a null or blank task name or JDK version is rejected with IllegalArgumentException.'),
    ('senior-reproducible-timestamp', 1, 'sourceDateEpoch renders the reproducible build timestamp written into archive entries, always in ISO-8601 UTC.'),
    ('senior-reproducible-timestamp', 2, 'A null value returns the fixed reproducible fallback 1980-01-01T00:00:00Z, so a build that supplies nothing still gets a constant stamp.'),
    ('senior-reproducible-timestamp', 3, 'A supplied value renders as yyyy-MM-ddTHH:mm:ss followed by a literal Z in UTC, so the Unix epoch renders as 1970-01-01T00:00:00Z and 1700000000 as 2023-11-14T22:13:20Z.'),
    ('senior-reproducible-timestamp', 4, 'Valid timestamps are never clamped, and a value the formatter cannot represent is rejected with IllegalArgumentException.'),
    ('senior-toolchain-matrix', 1, 'selectToolchains binds each needed Java release to a vendor from the installed toolchains.'),
    ('senior-toolchain-matrix', 2, 'Each release maps to the lexicographically highest vendor installed for it, so temurin and zulu at release 17 select zulu.'),
    ('senior-toolchain-matrix', 3, 'Releases are reported in the requested order, a repeated release appears once, and an empty or null list of releases yields an empty map.'),
    ('senior-toolchain-matrix', 4, 'If any needed release has no installed vendor the whole selection is empty rather than partial, and a null installed map, a null release entry and an empty vendor list are all handled without failing.'),
    ('senior-configuration-cache-safe', 1, 'violations audits Gradle task lines the way the configuration cache does and reports every line that captures something the cache cannot store.'),
    ('senior-configuration-cache-safe', 2, 'A line is a violation when it references Project as a whole word, calls through the implicit project receiver, calls getProject(, or reads the process environment with System.getenv.'),
    ('senior-configuration-cache-safe', 3, 'Each offending line is reported trimmed and exactly as written, sorted naturally and de-duplicated.'),
    ('senior-configuration-cache-safe', 4, 'Blank and null entries are ignored, and supported alternatives such as providers.environmentVariable, projectDir, layout.buildDirectory or providers.gradleProperty are not violations.'),
    ('senior-enforcer-rules', 1, 'violations evaluates the enforcer rules and reports every breach, sorted naturally.'),
    ('senior-enforcer-rules', 2, 'The bannedDependencies rule holds a comma separated list of coordinates, and each one present in the comma separated dependencies value is reported as banned-dependency <coordinate>, trimmed, with blanks skipped and never reported twice.'),
    ('senior-enforcer-rules', 3, 'The requireJavaVersion rule reports wrong-java-version expected <required> but found <found> when the actual javaVersion differs, treating a build that reports none as unknown.'),
    ('senior-enforcer-rules', 4, 'A null or empty rules map yields an empty report, absent rules are not evaluated, and a null actual map is treated as a build that reports nothing.'),
    ('lead-build-standard', 1, 'requiredPractices returns the build practices an organisation standard requires, in the order they should be introduced.'),
    ('lead-build-standard', 2, 'Every build adopts reproducible-builds then locked-dependency-versions, a publisher additionally adopts published-metadata then signed-artifacts, and a regulated domain additionally adopts dependency-audit then build-provenance.'),
    ('lead-build-standard', 3, 'When both flags are set the regulated practices come before the publication ones, and no practice is ever repeated.'),
    ('lead-build-standard', 4, 'The returned list is unmodifiable and identical for identical inputs.'),
    ('lead-gradle-migration', 1, 'migrationOrder plans an incremental Maven to Gradle migration by ordering modules so each one is migrated after the modules it depends on.'),
    ('lead-gradle-migration', 2, 'The result is leaf-to-root: modules with no remaining Maven dependencies come first, then modules that only depend on already migrated ones, each appearing exactly once.'),
    ('lead-gradle-migration', 3, 'Independent modules are emitted in natural sorted order, a module mentioned only as a dependency is still migrated, and null entries and blank module names are ignored.'),
    ('lead-gradle-migration', 4, 'A null or empty graph yields an empty order, and a graph containing a cycle cannot be ordered, so the result is empty rather than a partial plan.'),
    ('junior-bean-scope', 1, 'Return "request" for a bean that holds state for the lifetime of a single web request.'),
    ('junior-bean-scope', 2, 'Return "prototype" when the bean holds mutable state that must not be shared between callers, even when creating it is expensive.'),
    ('junior-bean-scope', 3, 'Return "singleton" for stateless beans, including expensive ones whose creation cost should be paid once.'),
    ('junior-bean-scope', 4, 'Request scope outranks every other concern, because request state cannot live in a wider scope.'),
    ('junior-property-bind', 1, 'Read the port from the exact key "app.port" and fall back when the key is absent or its value is not a valid port.'),
    ('junior-property-bind', 2, 'Accept the relaxed environment variable name "APP_PORT" as well, and prefer the exact key "app.port" when both are present, even when the exact value is invalid.'),
    ('junior-property-bind', 3, 'A valid port is a trimmed integer between 1 and 65535 inclusive; blank, non-numeric or out of range values fall back.'),
    ('junior-property-bind', 4, 'Treat a null environment map as an empty environment.'),
    ('junior-status-mapping', 1, 'Map the outcome "created" to 201, "missing" to 404, "conflict" to 409, "invalid" to 422 and "unexpected" to 500.'),
    ('junior-status-mapping', 2, 'Trim the outcome and ignore case when matching.'),
    ('junior-status-mapping', 3, 'Return 500 for a null or unrecognized outcome, because an unknown failure must not be reported as success.'),
    ('mid-autoconfig-condition', 1, 'Return "CREATE" only when the required class is present, the enabling property is set and no bean of the same type already exists.'),
    ('mid-autoconfig-condition', 2, 'Return "BACK_OFF" when the required class is missing or the enabling property is disabled, whatever the other flags say.'),
    ('mid-autoconfig-condition', 3, 'Return "SKIP" when the class is present and the property is enabled but the application already defines the bean.'),
    ('mid-autoconfig-condition', 4, 'Evaluate the conditions in the documented order: class availability first, then the property, then the missing-bean condition.'),
    ('mid-profile-override-merge', 1, 'Start from the base properties and apply each override map from left to right, so a later profile wins.'),
    ('mid-profile-override-merge', 2, 'Preserve every base key that no profile overrides, and merge in keys that only a profile defines.'),
    ('mid-profile-override-merge', 3, 'Treat a null base as empty, and ignore null or empty override entries.'),
    ('mid-profile-override-merge', 4, 'Never modify the base map or the override maps; return a new map.'),
    ('mid-problem-detail-build', 1, 'Return a problem detail document with exactly the members "type", "title" and "status" holding the supplied values.'),
    ('mid-problem-detail-build', 2, 'Add the extension member "errors" only when at least one field has a non-empty list of messages; omit the member entirely otherwise.'),
    ('mid-problem-detail-build', 3, 'Each errors entry is a map with the keys "field" and "message", ordered by field name and then by message so the response is deterministic.'),
    ('mid-problem-detail-build', 4, 'Substitute "about:blank" for a null type and an empty string for a null title, and never return null.'),
    ('mid-problem-detail-build', 5, 'Do not modify the supplied field-error map or its lists.'),
    ('mid-validation-fields', 1, 'Return an empty map when the request is valid, and never return null values inside it.'),
    ('mid-validation-fields', 2, 'Report "must not be blank" under "reference" when the reference is null or blank.'),
    ('mid-validation-fields', 3, 'Report "must be between 1 and 100" under "quantity" when quantity falls outside 1..100 inclusive.'),
    ('mid-validation-fields', 4, 'Report "must be one of EUR, USD, CZK" under "currency" when the currency is null or is not one of those three values.'),
    ('mid-validation-fields', 5, 'Report every violated field instead of stopping at the first, with keys ordered reference, quantity, currency.'),
    ('mid-cache-key-compose', 1, 'Compose the key from prefix and tenant, then the arguments, joined by the ":" separator and always terminated by a trailing separator.'),
    ('mid-cache-key-compose', 2, 'Escape every ":" and "\" inside a part by prefixing it with a backslash, so a part can never be confused with several parts.'),
    ('mid-cache-key-compose', 3, 'Render a null argument as an empty part, and treat a null argument list as an empty list.'),
    ('mid-cache-key-compose', 4, 'Return a non-null key for every input, including null prefix or tenant and empty arguments.'),
    ('mid-transaction-boundary', 1, 'Mark a step as transactional only when it both reads and writes persistent state, because only such a read-modify-write unit must be atomic.'),
    ('mid-transaction-boundary', 2, 'A step reads persistent state when it contains "read", "load" or "select", and writes when it contains "write", "insert", "update" or "delete", ignoring case.'),
    ('mid-transaction-boundary', 3, 'Return the marked steps in their original order and unmodified; a step that only reads, only writes, or does neither is left out.'),
    ('mid-transaction-boundary', 4, 'Ignore blank and null steps, and return an empty list for a null step list instead of null.'),
    ('mid-retry-delay', 1, 'Return initial multiplied by multiplier raised to attempt-1, truncated to a whole number of milliseconds.'),
    ('mid-retry-delay', 2, 'Treat an attempt below 1 as the first attempt, so the returned delay is the initial delay.'),
    ('mid-retry-delay', 3, 'Cap the result at max, so the delay never exceeds it.'),
    ('mid-retry-delay', 4, 'Never overflow or return a negative value, no matter how large the attempt is.'),
    ('mid-health-aggregate', 1, 'Aggregate the indicator statuses into one overall status using the documented precedence DOWN, then OUT_OF_SERVICE, then UP, then UNKNOWN, where the first status present in that list wins.'),
    ('mid-health-aggregate', 2, 'Compare statuses ignoring case and surrounding whitespace, and ignore entries that are not one of the four documented statuses.'),
    ('mid-health-aggregate', 3, 'Return "UNKNOWN" when there is no indicator list, when it is empty, or when it contains no recognized status.'),
    ('mid-health-aggregate', 4, 'Never return null: the aggregate is always one of DOWN, OUT_OF_SERVICE, UP or UNKNOWN.'),
    ('senior-aop-order', 1, 'Return the advice callbacks as the strings "<aspect> in" and "<aspect> out", sorted by ascending order value on the way in.'),
    ('senior-aop-order', 2, 'On the way out the aspects run in reverse order, so the lowest order value enters first and exits last.'),
    ('senior-aop-order', 3, 'Break ties between equal order values alphabetically by aspect name, so the result never depends on map iteration order.'),
    ('senior-aop-order', 4, 'Skip null aspect names, and return an empty list for a null or empty aspect map rather than null.'),
    ('senior-propagation-choice', 1, 'Return "REQUIRED" for the scenario "write", because a normal write should join the caller transaction and roll back with it.'),
    ('senior-propagation-choice', 2, 'Return "REQUIRES_NEW" for the scenario "audit", because an audit record must survive a caller rollback in its own independent transaction.'),
    ('senior-propagation-choice', 3, 'Return "NOT_SUPPORTED" for the scenario "long-read", because a long read should suspend any transaction instead of holding locks.'),
    ('senior-propagation-choice', 4, 'Match the scenario ignoring case and surrounding whitespace, and return "REQUIRED" for a null or unrecognized scenario; never return null.'),
    ('senior-api-version-route', 1, 'Choose the highest supported version that is not above the requested version, which is what Spring 7 does when several candidate mappings are at or below the request.'),
    ('senior-api-version-route', 2, 'Compare versions component by component as numbers, so 1.10 is newer than 1.9 and 2 is the same version as 2.0.'),
    ('senior-api-version-route', 3, 'Fall back to the baseline when the request is null or blank, when the supported list is null or empty, or when no supported version is at or below the request.'),
    ('senior-api-version-route', 4, 'Trim surrounding whitespace and return the matching version exactly as it appears in the supported list; never return null.'),
    ('senior-filter-chain-order', 1, 'Return the documented Spring Security filter order as the fifteen names DisableEncodeUrlFilter, WebAsyncManagerIntegrationFilter, SecurityContextHolderFilter, HeaderWriterFilter, CorsFilter, CsrfFilter, LogoutFilter, UsernamePasswordAuthenticationFilter, DefaultLoginPageGeneratingFilter, BasicAuthenticationFilter, RequestCacheAwareFilter, SecurityContextHolderAwareRequestFilter, AnonymousAuthenticationFilter, ExceptionTranslationFilter, AuthorizationFilter.'),
    ('senior-filter-chain-order', 2, 'The security context holder filter runs before the header writer, because the context must be available before anything else reads it.'),
    ('senior-filter-chain-order', 3, 'Cors runs before csrf, csrf before logout, logout before form login, and every authentication filter before authorization.'),
    ('senior-filter-chain-order', 4, 'ExceptionTranslationFilter runs after AnonymousAuthenticationFilter but before AuthorizationFilter, because it translates the access denied exception that filter raises.'),
    ('senior-filter-chain-order', 5, 'Return the same list for every call; never return null.'),
    ('senior-modulith-boundary', 1, 'Treat each map entry as a module and the fully qualified type names it references; a module is known only when it appears as a key in the map.'),
    ('senior-modulith-boundary', 2, 'A reference is a violation only when it targets a known, different module and its package is neither that module''s base package nor its api subpackage; a second package segment starting with an uppercase letter is the type itself, so the type lives in the module base package and is part of the module API.'),
    ('senior-modulith-boundary', 3, 'Return "<source> -> <target>" for every violation, sorted by source module and then by target type, so the result does not depend on map iteration order.'),
    ('senior-modulith-boundary', 4, 'Ignore references to unknown modules, names outside the application base package "com.acme.", and null, blank or null-list entries; return an empty list for a null map instead of null.'),
    ('senior-native-hint-need', 1, 'Map each pattern to the unified reachability metadata file it requires: "reflection:" to reflect-config.json, "resource:" to resource-config.json and "proxy:" to proxy-config.json.'),
    ('senior-native-hint-need', 2, 'Return the distinct metadata files in the documented order reflect-config.json, resource-config.json, proxy-config.json.'),
    ('senior-native-hint-need', 3, 'Match the prefix ignoring case and surrounding whitespace, and ignore unrecognized or blank patterns.'),
    ('senior-native-hint-need', 4, 'Registering reflection for a type already implies constructors, methods and fields, so a member category suffix does not add another entry, and pattern lists may be null or contain nulls without returning null.'),
    ('lead-upgrade-plan', 1, 'Always start the plan with "verify Java 17+ and Jakarta EE 11 baselines", because a framework upgrade is also a container and persistence provider upgrade.'),
    ('lead-upgrade-plan', 2, 'Add "migrate javax.annotation and javax.inject usages to the jakarta packages" when javax annotations are used, then "replace ListenableFuture with CompletableFuture", then "migrate RestTemplate usages to RestClient before the 7.1 deprecation" when those APIs are used.'),
    ('lead-upgrade-plan', 3, 'Keep that exact order in the returned list, because each later step assumes the earlier ones are done.'),
    ('lead-upgrade-plan', 4, 'Return a non-null list with no duplicates; a clean codebase still returns the baseline step.'),
    ('lead-service-template', 1, 'Every new service includes the core components "spring-boot-starter-web", "spring-boot-starter-actuator" and "structured logging with a correlation id", in that order.'),
    ('lead-service-template', 2, 'An API service adds "spring-boot-starter-validation" and "RFC 9457 problem details error contract" after the core components, in that order.'),
    ('lead-service-template', 3, 'A service that writes data adds "spring-boot-starter-data-jpa" and "database migrations managed by flyway or liquibase" after the API components.'),
    ('lead-service-template', 4, 'A production service adds "spring-boot-starter-security", "micrometer metrics with alert thresholds" and "liveness and readiness health probes" last, in that order.'),
    ('mid-query-method-parse', 1, 'describe strips a query prefix (findBy, readBy, getBy, queryBy, searchBy, streamBy, countBy, existsBy, deleteBy) and splits the remainder into criteria on And and Or boundaries, keeping those connector keywords in the description.'),
    ('mid-query-method-parse', 2, 'Each criterion renders as "property OPERATOR": the property keeps its spelling except that the first letter is lower-cased, and the operator is upper-cased with underscores.'),
    ('mid-query-method-parse', 3, 'Supported suffixes are GreaterThan, LessThan, GreaterThanEqual, LessThanEqual, Like, Containing, StartingWith, EndingWith, IsNull and IsNotNull; a criterion with no suffix is EQUALS.'),
    ('mid-query-method-parse', 4, 'Criteria render in declaration order joined by " AND " or " OR "; And and Or are case-sensitive keywords only when followed by an upper-case letter.'),
    ('mid-query-method-parse', 5, 'A null, blank or prefix-less method name, an empty criterion, a criterion made only of a keyword, or a leading/dangling connector is rejected with IllegalArgumentException.'),
    ('mid-page-vs-slice', 1, 'chooseReturnType returns "Page" whenever needsTotalCount is true, because Page carries the total element count and total page count while Slice does not.'),
    ('mid-page-vs-slice', 2, 'When needsTotalCount is false but either largeTable or infiniteScroll is true, it returns "Slice", because Slice avoids the extra count query and only needs the row after the page to detect a next slice.'),
    ('mid-page-vs-slice', 3, 'When none of the flags are set, it returns "Page" as the default with the full metadata.'),
    ('mid-page-vs-slice', 4, 'The two flags largeTable and infiniteScroll are treated as a single "avoid the count" signal.'),
    ('mid-page-vs-slice', 5, 'The result is always exactly "Page" or "Slice" with that capitalisation.'),
    ('mid-scope-authorisation', 1, 'authorised returns true when the granted set contains the scope value "admin", because the admin scope grants every scope.'),
    ('mid-scope-authorisation', 2, 'It also returns true when adminBypass is true, even if granted is null or empty.'),
    ('mid-scope-authorisation', 3, 'Otherwise it returns true only when granted contains required as an exact, case-sensitive scope value.'),
    ('mid-scope-authorisation', 4, 'A null, blank or whitespace-containing required value is never authorised without an admin scope or bypass.'),
    ('mid-scope-authorisation', 5, 'A null or empty granted set is denied when there is no admin scope and no bypass.'),
    ('mid-password-policy', 1, 'violations checks, in this order: "too short" when the password is shorter than minLength, "no upper" when it has no upper-case letter, "no lower" when it has no lower-case letter, "no digit" when it has no digit, and "no symbol" when it has none of ! @ # $ % ^ & *.'),
    ('mid-password-policy', 2, 'The returned list contains one message per broken rule in that order and is empty when the password satisfies every rule.'),
    ('mid-password-policy', 3, 'A null password fails every rule, so it returns all five messages in order.'),
    ('mid-password-policy', 4, 'A password exactly at minLength is long enough; shorter passwords are too short.'),
    ('senior-jwt-claims', 1, 'Missing claims are reported first as "missing sub", "missing exp" and "missing aud" in that order, for a null claim map too; a claim counts as missing when it is absent or null.'),
    ('senior-jwt-claims', 2, 'After the missing-claim checks, the token is "expired" when exp is not greater than nowEpochSeconds, and "audience mismatch" when expectedAudience is non-null and the aud value is not equal to it.'),
    ('senior-jwt-claims', 3, 'The audience check is skipped entirely when expectedAudience is null or blank, and aud is still required in the claims.'),
    ('senior-jwt-claims', 4, 'exp is compared as a long; a fractional or string value that is not a Long or Integer counts as missing.'),
    ('senior-jwt-claims', 5, 'The result list is empty only for a token that is missing no claim, is not expired and matches the expected audience.'),
    ('senior-method-security', 1, 'permit evaluates a Spring Security expression made of hasRole(''X''), hasAuthority(''X''), isOwner, parentheses and the ! , && and || operators (the case-insensitive words and, or and not are also accepted).'),
    ('senior-method-security', 2, 'hasRole(''X'') is true when the authorities contain "ROLE_X", while hasAuthority(''X'') is true only when they contain X exactly; both are case-sensitive and false when authorities is null.'),
    ('senior-method-security', 3, 'isOwner is true only when ownerId and callerId are both non-blank and equal.'),
    ('senior-method-security', 4, '! binds tightest, then and, then or, and parentheses override precedence; a null, blank or unrecognised expression is denied without throwing.'),
    ('senior-audit-write', 1, 'auditEntry returns a map with exactly the four keys actor, action, target and outcome in that order.'),
    ('senior-audit-write', 2, 'A null or blank input value is recorded as "unknown" and other values are trimmed.'),
    ('senior-audit-write', 3, 'A value is replaced by "[redacted]" when it mentions password, secret or token (case-insensitive) or contains a run of 12 or more consecutive digits.'),
    ('senior-audit-write', 4, 'The outcome is lower-cased when it is one of success, failure or denied, and is "unknown" otherwise.'),
    ('senior-audit-write', 5, 'The entry must never contain the raw sensitive value in any field.'),
    ('junior-where-builder', 1, 'Return "<column> <operator> ?" for an allowlisted column and operator, where ? is the bound parameter placeholder.'),
    ('junior-where-builder', 2, 'Allow only the columns id, email, status and created_at, and only the operators =, <>, <, <=, > and >=.'),
    ('junior-where-builder', 3, 'Throw IllegalArgumentException for a column or operator that is not allowlisted, for a parameter index below 1, or for null arguments.'),
    ('junior-where-builder', 4, 'Never interpolate a value into the returned SQL text; only a placeholder may follow the operator.'),
    ('junior-row-count', 1, 'Count the values that are greater than the threshold, or greater than or equal to it when inclusive is true.'),
    ('junior-row-count', 2, 'Treat a null list as an empty list and return 0.'),
    ('junior-row-count', 3, 'Handle negative values and repeated values without special cases.'),
    ('junior-null-semantics', 1, 'Return null when either argument is null, mirroring the SQL UNKNOWN result of a NULL comparison.'),
    ('junior-null-semantics', 2, 'Return Boolean.TRUE when both arguments are non-null and equal.'),
    ('junior-null-semantics', 3, 'Return Boolean.FALSE when both arguments are non-null and different.'),
    ('junior-null-semantics', 4, 'Two null values must still return null; NULL = NULL is unknown, never true.'),
    ('junior-order-clause', 1, 'Join the allowlisted column names with ", " and append " ASC" or " DESC" after each column, based on descending.'),
    ('junior-order-clause', 2, 'Allow only the columns id, email, status, created_at and score.'),
    ('junior-order-clause', 3, 'Throw IllegalArgumentException for a null or empty column list, for any unknown column, or for a null column entry.'),
    ('junior-order-clause', 4, 'Do not copy user text verbatim into the clause; every column must pass the allowlist check.'),
    ('mid-index-column-order', 1, 'Return one column order for a composite index: equality columns first, then sort columns, then range columns.'),
    ('mid-index-column-order', 2, 'Preserve the relative order inside each input list and treat null lists as empty.'),
    ('mid-index-column-order', 3, 'Drop duplicate column names and skip null entries, keeping the first occurrence.'),
    ('mid-index-column-order', 4, 'Never modify the input lists.'),
    ('mid-join-fanout', 1, 'parentRows maps a join key to the number of parent rows carrying it; childRows maps the same key to the number of child rows referencing it.'),
    ('mid-join-fanout', 2, 'Model a left join: every parent row survives, and matching child rows multiply it, so a key contributes parentCount * max(1, childCount) rows.'),
    ('mid-join-fanout', 3, 'Return true when the joined row total exceeds the total number of parent rows, meaning the join fans out.'),
    ('mid-join-fanout', 4, 'Treat a null map as empty and ignore non-positive counts.'),
    ('mid-query-count', 1, 'Total queries are 1 (the parent query) plus the child queries needed for all parents.'),
    ('mid-query-count', 2, 'Unbatched, the child cost is parents * childQueriesPerParent, modelling the N+1 problem.'),
    ('mid-query-count', 3, 'Batched, the child cost is ceil(parents * childQueriesPerParent / batchSize).'),
    ('mid-query-count', 4, 'Throw IllegalArgumentException when parents is negative, or when childQueriesPerParent or batchSize is below 1.'),
    ('mid-query-count', 5, 'Zero parents is allowed and costs only the single parent query.'),
    ('mid-isolation-choice', 1, 'Return READ COMMITTED for scenarios that only need to exclude dirty reads: dirty-read and read-only-report.'),
    ('mid-isolation-choice', 2, 'Return REPEATABLE READ for non-repeatable-read and lost-update.'),
    ('mid-isolation-choice', 3, 'Return SERIALIZABLE for phantom-read and write-skew.'),
    ('mid-isolation-choice', 4, 'Throw IllegalArgumentException for a null or unknown scenario instead of guessing.'),
    ('mid-lock-order', 1, 'Return the table names in ascending lexicographic order so every transaction acquires locks in the same sequence.'),
    ('mid-lock-order', 2, 'The result must be identical for any input permutation, which is what makes deadlocks impossible.'),
    ('mid-lock-order', 3, 'Reject a null list or a null table name with IllegalArgumentException, and never modify the input list.'),
    ('mid-lock-order', 4, 'An empty list is allowed and returns an empty list.'),
    ('mid-explain-verdict', 1, 'When sequentialScan is false return INDEX_SCAN, whatever the row counts are.'),
    ('mid-explain-verdict', 2, 'For a sequential scan returning fewer than 1000 scanned rows, return SMALL_TABLE.'),
    ('mid-explain-verdict', 3, 'A sequential scan returning at least half of the scanned rows is a deliberate FULL_SCAN.'),
    ('mid-explain-verdict', 4, 'A selective sequential scan (under half returned) is MISSING_INDEX when no index exists, otherwise STALE_STATISTICS.'),
    ('mid-explain-verdict', 5, 'Throw IllegalArgumentException for negative counts or when rowsReturned exceeds rowsScanned.'),
    ('senior-partition-key', 1, 'A usable partition key is either a time column (created_at, ordered_at) or a tenant column (tenant_id, account_id).'),
    ('senior-partition-key', 2, 'Return the eligible candidate with the highest cardinality from the map; on a tie return the one appearing first in the list.'),
    ('senior-partition-key', 3, 'Return null when no candidate is eligible, when the list is null or empty, or when a candidate has no cardinality entry.'),
    ('senior-partition-key', 4, 'Verify tenant and time columns before cardinality; a high-cardinality column that is neither is not eligible.'),
    ('senior-vacuum-settings', 1, 'vacuum_scale_factor is 0.2 * (1 - updateRatio), clamped up to a floor of 0.01.'),
    ('senior-vacuum-settings', 2, 'vacuum_threshold is 50 - 30 * updateRatio, clamped down to a floor of 20.'),
    ('senior-vacuum-settings', 3, 'vacuum_trigger_rows is floor(vacuum_threshold + vacuum_scale_factor * tableRows), the dead-tuple count that starts a vacuum.'),
    ('senior-vacuum-settings', 4, 'analyze_scale_factor is 0.1 * (1 - updateRatio), clamped up to a floor of 0.005.'),
    ('senior-vacuum-settings', 5, 'Throw IllegalArgumentException when tableRows is negative or updateRatio is outside 0 through 1 inclusive (NaN included).'),
    ('senior-replica-routing', 1, 'Return PRIMARY whenever readYourWrites is true, because a replica may not yet show the caller''s own write.'),
    ('senior-replica-routing', 2, 'Return PRIMARY whenever maxLagMillis is 0, since no lag at all is tolerated.'),
    ('senior-replica-routing', 3, 'Otherwise return REPLICA when lagMillis is less than or equal to maxLagMillis, and PRIMARY when the lag exceeds it.'),
    ('senior-replica-routing', 4, 'Throw IllegalArgumentException when either lag argument is negative.'),
    ('senior-migration-safety', 1, 'Classify a statement containing CONCURRENTLY, or any statement run against a small table, as SAFE.'),
    ('senior-migration-safety', 2, 'On a large table, classify ADD COLUMN with DEFAULT, ALTER COLUMN TYPE and SET NOT NULL as REQUIRES_BACKFILL.'),
    ('senior-migration-safety', 3, 'On a large table, classify CREATE INDEX without CONCURRENTLY as REQUIRES_LOCK.'),
    ('senior-migration-safety', 4, 'Match case-insensitively after trimming, and throw IllegalArgumentException for a null or blank statement.'),
    ('mid-fetch-strategy', 1, 'fetchFor returns "LAZY" whenever the association is not needed every time, no matter whether it is a collection.'),
    ('mid-fetch-strategy', 2, 'When it is needed every time and is a to-one (collection is false) it returns "EAGER", the default for to-one associations.'),
    ('mid-fetch-strategy', 3, 'When it is needed every time and is a collection it returns "JOIN FETCH" only if at most 1000 rows are expected, otherwise it returns "LAZY" because join fetching a collection multiplies the result rows.'),
    ('mid-fetch-strategy', 4, 'The 1000-row threshold is inclusive, and a negative rowsExpected is treated as zero.'),
    ('mid-batch-size', 1, 'batchSize estimates how many rows fit in memoryBudgetKb kibibytes when each row is rowWidthBytes wide.'),
    ('mid-batch-size', 2, 'The estimate divides the budget in bytes (memoryBudgetKb * 1024) by rowWidthBytes using integer arithmetic, then clamps the result into the range 1..1000 inclusive.'),
    ('mid-batch-size', 3, 'A rowWidthBytes of zero or less, or a memoryBudgetKb of zero or less, produces the minimum batch of 1 rather than dividing by zero or going negative.'),
    ('mid-batch-size', 4, 'The maximum is 1000 even when the budget allows many more rows, because larger batches delay flushing and risk memory pressure.'),
    ('mid-optimistic-conflict', 1, 'action returns "RETRY" only when exceptionType names an optimistic-lock conflict, replaysSafe is true, and attempts is still below maxAttempts.'),
    ('mid-optimistic-conflict', 2, 'A conflict is an exception whose type contains OptimisticLockingFailure or StaleObjectState (case-sensitive, so StaleStateException is not one).'),
    ('mid-optimistic-conflict', 3, 'The retry decision uses the attempts already made: when attempts is greater than or equal to maxAttempts there is nothing left to try, so it returns "SURFACE".'),
    ('mid-optimistic-conflict', 4, 'A non-conflict exception type, a null type, or an unsafe replay always returns "SURFACE".'),
    ('mid-dto-projection', 1, 'projection returns a new map holding only the requested fields that exist in the entity, preserving the order of the requested field list.'),
    ('mid-dto-projection', 2, 'Fields absent from the entity or mapped to null are skipped silently instead of being copied.'),
    ('mid-dto-projection', 3, 'A requested "password" field is never copied, even when the entity has a non-null value, and the entity map passed in must not be modified.'),
    ('mid-dto-projection', 4, 'A null or empty requestedFields list, or a null entity, returns an empty map rather than throwing.'),
    ('mid-dto-projection', 5, 'Repeating a field in the request keeps a single entry in its first position.'),
    ('mid-entity-mapping-review', 1, 'problems inspects an entity mapping described by property name to mapping text and returns messages of the form "Order: <detail>", sorted alphabetically.'),
    ('mid-entity-mapping-review', 2, 'When the mapping has no "id" property it reports "Order: missing id" as a single problem, even for a null or empty mapping.'),
    ('mid-entity-mapping-review', 3, 'A collection mapping marked EAGER is reported as "Order: collection <property> should be LAZY" because collections should use LAZY fetch.'),
    ('mid-entity-mapping-review', 4, 'A mapping that combines a generated strategy (IDENTITY, SEQUENCE or TABLE) with a second "assigned" id property is reported as "Order: generated id conflicts with assigned id on <property>".'),
    ('mid-entity-mapping-review', 5, 'A well-formed mapping returns an empty list, and the input map is not modified.'),
    ('senior-second-level-cache', 1, 'cacheRegion returns "none" for a null or blank entityName and for any entity that is not read-mostly, because entities that change often should not be in the second-level cache.'),
    ('senior-second-level-cache', 2, 'A read-mostly entity that is shared across nodes returns "read-only", the safest concurrent strategy for a cluster.'),
    ('senior-second-level-cache', 3, 'A read-mostly entity on a single node returns "read-write" because the read-write strategy needs entity locking that does not work safely in a cluster.'),
    ('senior-second-level-cache', 4, '"transactional" is only ever chosen for the read-mostly single-node case when the caller opts into transaction-scoped caching, so this method never returns it.'),
    ('senior-second-level-cache', 5, 'The only possible results are "read-only", "read-write" and "none".'),
    ('senior-statistics-triage', 1, 'findings inspects a map of Hibernate statistics names to values and returns one message per suspicious metric, sorted alphabetically, or an empty list for a null or empty map.'),
    ('senior-statistics-triage', 2, '"slowest query <n>ms" is reported when queryExecutionMaxTime exceeds 1000 milliseconds.'),
    ('senior-statistics-triage', 3, '"statements not reused" is reported when prepareStatementCount is at least 4 times queryExecutionCount, which indicates JDBC statement caching is off.'),
    ('senior-statistics-triage', 4, '"collections eagerly fetched" is reported when collectionFetchCount is at least 90 percent of entityLoadCount, meaning most loads come from eager collections that should be lazy.'),
    ('senior-statistics-triage', 5, 'A metric that is absent from the map is ignored, and a ratio test is skipped when its denominator is zero or missing.'),
    ('senior-nplusone-detect', 1, 'offenders normalises every non-blank, non-null log line by trimming it, collapsing runs of whitespace to a single space and replacing each run of digits with "?"; grouping is case-sensitive.'),
    ('senior-nplusone-detect', 2, 'The first normalised statement is the parent query, and its number of executions is the parent count P.'),
    ('senior-nplusone-detect', 3, 'Every other normalised statement is an offender only when it executes more than once and at least P times, because that means one execution per parent row.'),
    ('senior-nplusone-detect', 4, 'The result is the sorted list of distinct offender statements, or an empty list for a null, empty or single-statement log.'),
    ('mid-partition-key-choice', 1, 'Ordering is required when the ordering requirement is non-null and non-blank; return the first ordering-safe candidate, or null when none exists.'),
    ('mid-partition-key-choice', 2, 'A candidate is ordering-safe when it is non-null, non-blank, and not equal to "random" ignoring case: never randomize a key that carries an ordering requirement.'),
    ('mid-partition-key-choice', 3, 'Without an ordering requirement, hot key risk prefers a candidate equal to "random" (ignoring case) over the first candidate.'),
    ('mid-partition-key-choice', 4, 'Otherwise return the first non-null, non-blank candidate, or null when there is none.'),
    ('mid-offset-commit', 1, 'Exactly-once processing commits offsets inside the transaction: return "TRANSACTIONAL".'),
    ('mid-offset-commit', 2, 'Exactly-once outranks at-least-once when both are requested.'),
    ('mid-offset-commit', 3, 'Otherwise at-least-once commits synchronously at the end of each batch when batchProcessing is true: return "SYNC_AT_BATCH_BOUNDARY".'),
    ('mid-offset-commit', 4, 'Otherwise at-least-once commits synchronously after each record: return "SYNC_PER_RECORD".'),
    ('mid-offset-commit', 5, 'When neither guarantee is requested, keep auto commit: return "AUTO_COMMIT".'),
    ('mid-dlq-route', 1, 'Invalid bookkeeping — negative attempts or maxAttempts below 1 — returns "DISCARD" and is checked before the other rules.'),
    ('mid-dlq-route', 2, 'A permanent failure is never retried: return "DLQ".'),
    ('mid-dlq-route', 3, 'A transient failure with attempts below maxAttempts returns "RETRY".'),
    ('mid-dlq-route', 4, 'A transient failure that has reached or exceeded maxAttempts returns "DLQ".'),
    ('mid-consumer-dedupe', 1, 'The first delivery of a non-null id adds it to seenIds and returns false.'),
    ('mid-consumer-dedupe', 2, 'A repeat of a recorded id returns true and leaves the set unchanged.'),
    ('mid-consumer-dedupe', 3, 'A null event id is always a duplicate: return true without touching the set.'),
    ('mid-consumer-dedupe', 4, 'A null seenIds throws IllegalArgumentException.'),
    ('mid-schema-compat', 1, 'Treat null lists as empty lists.'),
    ('mid-schema-compat', 2, 'Removing a field is backward compatible only: a new reader can skip it, but an old reader cannot read data that lacks it.'),
    ('mid-schema-compat', 3, 'Adding an optional field with a default is fully compatible; adding a required field without a default is forward compatible only: old readers ignore it, but new readers cannot read old data that lacks it.'),
    ('mid-schema-compat', 4, 'Combining changes: when both directions are broken return "NONE"; otherwise when only backward is broken return "FORWARD", when only forward is broken return "BACKWARD", and when neither is broken return "FULL".'),
    ('senior-exactly-once-decision', 1, 'Cross-system writes cannot be covered by Kafka transactions, so any such pipeline returns "OUTBOX" (transactional outbox), and this wins over every other flag.'),
    ('senior-exactly-once-decision', 2, 'Otherwise an idempotent consumer makes replay harmless, so return "IDEMPOTENT_CONSUMER" even when a transactional sink exists: do not pay for transactions by default.'),
    ('senior-exactly-once-decision', 3, 'Otherwise a transactional Kafka-to-Kafka sink returns "TRANSACTIONS" (read-process-write with sendOffsetsToTransaction).'),
    ('senior-exactly-once-decision', 4, 'Otherwise nothing makes duplicates safe yet: return "AT_LEAST_ONCE".'),
    ('senior-rebalance-impact', 1, 'Fewer than one partition or one consumer is "INVALID", and this is checked first.'),
    ('senior-rebalance-impact', 2, 'More consumers than partitions returns "IDLE_CONSUMERS", because extra members sit idle.'),
    ('senior-rebalance-impact', 3, 'Otherwise assess the disruption: cooperative rebalancing that pauses only moved partitions is "MINIMAL" for stateless consumers and "MODERATE" when consumers hold per-partition state.'),
    ('senior-rebalance-impact', 4, 'Eager rebalancing revokes every partition from every member: "HIGH" for stateless consumers and "SEVERE" when consumers hold per-partition state.'),
    ('senior-outbox-claim', 1, 'claim returns true when the row has no owner, the lease is expired, or the caller already owns the row.'),
    ('senior-outbox-claim', 2, 'A lease whose leaseExpiresAt is less than or equal to now is expired; a later lease owned by another worker is refused.'),
    ('senior-outbox-claim', 3, 'A null or blank workerId can never claim, but a worker may claim a row it already owns even while its lease is live.'),
    ('senior-event-version-route', 1, 'A handler is named "v" + version, for example "v3".'),
    ('senior-event-version-route', 2, 'Return the exact handler when supportedVersions contains the event version.'),
    ('senior-event-version-route', 3, 'Otherwise return the highest supported version strictly below the event version, skipping null entries.'),
    ('senior-event-version-route', 4, 'Return null when no supported version is compatible: an empty or null list, an event version below one, or a version older than every handler.'),
    ('lead-event-governance', 1, 'Always start with these rules in order: "name events in past tense with a stable envelope", "every topic has an accountable owning team", "run the registry compatibility check in CI".'),
    ('lead-event-governance', 2, 'When publiclyConsumed, append "enumerate external consumers before changing the schema" after the base rules.'),
    ('lead-event-governance', 3, 'When regulated, append "classify payloads and enforce the retention policy" after any external-consumer rule.'),
    ('lead-event-governance', 4, 'Always end with "announce deprecations with a supported lifetime".'),
    ('lead-event-governance', 5, 'Return a list of plain rule strings in exactly this documented order.'),
    ('lead-saga-compensation', 1, 'Return the completed steps in reverse completion order.'),
    ('lead-saga-compensation', 2, 'Skip any step whose name starts with "query:" ignoring case, because read-only steps need no compensation.'),
    ('lead-saga-compensation', 3, 'Skip null and blank entries, and keep repeated steps as separate compensations.'),
    ('lead-saga-compensation', 4, 'Null or empty input returns an empty list.'),
    ('mid-message-router', 1, 'Iterate the routing map in its own iteration order and return the first channel whose list contains the message type exactly (case sensitive).'),
    ('mid-message-router', 2, 'Null keys and null accepted-types lists are skipped while matching, so a null key can never become the returned channel.'),
    ('mid-message-router', 3, 'Return "default" when no channel matches, when the message type is null, or when the routing map is null or empty.'),
    ('mid-splitter-aggregate', 1, 'Each chunk is a list whose first element is its correlation id, followed by zero or more payload parts.'),
    ('mid-splitter-aggregate', 2, 'Return the payload parts of every chunk whose correlation id equals correlationId, in chunk order; a header-only chunk contributes nothing.'),
    ('mid-splitter-aggregate', 3, 'Chunks for other ids, null chunks, and empty chunks are ignored, and matching is exact and case sensitive.'),
    ('mid-splitter-aggregate', 4, 'A null correlationId or a null/empty chunk list returns an empty list.'),
    ('mid-cron-next-run', 1, 'Accept a five-field cron: minute, hour, day of month, month and day of week, each either "*" or a plain number (minute 0-59, hour 0-23, day of month 1-31, month 1-12, day of week 0-6 with 0 = Sunday).'),
    ('mid-cron-next-run', 2, 'Return the first fire time strictly after the given time, as LocalDateTime.toString() such as 2026-10-06T09:30; all five fields must match the fire time.'),
    ('mid-cron-next-run', 3, 'Throw IllegalArgumentException for a malformed cron (wrong field count, non-numeric value, value outside its range), for a null cron or after time, and for a cron that can never fire such as day 31 of February.'),
    ('senior-batch-partition', 1, 'Reject negative rows, a chunkSize below 1, and a targetWorkers below 1 with IllegalArgumentException.'),
    ('senior-batch-partition', 2, 'Zero rows need no partitions: return 0.'),
    ('senior-batch-partition', 3, 'Otherwise return the smaller of targetWorkers and the chunk count ceil(rows / chunkSize), never fewer than 1.'),
    ('senior-batch-partition', 4, 'The chunk count must stay correct for very large row counts, so do not overflow while rounding up.'),
    ('senior-file-idempotency', 1, 'A file is already imported only when the history contains the same name recorded with the same size.'),
    ('senior-file-idempotency', 2, 'The same name with a different size is treated as a new file, and a name with no recorded size is not a duplicate.'),
    ('senior-file-idempotency', 3, 'Matching is exact and case sensitive; return false when the name is unknown.'),
    ('senior-file-idempotency', 4, 'A null or blank name, a negative size, and a null history throw IllegalArgumentException.'),
    ('junior-path-template', 1, 'Return a path that starts with a single leading slash.'),
    ('junior-path-template', 2, 'Join the base and the segments with single slashes, removing any leading or trailing slashes from each part.'),
    ('junior-path-template', 3, 'Ignore blank or null segments.'),
    ('junior-path-template', 4, 'Encode every space inside a segment as %20.'),
    ('junior-path-template', 5, 'Return "/" when there is no base and no usable segment.'),
    ('junior-status-code-choice', 1, 'Return 201 for create, 200 for read, 204 for delete and 202 for accept.'),
    ('junior-status-code-choice', 2, 'Match actions case-insensitively and ignore surrounding spaces.'),
    ('junior-status-code-choice', 3, 'Throw IllegalArgumentException for a null, blank or unrecognised action.'),
    ('junior-status-code-choice', 4, 'Only success status codes are returned.'),
    ('junior-query-filter-parse', 1, 'Split the query on "&" and each pair on its first "="; ignore blank pairs and blank keys.'),
    ('junior-query-filter-parse', 2, 'Decode keys and values with URL decoding: "+" becomes a space and "%XX" becomes the byte it names.'),
    ('junior-query-filter-parse', 3, 'Keys are trimmed after decoding; a parameter without "=" maps to the empty string.'),
    ('junior-query-filter-parse', 4, 'When a key repeats, the last value wins.'),
    ('junior-query-filter-parse', 5, 'Treat a null or blank query as an empty map.'),
    ('mid-etag-compute', 1, 'Return a strong ETag: a double quote, the lowercase hex SHA-256 digest, and a closing double quote.'),
    ('mid-etag-compute', 2, 'Digest the body bytes followed by the ASCII digits of version; a null body counts as empty.'),
    ('mid-etag-compute', 3, 'The same body and version always produce the same ETag, and a different version always produces a different ETag.'),
    ('mid-etag-compute', 4, 'An empty body still produces a quoted 64-character digest.'),
    ('mid-cursor-pagination', 1, 'encode returns the base64url (no padding) form of the UTF-8 text sortKey + "|" + id.'),
    ('mid-cursor-pagination', 2, 'decode reverses encode and splits the decoded text on the first "|".'),
    ('mid-cursor-pagination', 3, 'decode tolerates standard base64 padding and the standard base64 alphabet.'),
    ('mid-cursor-pagination', 4, 'Null arguments to encode throw IllegalArgumentException.'),
    ('mid-cursor-pagination', 5, 'decode returns an empty array for null, blank, non-base64 or separator-free input instead of throwing.'),
    ('mid-problem-json', 1, 'Return a map with exactly the members type, title, status, detail and instance.'),
    ('mid-problem-json', 2, 'type is "about:blank", status is an Integer, and instance defaults to "" when null.'),
    ('mid-problem-json', 3, 'title is the standard reason phrase for the common codes (400, 401, 403, 404, 409, 422, 429, 500, 503), otherwise Client Error for unlisted 4xx and Server Error for unlisted 5xx.'),
    ('mid-problem-json', 4, 'A null detail falls back to the title.'),
    ('mid-problem-json', 5, 'Throw IllegalArgumentException for a status outside 400..599.'),
    ('mid-content-negotiation', 1, 'Parse the Accept header as comma separated media ranges, each with an optional q parameter (default 1).'),
    ('mid-content-negotiation', 2, 'A supported type matches an accept entry when the entry is the same type, the same type family with a * subtype, or */*.'),
    ('mid-content-negotiation', 3, 'The quality of a supported type is the highest q among the entries that match it; q=0 entries never match.'),
    ('mid-content-negotiation', 4, 'Return the supported type with the highest quality, breaking ties with the order of supported.'),
    ('mid-content-negotiation', 5, 'When the header is absent or nothing matches, return the first supported type; a null or empty supported list throws IllegalArgumentException.'),
    ('mid-rate-limit-headers', 1, 'Return exactly four headers: RateLimit-Limit, RateLimit-Remaining, RateLimit-Reset and RateLimit-Policy.'),
    ('mid-rate-limit-headers', 2, 'Every value is the decimal text of the number.'),
    ('mid-rate-limit-headers', 3, 'RateLimit-Policy is the limit followed by ";w=60".'),
    ('mid-rate-limit-headers', 4, 'Clamp remaining into 0..limit so it is never negative and never above the limit.'),
    ('mid-rate-limit-headers', 5, 'Throw IllegalArgumentException for a negative limit or a negative reset.'),
    ('senior-breaking-change', 1, 'Field descriptors are type names such as "int" or "string"; a trailing "!" marks a required field.'),
    ('senior-breaking-change', 2, '"removed: NAME (TYPE)" is reported for every field in before that is missing from after.'),
    ('senior-breaking-change', 3, 'Numeric ranks are byte, short, int, long, float, double; "narrowed: NAME (OLD -> NEW)" is reported when both descriptors are numeric and the new rank is lower than the old rank.'),
    ('senior-breaking-change', 4, 'A widening between numeric descriptors (new rank at least as high) is compatible and is not reported.'),
    ('senior-breaking-change', 5, 'Any other change to a surviving field is "changed: NAME (OLD -> NEW)", and "new required: NAME (TYPE)" is reported for a field added by after whose descriptor ends with "!".'),
    ('senior-breaking-change', 6, 'Sort the result alphabetically; a null map throws IllegalArgumentException.'),
    ('senior-graphql-depth', 1, 'Return the maximum nesting depth of { selection sets in the query.'),
    ('senior-graphql-depth', 2, 'Braces inside double quoted strings, triple quoted block strings and # comments are ignored.'),
    ('senior-graphql-depth', 3, 'Backslash escapes inside a string do not end it.'),
    ('senior-graphql-depth', 4, 'Return 0 when the query has no braces at all.'),
    ('senior-graphql-depth', 5, 'Return -1 for null, blank or unbalanced input, including a string that is never closed.'),
    ('senior-grpc-field-safety', 1, 'Protobuf field numbers 19000 to 19999 inclusive are reserved for the implementation.'),
    ('senior-grpc-field-safety', 2, 'The largest valid field number is 536870911; numbers above it are unsafe, and so are numbers below 1.'),
    ('senior-grpc-field-safety', 3, 'Return the unsafe numbers sorted ascending and without duplicates.'),
    ('senior-grpc-field-safety', 4, 'Throw IllegalArgumentException for a null list or a null element.'),
    ('junior-header-parse', 1, 'Split the block into lines on \n and \r\n and ignore blank lines or lines without a colon.'),
    ('junior-header-parse', 2, 'Take the header name before the first colon and the value after it, trimming both.'),
    ('junior-header-parse', 3, 'Store names lower-cased; the last value for a repeated name wins.'),
    ('junior-header-parse', 4, 'Values may contain colons and may be empty; a missing name (line starting with a colon) is a malformed line.'),
    ('junior-header-parse', 5, 'Treat null input as an empty map.'),
    ('junior-uri-normalise', 1, 'Collapse runs of slashes into one and always return a path that starts with a single slash.'),
    ('junior-uri-normalise', 2, 'Remove "." segments and resolve ".." by popping the previous segment; ".." at the root is ignored rather than escaping.'),
    ('junior-uri-normalise', 3, 'Remove the trailing slash unless the path is "/".'),
    ('junior-uri-normalise', 4, 'Keep the query string (from the first ?) and the fragment (from the first #) unchanged.'),
    ('junior-uri-normalise', 5, 'Treat null or blank input as the root path.'),
    ('junior-status-class', 1, '100 to 199 is INFORMATIONAL, 200 to 299 is SUCCESS, 300 to 399 is REDIRECT.'),
    ('junior-status-class', 2, '400 to 499 is CLIENT_ERROR and 500 to 599 is SERVER_ERROR.'),
    ('junior-status-class', 3, 'Any other number, including negatives and values above 599, is UNKNOWN.'),
    ('junior-status-class', 4, 'The class name is the only thing returned: classify(404) is CLIENT_ERROR, not a reason phrase.'),
    ('mid-cache-freshness', 1, 'An entry may be used only when ageSeconds is strictly less than maxAgeSeconds and mustRevalidate is false.'),
    ('mid-cache-freshness', 2, 'An entry whose age equals or exceeds maxAgeSeconds is stale.'),
    ('mid-cache-freshness', 3, 'A maxAgeSeconds of zero is always stale, even at age zero.'),
    ('mid-cache-freshness', 4, 'Throw IllegalArgumentException when ageSeconds or maxAgeSeconds is negative.'),
    ('mid-retry-safety', 1, 'GET, HEAD, PUT, OPTIONS and TRACE are safe methods; POST, PATCH and DELETE are unsafe.'),
    ('mid-retry-safety', 2, 'A request is retryable when the status is one of 429, 500, 502, 503 and 504 and either the method is safe or an idempotency key is present.'),
    ('mid-retry-safety', 3, 'Success and other client error statuses are never retried.'),
    ('mid-retry-safety', 4, 'Match the method case-insensitively after trimming.'),
    ('mid-retry-safety', 5, 'Throw IllegalArgumentException for a null or unknown method and for a status below 100 or above 599.'),
    ('mid-timeout-budget', 1, 'Split totalMillis evenly over attempts; the per attempt share is totalMillis / attempts (integer division), so a tiny total with many attempts can leave a zero share.'),
    ('mid-timeout-budget', 2, 'Give the per attempt share a read budget of half of it (integer division) and a connect budget of the rest, so connect + read equals the share.'),
    ('mid-timeout-budget', 3, 'Return a map with exactly the keys budget, connect and read, where budget is the unchanged total in milliseconds.'),
    ('mid-timeout-budget', 4, 'Throw IllegalArgumentException when totalMillis is below 1 or attempts is below 1.'),
    ('mid-cors-decision', 1, 'Use the exact strings Access-Control-Allow-Origin, Access-Control-Allow-Methods, Access-Control-Allow-Credentials and Vary as header names.'),
    ('mid-cors-decision', 2, 'When allowedOrigins contains the request origin, echo that origin back; when it contains "*", allow any origin; otherwise return an empty list.'),
    ('mid-cors-decision', 3, 'Never return a wildcard allow origin together with credentials: that combination is an empty list.'),
    ('mid-cors-decision', 4, 'Every allowed response carries the requested method and Vary: Origin, except wildcard responses which must not vary.'),
    ('mid-cors-decision', 5, 'Throw IllegalArgumentException for a null or blank origin, a null method or a null allow list.'),
    ('senior-tls-policy', 1, 'Flag a protocol by adding "deprecated protocol: NAME" when the name is SSLv3, TLSv1, TLSv1.0 or TLSv1.1 (ignoring case).'),
    ('senior-tls-policy', 2, 'Flag a cipher suite by adding "weak cipher suite: NAME" when its upper-cased name contains _RC4_, _3DES_, _DES_, _NULL_ or EXPORT.'),
    ('senior-tls-policy', 3, 'Append "hostname verification disabled" and "certificate chain verification disabled" when the respective flag is false.'),
    ('senior-tls-policy', 4, 'Sort the findings alphabetically.'),
    ('senior-tls-policy', 5, 'Throw IllegalArgumentException when protocol or cipherSuite is null.'),
    ('senior-http2-decision', 1, 'Return "enable http/2" when concurrentRequests is at least 100 or headOfLineBlocking is true.'),
    ('senior-http2-decision', 2, 'Otherwise return "avoid server push" when serverPush is true.'),
    ('senior-http2-decision', 3, 'Otherwise return "keep http/1.1".'),
    ('senior-http2-decision', 4, 'Only enable http/2, avoid server push and keep http/1.1 are ever returned.'),
    ('senior-http2-decision', 5, 'Throw IllegalArgumentException for a negative concurrentRequests.'),
    ('mid-circuit-state', 1, 'State flows between CLOSED, OPEN and HALF_OPEN; unknown or null states are rejected with IllegalArgumentException.'),
    ('mid-circuit-state', 2, 'CLOSED keeps normal traffic and moves to OPEN when a call fails and failureRate has reached threshold.'),
    ('mid-circuit-state', 3, 'OPEN ignores call outcomes and stays OPEN until a recovery probe begins.'),
    ('mid-circuit-state', 4, 'HALF_OPEN closes on a successful probe and reopens on a failed probe.'),
    ('mid-circuit-state', 5, 'failureRate must be 0..100 and threshold must be 1..100; both are validated.'),
    ('mid-bulkhead-limit', 1, 'The reserve percentage of the capacity is held back before the remainder is divided evenly between the dependencies.'),
    ('mid-bulkhead-limit', 2, 'Each dependency receives floor(usable / dependencies) permits and always at least one permit.'),
    ('mid-bulkhead-limit', 3, 'dependencyCapacity and dependencies must be positive and reservePercent must be 0..99; otherwise throw IllegalArgumentException.'),
    ('mid-discovery-cache', 1, 'A cached entry is fresh while cachedAgeMillis is less than or equal to ttlMillis and the action is USE_CACHE.'),
    ('mid-discovery-cache', 2, 'A stale entry asks the registry for fresh data with REFRESH when registryAvailable is true.'),
    ('mid-discovery-cache', 3, 'A stale entry with an unreachable registry returns FAIL_FAST instead of serving stale data.'),
    ('mid-discovery-cache', 4, 'Negative ages or ttl values throw IllegalArgumentException.'),
    ('mid-correlation-id', 1, 'A non-blank inbound header of at most 64 characters is trimmed and preserved as the correlation id.'),
    ('mid-correlation-id', 2, 'A null, blank or longer-than-64-characters inbound header is replaced by generator.get().'),
    ('mid-correlation-id', 3, 'The generator is only invoked when a new id is required, and a null generator throws IllegalArgumentException.'),
    ('mid-correlation-id', 4, 'A blank generated id throws IllegalStateException.'),
    ('mid-error-budget', 1, 'budget(target, totalRequests, failedRequests) reports allowedFraction = 1 - target plus the consumed and remaining parts of the error budget.'),
    ('mid-error-budget', 2, 'The allowed failure count is floor(totalRequests * allowedFraction); consumedFraction is failedRequests divided by that count, clamped to at most 1.'),
    ('mid-error-budget', 3, 'consumedFraction reaches exactly 1 when the failures use the whole budget, and any failure in a zero-failure budget is already exhausted.'),
    ('mid-error-budget', 4, 'remainingFraction is 1 - consumedFraction and exhausted is true when consumedFraction reaches 1.'),
    ('mid-error-budget', 5, 'target must be strictly between 0 and 1, totalRequests must not be negative, and failedRequests must be within 0..totalRequests; otherwise throw IllegalArgumentException.'),
    ('senior-saga-compensate', 1, 'compensate returns the completed steps as compensation actions in reverse completion order.'),
    ('senior-saga-compensate', 2, 'The failed step is never compensated, and steps whose name starts with "audit-" are irreversible and skipped.'),
    ('senior-saga-compensate', 3, 'Each distinct step is compensated once, at its latest completed position.'),
    ('senior-saga-compensate', 4, 'A null completed list, null entries or a list that filters down to nothing yields an empty list.'),
    ('senior-tenant-routing', 1, 'datasourceFor returns "isolated:" + tenantId for tenants whose tier is REGULATED and "pooled" for everyone else.'),
    ('senior-tenant-routing', 2, 'Tiers are matched after trimming and ignoring case, and unknown or missing tiers use the pooled datasource.'),
    ('senior-tenant-routing', 3, 'A null or blank tenant id throws IllegalArgumentException; a null tier map behaves like an empty map.'),
    ('senior-strangler-route', 1, 'The user bucket is Math.floorMod(userId.hashCode(), 100) so routing is sticky for every user.'),
    ('senior-strangler-route', 2, 'A user moves to the new implementation when the bucket is below rolloutPercent, otherwise it stays on legacy while legacy is healthy.'),
    ('senior-strangler-route', 3, 'When the legacy implementation is unhealthy its share fails over to the new implementation.'),
    ('senior-strangler-route', 4, 'rolloutPercent must be 0..100 and userId must be non-blank; otherwise throw IllegalArgumentException.'),
    ('senior-contract-compat', 1, 'violations compares the consumer-required fields with the provider''s provided fields and lists "missing:<field>" or "type:<field>" for each problem.'),
    ('senior-contract-compat', 2, 'A required field that is absent or null in provided counts as missing, and a provided value that differs counts as a type mismatch.'),
    ('senior-contract-compat', 3, 'Extra provided fields are allowed and field names are case sensitive.'),
    ('senior-contract-compat', 4, 'The violation list is sorted alphabetically; a null provided map means nothing is available and a null required map means no violations.'),
    ('lead-resilience-standard', 1, 'New services must adopt these resilience patterns: remote calls need timeout, circuit-breaker and bulkhead; data writes need an idempotency-key; user-facing surfaces need graceful-degradation.'),
    ('lead-resilience-standard', 2, 'The result lists only the patterns required by the flags, in the canonical order timeout, circuit-breaker, bulkhead, idempotency-key, graceful-degradation.'),
    ('lead-resilience-standard', 3, 'An internal service that does none of these has an empty standard.'),
    ('lead-monolith-split', 1, 'coupling maps each module to the modules it depends on; modules that appear only as a dependency are still part of the graph.'),
    ('lead-monolith-split', 2, 'A module can only be extracted after all of its remaining dependencies, and each extraction removes the module from the graph.'),
    ('lead-monolith-split', 3, 'Among the extractable modules (those whose remaining dependencies are gone), the one with the fewest couplings in the remaining graph is extracted first, where couplings are remaining dependencies plus remaining dependents; ties are broken alphabetically.'),
    ('lead-monolith-split', 4, 'A split order exists only when the dependency graph is acyclic; any cycle, including a self reference, means nothing is separable and the result is empty, as it is for a null or empty map.'),
    ('senior-quality-tactic', 1, 'tactics returns the documented tactics for the given quality attribute in canonical order.'),
    ('senior-quality-tactic', 2, 'availability: heartbeat-monitor, passive-redundancy and graceful-degradation, with active-redundancy replacing passive-redundancy when latencyCritical is true.'),
    ('senior-quality-tactic', 3, 'performance: resource-pooling and prioritise-requests, with introduce-concurrency added when latencyCritical is true.'),
    ('senior-quality-tactic', 4, 'modifiability: reduce-coupling, increase-cohesion, defer-binding and use-an-intermediary, unchanged by latency.'),
    ('senior-quality-tactic', 5, 'security: authenticate-requests, authorise-requests, encrypt-sensitive-data and audit-access, unchanged by latency.'),
    ('senior-quality-tactic', 6, 'Attribute names ignore surrounding whitespace and case; an unknown or null attribute throws IllegalArgumentException.'),
    ('senior-adr-review', 1, 'A decision record must contain the sections context, options, decision, consequences and revisit.'),
    ('senior-adr-review', 2, 'A section counts as present only when its key maps to a non-blank value; keys are matched ignoring case and surrounding whitespace, and extra keys are ignored.'),
    ('senior-adr-review', 3, 'missingSections returns the absent sections in the canonical order context, options, decision, consequences, revisit; a null record misses every section.'),
    ('senior-instability-metric', 1, 'instability = efferent / (afferent + efferent) where afferent is incoming and efferent is outgoing coupling.'),
    ('senior-instability-metric', 2, 'A component with no coupling at all has zero instability, pure efferent coupling gives 1.0 and pure afferent coupling gives 0.0.'),
    ('senior-instability-metric', 3, 'Negative coupling counts throw IllegalArgumentException, and large counts must not overflow.'),
    ('lead-roadmap-sequence', 1, 'sequence orders the given roadmap items so that every blocker comes before the item it blocks; blockers that are not in the item list are ignored.'),
    ('lead-roadmap-sequence', 2, 'Ready items are emitted alphabetically, and null or duplicate items are ignored so each item appears once.'),
    ('lead-roadmap-sequence', 3, 'Any cycle, including a self dependency, means no valid order exists and the result is an empty list; a null or empty item list is also empty.'),
    ('lead-cost-capacity', 1, 'recommendations reports the actions the documented thresholds require, in the canonical order scale-out, consolidate, optimise-latency, reduce-spend.'),
    ('lead-cost-capacity', 2, 'utilisation above 0.80 needs scale-out and below 0.30 needs consolidate; a p99 above 300 ms needs optimise-latency; a budget utilisation of 1.0 or more needs reduce-spend.'),
    ('lead-cost-capacity', 3, 'Thresholds are exclusive when compared: exactly 0.80, 0.30 or 300 ms triggers nothing, while 1.0 budget utilisation is already exhausted.'),
    ('lead-cost-capacity', 4, 'Measurements must be finite and non-negative; otherwise throw IllegalArgumentException.'),
    ('principal-system-shape', 1, 'shape chooses the system shape from the deployment and consistency constraints and the number of teams.'),
    ('principal-system-shape', 2, 'Without independent deployment the answer is MODULAR_MONOLITH; independent deployment with strong consistency required is SERVICES regardless of team count.'),
    ('principal-system-shape', 3, 'Independent deployment with weak consistency is SERVICES below five teams and EVENT_DRIVEN from five teams up, since asynchronous integration decouples many teams.'),
    ('principal-system-shape', 4, 'teamCount must be positive; otherwise throw IllegalArgumentException.'),
    ('principal-governance', 1, 'governance picks the API governance model with its rationale from regulation, team count and platform-team availability.'),
    ('principal-governance', 2, 'A regulated organisation without a central platform team needs CENTRAL_REVIEW; with a central platform team it uses PLATFORM_TEAM, where guardrails are automated on the paved road.'),
    ('principal-governance', 3, 'Unregulated organisations use PLATFORM_TEAM when a central platform team exists; otherwise CENTRAL_REVIEW below eight teams and FEDERATED from eight teams up, since central review cannot scale to many teams.'),
    ('principal-governance', 4, 'teamCount must be positive; otherwise throw IllegalArgumentException.'),
    ('mid-value-object-equality', 1, 'Money is a record with a long cents amount and a String currency.'),
    ('mid-value-object-equality', 2, 'The compact constructor normalises the currency to upper case using Locale.ROOT, and a null currency becomes an empty string.'),
    ('mid-value-object-equality', 3, 'Record equality and hashCode are value based, so two Money values with the same normalised fields are equal.'),
    ('mid-value-object-equality', 4, 'sameValue(Money other) returns true when both fields match and false when other is null.'),
    ('mid-value-object-equality', 5, 'Negative amounts are allowed and compare like any other value.'),
    ('mid-aggregate-invariant', 1, 'The aggregate may hold at most maxItems items and can never drop below zero.'),
    ('mid-aggregate-invariant', 2, 'A request is allowed only when requested is at least 1 and currentItems + requested stays within maxItems.'),
    ('mid-aggregate-invariant', 3, 'A request of zero or less is always rejected.'),
    ('mid-aggregate-invariant', 4, 'A current count below zero or above maxItems is a corrupt aggregate and every request is rejected.'),
    ('mid-aggregate-invariant', 5, 'A negative maxItems leaves no capacity, so every request is rejected.'),
    ('mid-domain-event-name', 1, 'Build the event name from the aggregate part and the action part, both split on any run of non-alphanumeric characters.'),
    ('mid-domain-event-name', 2, 'Each part is converted to PascalCase: every word is lower cased and its first letter is upper cased, so order_item becomes OrderItem.'),
    ('mid-domain-event-name', 3, 'The action is then turned into the past tense: an action already ending in "ed" is kept, one ending in "e" takes a "d", one ending in a consonant plus "y" changes "y" to "ied", and everything else takes "ed".'),
    ('mid-domain-event-name', 4, 'A null or blank part contributes nothing, so the event name is the one non-empty part, and both parts empty give "".'),
    ('mid-domain-event-name', 5, 'For example the aggregate order and the action place produce OrderPlaced.'),
    ('mid-repository-contract', 1, 'Return the repository methods the aggregate actually needs, chosen from findById, save and findByOwner.'),
    ('mid-repository-contract', 2, 'needsLookupById adds findById, needsSave adds save and needsQueryByOwner adds findByOwner.'),
    ('mid-repository-contract', 3, 'List the methods in the fixed order findById, save, findByOwner and return an empty list when nothing is needed.'),
    ('mid-repository-contract', 4, 'Repository contracts use domain language only: never SQL words such as select, insert, update or delete.'),
    ('mid-ubiquitous-terms', 1, 'codeNames maps each concept to the term used in the code, and glossary maps the same concept to the agreed ubiquitous-language term.'),
    ('mid-ubiquitous-terms', 2, 'Two terms match when they are equal after trimming surrounding spaces and ignoring case, so ''Order Total'' and '' order total '' match.'),
    ('mid-ubiquitous-terms', 3, 'Report "concept: code uses ''X'' but glossary says ''Y''" for every concept whose terms do not match, showing the trimmed names with their original case.'),
    ('mid-ubiquitous-terms', 4, 'Concepts missing from the glossary and entries with a null concept key are ignored.'),
    ('mid-ubiquitous-terms', 5, 'A null name is treated as an empty string.'),
    ('mid-ubiquitous-terms', 6, 'Sort the report by concept.'),
    ('senior-context-map', 1, 'The pattern is derived from three facts: whether the upstream team controls the model, whether the downstream team adopts the upstream model, and whether a translation layer exists.'),
    ('senior-context-map', 2, 'A translation layer without downstream adoption returns ANTICORRUPTION_LAYER.'),
    ('senior-context-map', 3, 'Otherwise, an upstream controlled model that the downstream adopts returns CONFORMIST.'),
    ('senior-context-map', 4, 'Otherwise, when none of the three facts holds, return SHARED_KERNEL.'),
    ('senior-context-map', 5, 'Every remaining combination returns CUSTOMER_SUPPLIER.'),
    ('senior-context-map', 6, 'Return exactly one of SHARED_KERNEL, CONFORMIST, ANTICORRUPTION_LAYER or CUSTOMER_SUPPLIER.'),
    ('senior-anticorruption-translate', 1, 'Build the internal model from the external payload using fieldMap, which maps each external field name to the internal field name.'),
    ('senior-anticorruption-translate', 2, 'Copy only fields whose external name exists in external; unmapped external fields and mappings for missing external fields are dropped.'),
    ('senior-anticorruption-translate', 3, 'Skip any mapping whose external or internal name is null, and any mapping whose internal name is blank.'),
    ('senior-anticorruption-translate', 4, 'When several external fields map to the same internal name, the first mapping in fieldMap iteration order wins.'),
    ('senior-anticorruption-translate', 5, 'A null external payload or a null fieldMap yields an empty map, and null values are carried across as null.'),
    ('senior-event-replay', 1, 'Every event is "<TYPE> <amount>", exactly two whitespace separated parts, with TYPE compared case-insensitively as CREDIT or DEBIT and an integer amount of zero or more.'),
    ('senior-event-replay', 2, 'Events apply in order to the starting balance: CREDIT adds the amount and DEBIT subtracts it.'),
    ('senior-event-replay', 3, 'When a debit would leave the balance below zero, throw an IllegalStateException with the message "balance cannot go negative".'),
    ('senior-event-replay', 4, 'A null list replays nothing, and null or blank entries are ignored.'),
    ('senior-event-replay', 5, 'An event with an unknown type, a negative amount or a non-integer amount throws an IllegalArgumentException.'),
    ('junior-assertion-choice', 1, 'Choose the assertion method that expresses a requested check and return its AssertJ method name.'),
    ('junior-assertion-choice', 2, '"equality" maps to "isEqualTo" and "null" maps to "isNull".'),
    ('junior-assertion-choice', 3, '"not-null" maps to "isNotNull" and "exception" maps to "isInstanceOf".'),
    ('junior-assertion-choice', 4, '"collection-size" maps to "hasSize" and "collection-empty" maps to "isEmpty".'),
    ('junior-assertion-choice', 5, 'Any other check, including null, maps to "unknown".'),
    ('junior-assertion-choice', 6, 'Check names are matched ignoring case.'),
    ('junior-test-name-quality', 1, 'Judge a test name by whether it states a condition and an expected outcome.'),
    ('junior-test-name-quality', 2, 'A condition word is one of: when, given, if.'),
    ('junior-test-name-quality', 3, 'An expectation word is one of: then, should, returns, throws.'),
    ('junior-test-name-quality', 4, 'Report "missing-condition" when no condition word appears and "missing-expectation" when no expectation word appears, in that order.'),
    ('junior-test-name-quality', 5, 'Names are split into words at non-letter characters and camel-case boundaries and matched case-insensitively.'),
    ('junior-test-name-quality', 6, 'A null or blank name reports both problems, and a name containing both parts reports none.'),
    ('junior-test-structure', 1, 'Classify every line of an Arrange-Act-Assert test as SETUP, EXERCISE, VERIFY or NOISE, one label per line and in order.'),
    ('junior-test-structure', 2, 'A line starting with "given", "prepare" or "arrange" is SETUP.'),
    ('junior-test-structure', 3, 'A line starting with "when", "call" or "invoke" is EXERCISE.'),
    ('junior-test-structure', 4, 'A line starting with "assert", "verify", "expect" or "then" is VERIFY.'),
    ('junior-test-structure', 5, 'Any other line, including a blank line or a comment, is NOISE.'),
    ('junior-test-structure', 6, 'Matching ignores leading whitespace and letter case, and a null list returns an empty list.'),
    ('mid-parameterised-cases', 1, 'Turn every input string into one parameterised test case row of the form {name, input, expected}.'),
    ('mid-parameterised-cases', 2, 'The name is the trimmed input, except that an empty input is named "empty" and a blank input is named "blank".'),
    ('mid-parameterised-cases', 3, 'The expected value is the length of the trimmed input.'),
    ('mid-parameterised-cases', 4, 'Rows keep the order of the input list, and the result is never empty when inputs are given.'),
    ('mid-parameterised-cases', 5, 'A null or empty input list returns an empty list.'),
    ('mid-parameterised-cases', 6, 'The expected value is always a non-null Integer.'),
    ('mid-interaction-verify', 1, 'Plan the verifications for a test that exercises a service throwing a checked exception.'),
    ('mid-interaction-verify', 2, 'Add "verify once with expected argument" when the method was called exactly once.'),
    ('mid-interaction-verify', 3, 'Add "verify times(N)" when the method was called more than once, using the actual count.'),
    ('mid-interaction-verify', 4, 'Add "verify payload is unchanged" when idempotency is required.'),
    ('mid-interaction-verify', 5, 'A count of zero or less, or a call that never happened, adds no call verification.'),
    ('mid-interaction-verify', 6, 'Every applicable verification is reported in the documented order, and results never contain duplicates.'),
    ('mid-container-lifecycle', 1, 'Pick a test container lifecycle from the values a test suite already knows.'),
    ('mid-container-lifecycle', 2, 'Return "PER_TEST" when tests need mutable state, because every test then needs a fresh container.'),
    ('mid-container-lifecycle', 3, 'Return "PER_CLASS" for a shared container when the suite has at least 3 tests and startup takes at least 10 seconds.'),
    ('mid-container-lifecycle', 4, 'Return "PER_CLASS" for a shared container when the suite has at least 5 tests and startup takes at least 2 seconds.'),
    ('mid-container-lifecycle', 5, 'Otherwise return "PER_METHOD", the default single container instance that shares nothing.'),
    ('mid-flaky-detection', 1, 'Decide whether a recorded history of past results proves that a test is flaky.'),
    ('mid-flaky-detection', 2, 'A test is flaky when the history contains both a pass and a failure.'),
    ('mid-flaky-detection', 3, 'A history with only passes or only failures is not flaky.'),
    ('mid-flaky-detection', 4, 'A history with fewer than two results cannot prove flakiness.'),
    ('mid-flaky-detection', 5, 'A null entry or a null history means the result cannot be judged and is not flaky.'),
    ('senior-contract-verify', 1, 'Compare a consumer contract with the payload actually received from the provider.'),
    ('senior-contract-verify', 2, 'For each contract key missing from the payload, report "missing: <key>".'),
    ('senior-contract-verify', 3, 'For each key whose value type does not match the contract, report "type: <key> expected <contractType> but was <actualType>".'),
    ('senior-contract-verify', 4, 'The accepted type names are number, string, boolean, object and array, and a number accepts any integral or floating-point value.'),
    ('senior-contract-verify', 5, 'A missing key is reported only as missing, extra payload keys are allowed, and the report contains no duplicates.'),
    ('senior-contract-verify', 6, 'Sort the report alphabetically, and return an empty list when either map is null or empty.'),
    ('senior-mutation-score', 1, 'Interpret the outcome of a mutation testing run from its killed, survived and no-coverage mutant counts.'),
    ('senior-mutation-score', 2, 'Report the mutation score as "score N%", where N is killed divided by all mutants rounded half up to the nearest whole percent and reported as 0 percent when there are no mutants.'),
    ('senior-mutation-score', 3, 'Report "weakest: NO_COVERAGE" when there are no mutants at all or when more mutants were never covered than survived.'),
    ('senior-mutation-score', 4, 'Otherwise report "strong" when the score is at least 80 percent.'),
    ('senior-mutation-score', 5, 'Otherwise report "weakest: SURVIVED".'),
    ('senior-mutation-score', 6, 'The report always contains exactly the score line followed by the category line.'),
    ('senior-pyramid-allocation', 1, 'Split a suite of tests across the three levels of the test pyramid, keyed "unit", "integration" and "endToEnd".'),
    ('senior-pyramid-allocation', 2, 'Use the percentage split 60/30/10 by default, 70/20/10 when the code is logic heavy, 50/40/10 when it is io heavy, and 60/30/10 when both or neither flag is set.'),
    ('senior-pyramid-allocation', 3, 'Convert each percentage into a count with the largest-remainder method so the counts always sum to the total.'),
    ('senior-pyramid-allocation', 4, 'Break any remaining tie in the order unit, then integration, then endToEnd.'),
    ('senior-pyramid-allocation', 5, 'When the total is not positive every count is zero, and the map always contains all three keys.'),
    ('mid-coverage-threshold', 1, 'Return the documented minimum line-coverage threshold, as a whole percentage, for a module kind.'),
    ('mid-coverage-threshold', 2, 'A "service" module must reach 80 percent, a "controller" module 70 percent, and a "utility" module 90 percent.'),
    ('mid-coverage-threshold', 3, 'Any other module kind, including null, returns the default threshold of 60 percent.'),
    ('mid-coverage-threshold', 4, 'The module kind is matched ignoring case and surrounding whitespace.'),
    ('mid-coverage-threshold', 5, 'A threshold is never above 100 percent.'),
    ('mid-severity-mapping', 1, 'Apply the documented static analysis quality gate rules to a list of severities.'),
    ('mid-severity-mapping', 2, 'A "critical" or "vulnerability" finding anywhere in the list fails the gate with "FAIL".'),
    ('mid-severity-mapping', 3, 'Blockers fail with "FAIL" only when their count is greater than blockerThreshold, otherwise they warn.'),
    ('mid-severity-mapping', 4, '"minor" and "info" findings warn, and an empty list passes with "PASS".'),
    ('mid-severity-mapping', 5, 'An unrecognised severity, a null list or a null entry is malformed and warns with "WARN" unless a failing rule above already applies.'),
    ('mid-severity-mapping', 6, 'Severities are matched ignoring case and surrounding whitespace.'),
    ('senior-benchmark-validity', 1, 'Audit a benchmark configuration map and report every problem found, in the documented order.'),
    ('senior-benchmark-validity', 2, 'Report "missing warmup" when warmupIterations is absent or is not a positive number.'),
    ('senior-benchmark-validity', 3, 'Report "no forks" when forks is absent or below 2.'),
    ('senior-benchmark-validity', 4, 'Report "dead code elimination" when blackhole is absent or not "true".'),
    ('senior-benchmark-validity', 5, 'Report "no baseline" when baseline is absent or not "true".'),
    ('senior-benchmark-validity', 6, 'A null or empty configuration reports every problem, and values are compared ignoring case.'),
    ('senior-load-model', 1, 'Choose the load test model from how the traffic is generated.'),
    ('senior-load-model', 2, 'A bounded user pool, where maxConcurrency is 2 or more, always means "CLOSED".'),
    ('senior-load-model', 3, 'An arrival rate that is not positive or not below 100 requests per second is unusable, so the model is "CLOSED".'),
    ('senior-load-model', 4, 'With maxConcurrency at 0 and constant traffic the model is "OPEN"; without constant traffic it is "CLOSED".'),
    ('senior-load-model', 5, 'With maxConcurrency at 1 a single pacing user keeps the model "OPEN" whatever the traffic pattern.'),
    ('junior-log-level', 1, 'Map the event category "expected-failure" to WARN, because a handled failure needs attention but not a page.'),
    ('junior-log-level', 2, 'Map "unexpected-failure" to ERROR, because a human must act on it.'),
    ('junior-log-level', 3, 'Map "routine-detail" to DEBUG and "lifecycle" to INFO.'),
    ('junior-log-level', 4, 'Accept the category case-insensitively and ignore surrounding whitespace.'),
    ('junior-log-level', 5, 'Throw IllegalArgumentException for a null, blank or unknown category.'),
    ('junior-metric-name', 1, 'A valid meter name is lowercase and dot-separated with non-empty segments, for example orders.placed.'),
    ('junior-metric-name', 2, 'Report "uppercase" for any A-Z, "space" for any whitespace and "other-character" for anything outside a-z, 0-9, dot and whitespace.'),
    ('junior-metric-name', 3, 'Report "empty-segment" when the name starts or ends with a dot or contains two consecutive dots.'),
    ('junior-metric-name', 4, 'Return the labels in the order uppercase, space, other-character, empty-segment, and an empty list when the name is valid.'),
    ('junior-metric-name', 5, 'Throw IllegalArgumentException for a null or blank name.'),
    ('junior-alert-condition', 1, 'Build the condition string "<metric> > <threshold> for <window>", rendering the threshold with Double.toString so 0.05 stays 0.05.'),
    ('junior-alert-condition', 2, 'Alerts target symptoms of user impact; reject cause-based metrics: cpu, memory, heap, disk, thread and gc (matched case-insensitively anywhere in the name).'),
    ('junior-alert-condition', 3, 'Trim the metric and window; throw IllegalArgumentException for a null or blank metric or window.'),
    ('junior-alert-condition', 4, 'Throw IllegalArgumentException for a threshold that is NaN or infinite, or for a cause-based metric.'),
    ('mid-cardinality-risk', 1, 'cardinality(tagSizes) returns the product of the tag cardinalities; an empty list is a single series, so its cardinality is 1.'),
    ('mid-cardinality-risk', 2, 'A tag size of zero makes the product zero; null tags or negative sizes throw IllegalArgumentException.'),
    ('mid-cardinality-risk', 3, 'Guard against overflow: clamp the product at Long.MAX_VALUE instead of wrapping around.'),
    ('mid-cardinality-risk', 4, 'risky(tagSizes) returns true when the cardinality exceeds the documented limit of 10000 active series.'),
    ('mid-histogram-buckets', 1, 'Return eleven ascending boundaries for sloMillis: 0.5, 0.75, 0.9, 0.95, 1.0, 1.05, 1.1, 1.25, 1.5, 2.0 and 4.0 times the SLO, in that order.'),
    ('mid-histogram-buckets', 2, 'The boundaries cluster in the SLO region so percentile interpolation stays accurate at the decision line, with a coarse tail bounded at four times the SLO.'),
    ('mid-histogram-buckets', 3, 'Keep the list strictly ascending with no duplicates; the fixed count keeps series cardinality bounded.'),
    ('mid-histogram-buckets', 4, 'Throw IllegalArgumentException when sloMillis is not finite or not positive.'),
    ('mid-trace-sampling', 1, 'Sample everything at low volume: return ALWAYS_ON when requestsPerSecond is at most 10.'),
    ('mid-trace-sampling', 2, 'Above that rate, return TAIL_BASED when errorsMatter, because tail sampling can keep every error after seeing the outcome.'),
    ('mid-trace-sampling', 3, 'Otherwise return PROBABILISTIC, scaling the volume down with a head sampling ratio.'),
    ('mid-trace-sampling', 4, 'Throw IllegalArgumentException when requestsPerSecond is negative, NaN or infinite.'),
    ('mid-burn-rate-alert', 1, 'The burn rate for one window is errorBudgetConsumedFraction divided by timeWindowFraction.'),
    ('mid-burn-rate-alert', 2, 'The alert fires only when the burn rate strictly exceeds factor.'),
    ('mid-burn-rate-alert', 3, 'The consumed fraction may exceed 1 when the budget is overspent, but it must be finite and not negative.'),
    ('mid-burn-rate-alert', 4, 'timeWindowFraction must be in (0, 1] and factor must be positive and finite; otherwise throw IllegalArgumentException.'),
    ('senior-tail-sampling', 1, 'Keep a share of the error traces: ceil(errors * errorSampleRate), so an errorSampleRate of 1.0 keeps every error.'),
    ('senior-tail-sampling', 2, 'Keep a baseline sample of the non-error traces: ceil((traces - errors) * baselineRate).'),
    ('senior-tail-sampling', 3, 'The result is the two samples added together, never more than traces.'),
    ('senior-tail-sampling', 4, 'traces must not be negative, errors must be within 0..traces, and both rates must be finite and within 0..1; otherwise throw IllegalArgumentException.'),
    ('senior-incident-triage', 1, 'Triage starts from the user-visible symptom, so the first step is always confirm-user-impact, never the loudest alert.'),
    ('senior-incident-triage', 2, 'When recentChange is true, check-recent-changes comes second because most incidents follow a deploy or configuration change.'),
    ('senior-incident-triage', 3, 'Then add the active signals in this fixed order: inspect-errors, inspect-latency, inspect-saturation.'),
    ('senior-incident-triage', 4, 'When no signal is active, add widen-scope before the final step; the last step is always form-hypothesis.'),
    ('senior-slo-alert-design', 1, 'alert returns a definition map containing sli, budget, fastWindowSeconds, slowWindowSeconds, burnRateFactor and condition.'),
    ('senior-slo-alert-design', 2, 'budget is 1 - target, and the window seconds are the minute arguments multiplied by 60.'),
    ('senior-slo-alert-design', 3, 'burnRateFactor follows the documented tiers: 14.4 when slowWindowMinutes is at most 60, 6.0 when at most 360, and 1.0 otherwise.'),
    ('senior-slo-alert-design', 4, 'condition is "burnRate > <factor> over <fast>m and <slow>m", requiring both the short and the long window to breach.'),
    ('senior-slo-alert-design', 5, 'The sli must not be blank, target must be strictly between 0 and 1, and 0 < fast < slow windows; otherwise throw IllegalArgumentException.'),
    ('mid-cache-ttl', 1, 'Pick a base TTL per volatility: static 86400 seconds, slow 3600, fast 60 and realtime 1.'),
    ('mid-cache-ttl', 2, 'The TTL never exceeds acceptableStalenessSeconds, because exceeding accepted staleness breaks the consistency contract.'),
    ('mid-cache-ttl', 3, 'Within that bound, raise the TTL to at least ten times the source latency (ceil(sourceLatencyMillis / 100) seconds), since a TTL shorter than the load cost saves nothing.'),
    ('mid-cache-ttl', 4, 'The result is always at least 1 second.'),
    ('mid-cache-ttl', 5, 'Staleness must be positive and latency must not be negative; an unknown volatility throws IllegalArgumentException.'),
    ('mid-invalidation-set', 1, 'A write to entity id affects the key "<entity>:<id>" and every nested key starting with "<entity>:<id>:".'),
    ('mid-invalidation-set', 2, 'It also affects list keys equal to "<entity>-list" and keys starting with "<entity>-list:".'),
    ('mid-invalidation-set', 3, 'Return only the affected keys that are present in knownKeys; similar ids such as "<entity>:<id>0" and other entities stay untouched.'),
    ('mid-invalidation-set', 4, 'The knownKeys set must not be modified.'),
    ('mid-invalidation-set', 5, 'Throw IllegalArgumentException for a null or blank entity or id, or a null knownKeys set.'),
    ('mid-pool-sizing', 1, 'Size the pool with ceil(databaseCores * (1 + waitBudgetMillis / serviceTimeMillis)), since more waiting allows more concurrent connections.'),
    ('mid-pool-sizing', 2, 'Never return less than 2 connections, so the service can still overlap work.'),
    ('mid-pool-sizing', 3, 'Cap the pool at eight times databaseCores, because more connections than that only move the queue into the database.'),
    ('mid-pool-sizing', 4, 'databaseCores must be at least 1, serviceTimeMillis must be positive and finite, and waitBudgetMillis must be finite and not negative; otherwise throw IllegalArgumentException.'),
    ('senior-target-choice', 1, 'User-facing work always targets LATENCY, because a person waits for the response.'),
    ('senior-target-choice', 2, 'Non-user-facing batch work targets THROUGHPUT when p99BudgetMillis is more than 1000, because the wait is hidden and batching amortises fixed costs.'),
    ('senior-target-choice', 3, 'Otherwise the work targets LATENCY, because some caller still waits for it.'),
    ('senior-target-choice', 4, 'p99BudgetMillis must be finite and positive; otherwise throw IllegalArgumentException.'),
    ('senior-format-choice', 1, 'Return JSON when browserClient is true, because browsers speak JSON natively.'),
    ('senior-format-choice', 2, 'Otherwise return JSON when humanReadable is true, because operators and support can inspect the payloads.'),
    ('senior-format-choice', 3, 'Otherwise return JSON when highVolume is false, because compression and tooling cost are not justified at low volume.'),
    ('senior-format-choice', 4, 'For high-volume internal traffic return AVRO when schemaEvolution is true, because a schema registry resolves writer and reader differences; otherwise return PROTOBUF.'),
    ('senior-regression-gate', 1, 'Report the signed percentage change as "<verdict> <change>", where change is formatted with Locale.ROOT to one decimal place, for example FAIL +12.5%.'),
    ('senior-regression-gate', 2, 'The change ratio is (candidateP99 - baselineP99) / baselineP99.'),
    ('senior-regression-gate', 3, 'PASS when the change ratio is at most tolerance, WARN when it is at most twice the tolerance, and FAIL beyond that.'),
    ('senior-regression-gate', 4, 'baselineP99 must be positive, candidateP99 must not be negative, and tolerance must be finite and not negative; otherwise throw IllegalArgumentException.'),
    ('mid-error-fallback', 1, 'signals returns the pipeline trace: the operator onErrorResume first, then the signals emitted in order.'),
    ('mid-error-fallback', 2, 'A successful main sequence emits next:main then complete, and the fallback is never subscribed.'),
    ('mid-error-fallback', 3, 'A main failure emits error:main, then next:fallback and complete when a fallback value exists.'),
    ('mid-error-fallback', 4, 'When the fallback is empty the error is replaced by an empty completion: error:main then complete.'),
    ('mid-backpressure-policy', 1, 'Return BUFFER when mustBeLossless is true, regardless of the other flags.'),
    ('mid-backpressure-policy', 2, 'Otherwise return ERROR when canDrop is false, because no drop policy is acceptable.'),
    ('mid-backpressure-policy', 3, 'Otherwise return DROP_OLDEST for a slow consumer and DROP_LATEST for a fast one.'),
    ('mid-backpressure-policy', 4, 'The result is always one of BUFFER, DROP_OLDEST, DROP_LATEST or ERROR.'),
    ('mid-scheduler-choice', 1, 'Map "cpu" to parallel, "blocking" to boundedElastic, "legacy" to elastic, "single" to single, and "immediate" to immediate.'),
    ('mid-scheduler-choice', 2, 'Matching is case-insensitive and ignores surrounding whitespace.'),
    ('mid-scheduler-choice', 3, 'Throw IllegalArgumentException for a null or unknown workload.'),
    ('mid-context-value', 1, 'Reactor Context is immutable and scoped to the subscription that wrote it, so a reader sees only its own keys.'),
    ('mid-context-value', 2, 'Return true when contextKeys contains readerKey using an exact, case-sensitive match.'),
    ('mid-context-value', 3, 'Return false for a null key, a null set, or a key that is not present.'),
    ('senior-blocking-detect', 1, 'Scan the pipeline listing and treat each entry as one line, numbered from 1.'),
    ('senior-blocking-detect', 2, 'A line is flagged when it contains any blocking token: Thread.sleep(, .block(, .blockFirst(, .blockLast( or awaitTermination(, matched case-sensitively.'),
    ('senior-blocking-detect', 3, 'A line whose trimmed text starts with // is a comment and is never flagged, and a flagged line is reported only once.'),
    ('senior-blocking-detect', 4, 'Return the flagged line numbers in ascending order, and throw IllegalArgumentException for a null list or a null element.'),
    ('senior-reactive-or-thread', 1, 'Return "reactive" when the source is a stream, because cancellation and flow control are part of the contract.'),
    ('senior-reactive-or-thread', 2, 'Otherwise return "reactive" only for an I/O-bound call with a fanOut of at least 1000 when the team already knows Reactor.'),
    ('senior-reactive-or-thread', 3, 'Otherwise return "virtual-threads": request-response I/O gains little from reactive types, and CPU-bound or unfamiliar teams should stay imperative.'),
    ('senior-reactive-or-thread', 4, 'Throw IllegalArgumentException for a negative fanOut.'),
    ('senior-streaming-backpressure', 1, 'Return the demand actually requested: the smaller of consumerDemand and the remaining capacity limit - buffered.'),
    ('senior-streaming-backpressure', 2, 'A demand of zero or less, or a full or overfull buffer, results in 0; the result is never negative.'),
    ('senior-streaming-backpressure', 3, 'Throw IllegalArgumentException for a negative buffered count or a negative limit.'),
    ('junior-dockerfile-order', 1, 'A dependency-resolution instruction is a RUN instruction mentioning dependency or go-offline, ignoring case.'),
    ('junior-dockerfile-order', 2, 'A source copy is a COPY or ADD instruction whose source operand is . or begins with src.'),
    ('junior-dockerfile-order', 3, 'Each dependency-resolution instruction after the first source copy moves to just before that copy, keeping relative order.'),
    ('junior-dockerfile-order', 4, 'Other instructions keep their relative order, the input list is never modified, and null or empty input gives an empty list.'),
    ('junior-env-injection', 1, 'Convert every configuration key to its environment variable form: upper case with dots and dashes replaced by underscores.'),
    ('junior-env-injection', 2, 'Copy values unchanged and skip entries whose key is null.'),
    ('junior-env-injection', 3, 'A null or empty config returns an empty map.'),
    ('junior-env-injection', 4, 'The map is keyed only by the converted name; the original key is not emitted.'),
    ('junior-probe-choice', 1, 'Return STARTUP when the purpose contains startup or boot, case-insensitively.'),
    ('junior-probe-choice', 2, 'Return READINESS when the purpose contains readiness, ready, or traffic.'),
    ('junior-probe-choice', 3, 'Return LIVENESS when the purpose contains liveness, alive, restart, or deadlock.'),
    ('junior-probe-choice', 4, 'Return NONE for null, blank, or unrecognised purposes; check STARTUP first, then READINESS, then LIVENESS.'),
    ('mid-resource-limits', 1, 'The memory limit is the heap plus 25 percent overhead headroom, rounded up to a whole mebibyte, suffixed Mi.'),
    ('mid-resource-limits', 2, 'The CPU request is the core count multiplied by one thousand millicores, suffixed m.'),
    ('mid-resource-limits', 3, 'Return exactly the keys memory and cpu, and throw IllegalArgumentException when heapMb or cores is below one.'),
    ('mid-hpa-target', 1, 'Choose QUEUE_DEPTH for a queue consumer, because backlog is the most direct signal.'),
    ('mid-hpa-target', 2, 'Otherwise choose P95_LATENCY for a latency sensitive service.'),
    ('mid-hpa-target', 3, 'Otherwise choose CPU_UTILIZATION for a cpu bound service.'),
    ('mid-hpa-target', 4, 'Otherwise choose REQUESTS_PER_SECOND; check in the order queue, latency, cpu, throughput.'),
    ('mid-config-merge', 1, 'Entries prefixed secret: are secrets; the prefix is stripped and the remaining name is the output key.'),
    ('mid-config-merge', 2, 'Later layers win for plain keys, and a secret always beats a plain value for the same name even if the secret came earlier.'),
    ('mid-config-merge', 3, 'A later secret beats an earlier secret.'),
    ('mid-config-merge', 4, 'Skip null layers and null keys; a null layer list returns an empty map.'),
    ('mid-shutdown-grace', 1, 'The needed grace is longestRequestSeconds plus drainSeconds.'),
    ('mid-shutdown-grace', 2, 'Return the smaller of the needed grace and terminationGraceSeconds, so the value always fits the pod termination budget.'),
    ('mid-shutdown-grace', 3, 'Throw IllegalArgumentException when any argument is negative, when terminationGraceSeconds is not positive, or when the sum overflows an int.'),
    ('senior-image-reduction', 1, 'Report, in this fixed order: use a multi-stage build when multiStage is false and build tools are present in the runtime image.'),
    ('senior-image-reduction', 2, 'Report use a JRE base image when the base image name contains jdk or says openjdk without jre.'),
    ('senior-image-reduction', 3, 'Report use a slim base image when the base image is not slim, alpine, or distroless.'),
    ('senior-image-reduction', 4, 'Never repeat a measure; a null base image still reports boolean-driven findings.'),
    ('senior-pod-security', 1, 'Treat a null security context as unsafe and report all three checks: runAsNonRoot, privileged, readOnlyRootFilesystem.'),
    ('senior-pod-security', 2, 'Report runAsNonRoot when runAsNonRoot is not true and runAsUser is missing, zero, or negative.'),
    ('senior-pod-security', 3, 'Report privileged unless privileged is exactly false, and readOnlyRootFilesystem unless it is exactly true.'),
    ('senior-pod-security', 4, 'Report violations in the fixed order runAsNonRoot, privileged, readOnlyRootFilesystem, never repeating one.'),
    ('senior-rollout-strategy', 1, 'A breaking api change uses BLUE_GREEN so both versions can run side by side during cutover.'),
    ('senior-rollout-strategy', 2, 'A release with fewer than three replicas also uses BLUE_GREEN, since there is no spare capacity for a canary.'),
    ('senior-rollout-strategy', 3, 'A schema change with at least three replicas uses CANARY so the new version is sampled and can be rolled back quickly.'),
    ('senior-rollout-strategy', 4, 'Everything else uses ROLLING; throw IllegalArgumentException when replicas is below one.'),
    ('junior-secret-source', 1, 'Production always uses a managed secret store; never source control.'),
    ('junior-secret-source', 2, 'A short-lived credential outside production uses workload identity so nothing long-lived is stored.'),
    ('junior-secret-source', 3, 'Local development uses environment variables, taking priority over the short-lived rule.'),
    ('junior-secret-source', 4, 'Any other non-production deployment reads mounted files.'),
    ('junior-release-tag', 1, 'Accept an optional v prefix followed by exactly three dot-separated numeric components, optionally followed by +build metadata.'),
    ('junior-release-tag', 2, 'Return a map with key version holding the numeric version and key build holding metadata or an empty string.'),
    ('junior-release-tag', 3, 'Reject malformed tags, pre-release suffixes, and empty build metadata by returning an empty map.'),
    ('junior-parity-check', 1, 'Report every key whose deployed value differs from the local value, missing keys included.'),
    ('junior-parity-check', 2, 'Parity is symmetric: a key present in only one side is also a difference.'),
    ('junior-parity-check', 3, 'Sort the reported keys alphabetically and never repeat one.'),
    ('junior-parity-check', 4, 'Treat a null map as empty, so only the other side''s keys are reported.'),
    ('mid-pipeline-gate', 1, 'Always order gates compile, unit tests, then integration tests when they exist, then package, then security scan when required.'),
    ('mid-pipeline-gate', 2, 'Never include a gate that was not requested.'),
    ('mid-pipeline-gate', 3, 'Return every requested gate exactly once, cheapest and most critical first.'),
    ('mid-canary-percent', 1, 'The baseline percentage is ten, reduced to five for a high risk rollout.'),
    ('mid-canary-percent', 2, 'Raise the percentage only as needed so that the population times the percentage covers the minimum sample, rounded up.'),
    ('mid-canary-percent', 3, 'Never return below one or above one hundred; throw IllegalArgumentException when totalUsers or minimumSample is below one.'),
    ('mid-flag-evaluation', 1, 'The kill switch wins over everything: when killSwitch is true the flag is disabled for every user.'),
    ('mid-flag-evaluation', 2, 'Otherwise a user on the allowlist is enabled even at zero percent, and a null user is disabled.'),
    ('mid-flag-evaluation', 3, 'Otherwise the user is bucketed with Math.floorMod(userId.hashCode(), 100) and enabled when the bucket is below rolloutPercent.'),
    ('mid-flag-evaluation', 4, 'The evaluation must be deterministic and stable across calls for the same inputs.'),
    ('mid-autoscale-signal', 1, 'Choose QUEUE_BACKLOG for a service whose work arrives on a queue, because backlog is the most direct signal.'),
    ('mid-autoscale-signal', 2, 'Otherwise choose REQUEST_LATENCY for a latency sensitive service, because it reflects the user experience.'),
    ('mid-autoscale-signal', 3, 'Otherwise choose CPU_UTILIZATION for a cpu bound service.'),
    ('mid-autoscale-signal', 4, 'Otherwise choose CONCURRENCY; check in the order queue, latency, cpu, concurrency.'),
    ('senior-database-compatibility', 1, 'An additive migration such as ADD COLUMN, CREATE TABLE, or CREATE INDEX keeps the old application version working.'),
    ('senior-database-compatibility', 2, 'Flag any statement containing DROP, TRUNCATE, or RENAME, case-insensitively, because it breaks the old version.'),
    ('senior-database-compatibility', 3, 'Return the offending statements in input order, skipping null or blank entries; a null list returns an empty list.'),
    ('senior-cost-triage', 1, 'Action per area: idle is recoverable at 95 percent, logging 60, egress 50, storage 40, compute 35, and any other area 20.'),
    ('senior-cost-triage', 2, 'Order actions by recoverable spend, the largest first; break ties by the higher recoverable percentage, then by area name alphabetically.'),
    ('senior-cost-triage', 3, 'Ignore areas whose spend is null, zero, or negative.'),
    ('senior-cost-triage', 4, 'Action text is shut down idle environments, reduce log retention and volume, compress and cache cross-region traffic, apply storage lifecycle policies, right-size compute instances, or investigate <area> spend.'),
    ('senior-iac-drift', 1, 'Report each attribute that appears only in the actual infrastructure as added <key>.'),
    ('senior-iac-drift', 2, 'Report each attribute that appears only in the desired configuration as removed <key>.'),
    ('senior-iac-drift', 3, 'Report each attribute present in both with different values as changed <key>.'),
    ('senior-iac-drift', 4, 'Return the lines sorted alphabetically; treat a null map as empty, and an empty list when there is no drift.'),
    ('lead-delivery-standard', 1, 'Always order the base practices: require automated tests to pass before merge, deploy only through a reviewed pipeline, release progressively with automatic rollback, then observe release health before increasing traffic.'),
    ('lead-delivery-standard', 2, 'When more than one service is owned, add define a service owner for each service after the base practices.'),
    ('lead-delivery-standard', 3, 'When regulated, add retain an auditable release record then sign build artifacts, after any ownership practice.'),
    ('lead-delivery-standard', 4, 'Never repeat a practice; throw IllegalArgumentException when servicesOwned is below one.'),
    ('lead-secret-rotation', 1, 'Always create the new secret version first and revoke the old version last, only after verifying consumers.'),
    ('lead-secret-rotation', 2, 'When the store supports dual write, keep both versions valid during the overlap; otherwise update all consumers before activating the new version.'),
    ('lead-secret-rotation', 3, 'Roll the new version out in batches when there is more than one consumer, otherwise roll it out to the single consumer.'),
    ('lead-secret-rotation', 4, 'Throw IllegalArgumentException when consumers is below one; every sequence has exactly five unique steps.'),
    ('junior-password-strength', 1, 'A null password or one shorter than 8 characters is WEAK.'),
    ('junior-password-strength', 2, 'Character classes are lowercase, uppercase, digit and symbol, where a symbol is any character that is neither a letter nor a digit.'),
    ('junior-password-strength', 3, '12 or more characters with at least 3 classes is STRONG.'),
    ('junior-password-strength', 4, '10 or more characters with at least 2 classes is GOOD; everything else that is not WEAK is FAIR.'),
    ('junior-password-strength', 5, 'Return exactly one of WEAK, FAIR, GOOD or STRONG.'),
    ('junior-secret-detection', 1, 'A line is a finding when it assigns a value to one of the keys password, token, apiKey (or api_key) or secret, matched case-insensitively.'),
    ('junior-secret-detection', 2, 'The key must be followed by = or : and then a non-empty value; an empty value or an empty string literal is not a finding.'),
    ('junior-secret-detection', 3, 'Values taken from the environment, such as System.getenv(...), are not findings.'),
    ('junior-secret-detection', 4, 'Lines whose first non-space characters are // or # are comments and are never findings.'),
    ('junior-secret-detection', 5, 'Return "line <n>: <key>" for each finding, using the 1-based line number and the canonical key name, where api_key becomes apiKey.'),
    ('junior-secret-detection', 6, 'A null list or a null line yields no finding for that position.'),
    ('junior-header-hardening', 1, 'Always set X-Content-Type-Options to nosniff, X-Frame-Options to DENY, Referrer-Policy to no-referrer and Content-Security-Policy to default-src ''self''.'),
    ('junior-header-hardening', 2, 'Send Strict-Transport-Security with the value max-age=31536000; includeSubDomains only when httpsOnly is true, because HSTS must never be sent over plain HTTP.'),
    ('junior-header-hardening', 3, 'The returned map contains exactly those headers and nothing else.'),
    ('junior-input-sanitise', 1, 'Return an empty string for a null input.'),
    ('junior-input-sanitise', 2, 'Treat any run of whitespace or control characters (Character.isWhitespace or Character.isISOControl) as a single space.'),
    ('junior-input-sanitise', 3, 'Remove leading and trailing spaces so the result never starts or ends with a space and never contains two spaces in a row.'),
    ('junior-input-sanitise', 4, 'Keep every other character exactly as it is.'),
    ('mid-parameterised-query', 1, 'Report unsafe query building patterns found in the SQL template text.'),
    ('mid-parameterised-query', 2, 'A + character anywhere in the text means the query is assembled by string concatenation.'),
    ('mid-parameterised-query', 3, 'An ORDER BY clause followed before ; or the next ORDER BY by any of ? '' " ( + % or $ is unsafe interpolation.'),
    ('mid-parameterised-query', 4, 'The markers -- or /* anywhere in the text are comment injection markers.'),
    ('mid-parameterised-query', 5, 'Return each kind at most once, ordered by where it first appears; a null or blank input has no violations.'),
    ('mid-output-encoding', 1, 'Return an empty string when value is null.'),
    ('mid-output-encoding', 2, 'Escape & as &amp;, < as &lt; and > as &gt; using these named entities.'),
    ('mid-output-encoding', 3, 'Escape the double quote as &quot; and the single quote as &#39;.'),
    ('mid-output-encoding', 4, 'Leave every other character unchanged and escape each character exactly once.'),
    ('mid-csrf-token-check', 1, 'GET, HEAD, OPTIONS and TRACE are safe methods and always pass, even without tokens.'),
    ('mid-csrf-token-check', 2, 'Every other method, including an unknown or null method, is state changing and requires a session token and a request token that are equal and not blank.'),
    ('mid-csrf-token-check', 3, 'Compare the tokens without early exit, for example with MessageDigest.isEqual.'),
    ('mid-csrf-token-check', 4, 'Method names are compared case-insensitively.'),
    ('mid-jwt-validation', 1, 'A missing, blank or "none" alg, matched case-insensitively, is a violation: "alg none is not allowed".'),
    ('mid-jwt-validation', 2, 'exp must be a numeric claim; when it is missing or not a number report "exp is required", and when exp is less than or equal to the current time report "token is expired".'),
    ('mid-jwt-validation', 3, 'sub must be a non-blank string, otherwise report "sub is required".'),
    ('mid-jwt-validation', 4, 'Return the violations in the order alg, exp, sub; a valid token returns an empty list.'),
    ('mid-scope-check', 1, 'An empty or null required list is always permitted.'),
    ('mid-scope-check', 2, 'A null or empty granted set permits nothing unless required is also empty.'),
    ('mid-scope-check', 3, 'requireAll true demands every required scope; requireAll false demands at least one.'),
    ('mid-scope-check', 4, 'Scopes match exactly and case-sensitively; there is no wildcard expansion.'),
    ('senior-crypto-choice', 1, 'Map password-storage to hashing, which means a salted, slow password hash such as Argon2 or bcrypt.'),
    ('senior-crypto-choice', 2, 'Map data-at-rest to symmetric encryption, which means an authenticated mode such as AES-GCM.'),
    ('senior-crypto-choice', 3, 'Map message-integrity to MAC, such as HMAC-SHA-256, and session-key to key exchange, such as X25519 or ECDH.'),
    ('senior-crypto-choice', 4, 'Any other purpose, including null and different casing, throws IllegalArgumentException.'),
    ('senior-key-rotation', 1, 'The active key version returns "encrypt and decrypt" because only the active key may encrypt.'),
    ('senior-key-rotation', 2, 'The retainVersions most recent older versions return "decrypt only" so older data can still be read, counting back from the active version.'),
    ('senior-key-rotation', 3, 'Keys older than that window return "retired" and must never be used.'),
    ('senior-key-rotation', 4, 'A keyVersion ahead of activeVersion, a version below 1 or a retainVersions below 1 throws IllegalArgumentException.'),
    ('senior-audit-events', 1, 'Every audit entry must have a non-blank actor, action, target and timestamp; report "missing <field>" for each absent or blank field.'),
    ('senior-audit-events', 2, 'Report the missing fields in the order actor, action, target, timestamp.'),
    ('senior-audit-events', 3, 'An entry must never carry secret material; when any key is password, token, secret, apiKey, api_key or credential, matched case-insensitively, report "secret material must not be logged".'),
    ('senior-audit-events', 4, 'The secret finding always comes after the missing-field findings; a complete entry returns an empty list.'),
    ('senior-sbom-gate', 1, 'Return FAIL when any finding is marked reachable and its severity is greater than or equal to the severityThreshold.'),
    ('senior-sbom-gate', 2, 'Return WARN when there are findings but none is a reachable finding at or above the threshold, and PASS when there are no findings at all.'),
    ('senior-sbom-gate', 3, 'Severity is read from the severity key as a number; a missing or non-numeric severity counts as 0.'),
    ('senior-sbom-gate', 4, 'Only Boolean.TRUE under the reachable key counts as reachable.'),
    ('senior-sbom-gate', 5, 'The severityThreshold must be between 1 and 10 inclusive, otherwise IllegalArgumentException.'),
    ('principal-threat-model', 1, 'Recognise the six STRIDE categories spoofing, tampering, repudiation, information disclosure, denial of service and elevation of privilege, matched case-insensitively after trimming.'),
    ('principal-threat-model', 2, 'Spoofing returns "authenticate every principal before it acts", tampering returns "verify integrity of data in transit and at rest" and repudiation returns "record tamper-evident audit logs of privileged actions".'),
    ('principal-threat-model', 3, 'Information disclosure returns "encrypt sensitive data and enforce least privilege access", denial of service returns "apply rate limits, quotas and timeouts" and elevation of privilege returns "authorise every request against least privilege roles".'),
    ('principal-threat-model', 4, 'Return each mitigation at most once in risk order: elevation of privilege, information disclosure, spoofing, tampering, denial of service, repudiation.'),
    ('principal-threat-model', 5, 'Ignore unrecognised entries; a null or empty list returns an empty list.'),
    ('principal-security-policy', 1, 'Every organisation adopts, in this order: assign a security owner for every system, require two-person review for production changes, keep an incident response runbook up to date.'),
    ('principal-security-policy', 2, 'When regulatedData is true append "classify and retain regulated data under the data policy" and then "encrypt regulated data at rest and in transit".'),
    ('principal-security-policy', 3, 'When publicApi is true append "authenticate and rate limit every public endpoint".'),
    ('principal-security-policy', 4, 'When teamCount is 3 or more append "run a quarterly access review"; when it is 10 or more also append "fund a dedicated security engineering function".'),
    ('principal-security-policy', 5, 'A negative teamCount throws IllegalArgumentException.'),
    ('junior-json-field-read', 1, 'Resolve a dot-separated path into a JSON object and return the string value it points at as an Optional.'),
    ('junior-json-field-read', 2, 'Only string values are returned: numbers, booleans, null, arrays and objects all yield Optional.empty().'),
    ('junior-json-field-read', 3, 'A missing key, a path that traverses a non-object, or malformed JSON yields Optional.empty().'),
    ('junior-json-field-read', 4, 'A null or empty json or path yields Optional.empty(); standard JSON string escapes are decoded.'),
    ('junior-csv-row-parse', 1, 'Split the row on commas; a field that starts with a double quote is quoted and may contain commas.'),
    ('junior-csv-row-parse', 2, 'Inside a quoted field two double quotes decode to one literal quote; everything else is taken literally.'),
    ('junior-csv-row-parse', 3, 'Empty fields are preserved, fields are not trimmed, and a double quote only starts a quoted field at the start of that field.'),
    ('junior-csv-row-parse', 4, 'An unterminated quoted field, or any text after a closing quote other than a comma, throws IllegalArgumentException.'),
    ('junior-csv-row-parse', 5, 'A null row throws IllegalArgumentException.'),
    ('junior-yaml-flatten', 1, 'Flatten nested maps into dot-separated keys, joining each path with a period.'),
    ('junior-yaml-flatten', 2, 'String values are copied verbatim, and booleans and numbers are stringified with String.valueOf.'),
    ('junior-yaml-flatten', 3, 'Entries whose value is null are skipped, as are empty nested maps.'),
    ('junior-yaml-flatten', 4, 'Only nested maps and scalar values are supported: a list value throws IllegalArgumentException, as do a null map or a null key.'),
    ('mid-polymorphic-write', 1, 'Return a new map whose first entry is the discriminator "type" mapped to the given type, followed by every body entry in order.'),
    ('mid-polymorphic-write', 2, 'The input body must not be mutated, and the discriminator must survive a copy of the returned envelope.'),
    ('mid-polymorphic-write', 3, 'A body that already contains a "type" key, a null type or a null body throws IllegalArgumentException.'),
    ('mid-format-compatibility', 1, 'BACKWARD means the new reader can read all old data: after contains every field of before, and adding fields is the typical case.'),
    ('mid-format-compatibility', 2, 'FORWARD means the old reader can read new data: before contains every field of after, which is what removing fields produces.'),
    ('mid-format-compatibility', 3, 'When both directions hold the sets are equal and the result is FULL; when neither holds the result is BREAKING.'),
    ('mid-format-compatibility', 4, 'A field listed in required must appear in both before and after, otherwise the change is BREAKING.'),
    ('mid-format-compatibility', 5, 'A null set counts as empty, and a null field name inside any set throws IllegalArgumentException.'),
    ('mid-number-precision', 1, 'Render the BigDecimal as a plain string that preserves its declared scale, including trailing zeros.'),
    ('mid-number-precision', 2, 'The output must never use exponent notation, so values such as 1E+2 render as 100 and 1E-3 as 0.001.'),
    ('mid-number-precision', 3, 'A null value renders as an empty string.'),
    ('mid-datetime-format', 1, 'Format the instant in UTC as ISO-8601 with seconds precision, for example 2024-01-02T03:04:05Z.'),
    ('mid-datetime-format', 2, 'Any sub-second precision is truncated, not rounded, and the trailing Z marks UTC.'),
    ('mid-datetime-format', 3, 'A null instant yields an empty string.'),
    ('senior-deserialisation-safety', 1, 'Return the sorted violation codes for a class requested during deserialisation.'),
    ('senior-deserialisation-safety', 2, '"native-serialization" flags any class in the java.io namespace, even when that package is allowlisted.'),
    ('senior-deserialisation-safety', 3, '"dangerous-gadget" flags known gadget classes such as javax.naming.InitialContext and com.sun.rowset.JdbcRowSetImpl, even inside an allowed package.'),
    ('senior-deserialisation-safety', 4, '"package-not-allowed" flags a class whose package is not the allowlist entry itself or one of its subpackages; the default package is never allowed.'),
    ('senior-deserialisation-safety', 5, 'An empty list means the class is safe to resolve, and a null class name throws IllegalArgumentException.'),
    ('senior-streaming-parse', 1, 'Reassemble records separated by a single newline character across chunk boundaries, returning them in order.'),
    ('senior-streaming-parse', 2, 'A trailing record without a final newline is emitted, while empty lines are skipped and never returned.'),
    ('senior-streaming-parse', 3, 'No single record may exceed maxChunkBytes: a longer record throws IllegalArgumentException, as does a limit below 1.'),
    ('senior-streaming-parse', 4, 'A null chunk list, a null chunk element, or a null element in the list throws IllegalArgumentException.'),
    ('junior-reverse-array', 1, 'Reverse the array in place so the first element becomes the last and vice versa.'),
    ('junior-reverse-array', 2, 'Do nothing for a null, empty, or single-element array.'),
    ('junior-reverse-array', 3, 'The method returns nothing; only the array contents change.'),
    ('junior-reverse-array', 4, 'Move each element at most once, using O(1) extra space.'),
    ('junior-find-maximum', 1, 'Return the largest value in the array, or OptionalInt.empty() for null or empty input.'),
    ('junior-find-maximum', 2, 'An array with a single element returns that element.'),
    ('junior-find-maximum', 3, 'Duplicate maximum values must not change the result; negative values and Integer.MIN_VALUE are supported.'),
    ('junior-find-maximum', 4, 'The input array must not be modified.'),
    ('junior-count-occurrences', 1, 'Return how many entries in the list equal the target.'),
    ('junior-count-occurrences', 2, 'A null target matches nothing, even when the list contains null entries.'),
    ('junior-count-occurrences', 3, 'Skip null entries in the list rather than throwing; return zero for a null list.'),
    ('junior-count-occurrences', 4, 'Comparison is case-sensitive.'),
    ('junior-remove-duplicates', 1, 'Return the number of distinct values in an ascending sorted array.'),
    ('junior-remove-duplicates', 2, 'Compact the distinct values into the front of the array in place, in ascending order.'),
    ('junior-remove-duplicates', 3, 'Return zero for null or empty input without throwing.'),
    ('junior-remove-duplicates', 4, 'Ignore the values beyond the returned count; do not create a new array.'),
    ('junior-sort-by-key', 1, 'Return a new list sorted by string length in ascending order.'),
    ('junior-sort-by-key', 2, 'The sort must be stable: strings of equal length keep their original relative order.'),
    ('junior-sort-by-key', 3, 'Null elements sort after every non-null element, and nulls among themselves keep their original order.'),
    ('junior-sort-by-key', 4, 'Return an empty list for null or empty input; never modify the input list.'),
    ('mid-two-sum', 1, 'Return the indices of the first pair of values that add up to the target, smaller index first.'),
    ('mid-two-sum', 2, 'The first pair is the one with the smallest second index, and among those the smallest first index; an element may not be used twice.'),
    ('mid-two-sum', 3, 'Return an empty array when no pair exists, and for null or arrays shorter than two.'),
    ('mid-two-sum', 4, 'Handle negative and large values without integer overflow.'),
    ('mid-sliding-window', 1, 'Return the largest sum of any contiguous window of exactly the requested size.'),
    ('mid-sliding-window', 2, 'Solve it in a single pass using O(1) extra space, not by re-summing every window.'),
    ('mid-sliding-window', 3, 'Return zero when the window is not positive, larger than the array, or the input is null or empty.'),
    ('mid-sliding-window', 4, 'Negative values are allowed and the window must always contain exactly that many elements.'),
    ('mid-lru-cache', 1, 'Implement a fixed-capacity least-recently-used cache with get, put and size.'),
    ('mid-lru-cache', 2, 'get returns the cached value or null for a missing key, and marks the entry as most recently used.'),
    ('mid-lru-cache', 3, 'put inserts or updates an entry and marks it as most recently used, evicting the least recently used entry when the cache is full.'),
    ('mid-lru-cache', 4, 'size reports the number of live entries; constructing with a non-positive capacity throws IllegalArgumentException.'),
    ('mid-lru-cache', 5, 'Updating an existing key must not change the size, and it makes that key the most recently used entry.'),
    ('mid-top-k-frequent', 1, 'Return at most k words ordered by descending frequency, breaking ties by natural string order.'),
    ('mid-top-k-frequent', 2, 'Count only non-null words; null entries in the input are skipped.'),
    ('mid-top-k-frequent', 3, 'Return an empty list when k is not positive or when the input is null or empty.'),
    ('mid-top-k-frequent', 4, 'When k exceeds the number of distinct words, return every distinct word.'),
    ('mid-graph-bfs', 1, 'Return the nodes reachable from the start node in breadth-first order, including the start itself.'),
    ('mid-graph-bfs', 2, 'Visit the neighbours of each node in natural string order so the result is deterministic.'),
    ('mid-graph-bfs', 3, 'Tolerate cycles and repeated edges; every node appears at most once.'),
    ('mid-graph-bfs', 4, 'Return an empty list when the graph is null or empty or the start is missing or null; skip null neighbours.'),
    ('mid-merge-intervals', 1, 'Merge all overlapping or touching intervals and return them sorted by start.'),
    ('mid-merge-intervals', 2, 'Intervals that merely touch at an endpoint, such as [1,4] and [4,5], count as overlapping and must be combined.'),
    ('mid-merge-intervals', 3, 'Handle unsorted input, nested intervals and duplicates; the input list must not be modified.'),
    ('mid-merge-intervals', 4, 'Return an empty list for null or empty input.'),
    ('senior-dijkstra', 1, 'Compute the shortest distance from the source to every reachable node using only non-negative edge weights.'),
    ('senior-dijkstra', 2, 'The result includes the source itself with distance zero and omits nodes that cannot be reached.'),
    ('senior-dijkstra', 3, 'Skip edges that are null or have a non-positive weight; tolerate cycles.'),
    ('senior-dijkstra', 4, 'Return an empty map when the graph or source is null, the graph is empty, or the source node is absent.'),
    ('senior-knapsack', 1, 'Return the greatest total value achievable with items whose total weight does not exceed the capacity.'),
    ('senior-knapsack', 2, 'Each item can be used at most once, and items heavier than the capacity are simply skipped.'),
    ('senior-knapsack', 3, 'Return zero when the arrays have different lengths, either array is null, or the capacity is not positive.'),
    ('senior-knapsack', 4, 'An empty item list yields zero.'),
    ('senior-lru-threadsafe', 1, 'Implement a thread-safe fixed-capacity least-recently-used cache with get, put and size.'),
    ('senior-lru-threadsafe', 2, 'get and put are atomic with respect to each other, and size never exceeds the capacity, even under concurrent access.'),
    ('senior-lru-threadsafe', 3, 'get returns the cached value or null for a missing key, and marks the entry as most recently used; put inserts or updates and makes the entry most recently used.'),
    ('senior-lru-threadsafe', 4, 'Evict the least recently used entry when a put would exceed the capacity.'),
    ('senior-lru-threadsafe', 5, 'Constructing with a non-positive capacity throws IllegalArgumentException.'),
    ('junior-guard-clause', 1, 'Return the maximum depth of any if statement in the listing, where the depth of an if is one plus the number of enclosing blocks that are still open when the if is reached.'),
    ('junior-guard-clause', 2, 'A line whose first non-space character is } closes the innermost open block before the rest of the line is read, so an else if continuation of a closed block is measured at the outer depth.'),
    ('junior-guard-clause', 3, 'A null or blank line is skipped, and a null list or a listing without if statements has depth zero.'),
    ('junior-method-extraction', 1, 'A method is worth extracting when it mixes two or more distinct responsibilities, when it is longer than twenty lines, or when it uses eight or more local variables.'),
    ('junior-method-extraction', 2, 'A method of six lines or fewer is never extracted, even when the responsibility count, the length or the variable count signal extraction.'),
    ('junior-method-extraction', 3, 'When the method has seven or more lines, any one of the three signals is enough on its own: two or more responsibilities, more than twenty lines, or eight or more used variables.'),
    ('junior-method-extraction', 4, 'Otherwise a single responsibility, twenty lines or fewer and seven used variables or fewer leave the method in place.'),
    ('mid-duplication-detect', 1, 'Normalise each line by trimming surrounding space, lower casing it and dropping blank or null lines entirely; only the remaining lines take part in comparison.'),
    ('mid-duplication-detect', 2, 'Compare every window of minimumLines consecutive remaining lines with every later window of the same size, and mark a window as duplicated when the normalised lines are equal.'),
    ('mid-duplication-detect', 3, 'Report one region per run of consecutive duplicated window starts, using the 1-based line numbers of the first and last source lines covered by the run, such as "1-4"; a blank line inside the region is included in its range.'),
    ('mid-duplication-detect', 4, 'Report each region once, and sort the regions by their start line.'),
    ('mid-duplication-detect', 5, 'Return an empty list for a null list, a minimumLines below 1, or a listing with no duplicated window.'),
    ('mid-strategy-extraction', 1, 'Return one handler method name per case key of switchCases, keeping the original keys.'),
    ('mid-strategy-extraction', 2, 'The handler name is "ship" followed by the key converted to camel case: split the key on underscores, hyphens and other non-alphanumeric characters, lower case each word and capitalise the first letter of each following word.'),
    ('mid-strategy-extraction', 3, 'A null or blank key, and a null or blank switchCases, produce no handler.'),
    ('mid-strategy-extraction', 4, 'Never copy branch text from the map values into the handler name.'),
    ('mid-test-seam', 1, 'A seam is a line that makes a unit hard to test: a direct object creation with new, a static call or a read of the clock.'),
    ('mid-test-seam', 2, 'Report each seam as "<line>: <kind> <name>" with the 1-based line number, where the kind is "direct constructor" or "static call" and the name is the created class or called method, such as new PaymentClient() giving PaymentClient.'),
    ('mid-test-seam', 3, 'A clock read reports the kind "clock read" with no name whenever the line mentions System.currentTimeMillis, System.nanoTime, Clock.systemUTC or Instant.now.'),
    ('mid-test-seam', 4, 'Clock reads take precedence over other seams on the same line, System class calls such as System.out.println are not seams, and string literals are ignored.'),
    ('mid-test-seam', 5, 'Report seams in line order and include every seam on a line; null or blank lines and a null list have no seams.'),
    ('mid-legacy-risk', 1, 'Classify risk as HIGH, MEDIUM or LOW from complexity, testCoveragePercent and hasRecentIncidents.'),
    ('mid-legacy-risk', 2, 'Complexity above 20 is high risk, complexity above 10 up to 20 is medium risk, and complexity of 10 or less is low risk.'),
    ('mid-legacy-risk', 3, 'Test coverage below 50 percent raises the risk one level and coverage below 25 percent raises it two levels.'),
    ('mid-legacy-risk', 4, 'Any recent incident makes the risk high.'),
    ('mid-legacy-risk', 5, 'Coverage and incidents only ever raise the risk, never lower it, so complexity 3 with 20 percent coverage is HIGH while complexity 3 with 50 percent coverage is LOW.'),
    ('senior-characterisation', 1, 'Return a deterministic list of characterisation cases for the given inputs, always starting with the fixed cases.'),
    ('senior-characterisation', 2, 'The fixed cases include "case: whitespace only" and the legacy quirks "legacy: null text returns empty", "legacy: trailing spaces preserved", "legacy: mixed case preserved", "legacy: negative number not rejected" and "legacy: tabs treated as blank".'),
    ('senior-characterisation', 3, 'Each supplied input adds "input: <value>" in order, and every blank input adds the single case "empty" instead.'),
    ('senior-characterisation', 4, 'An input of one character adds "boundary: single char", an input longer than 255 characters adds "boundary: long input", an input of exactly 255 characters adds "boundary: 255 chars" and exactly 256 characters adds "boundary: 256 chars".'),
    ('senior-characterisation', 5, 'A null list behaves like an empty list, and repeated calls with the same inputs return the same cases.'),
    ('senior-module-extraction', 1, 'moduleDeps maps every module to the set of modules it depends on.'),
    ('senior-module-extraction', 2, 'Return the modules in an order that extracts leaves before the modules that depend on them, so a module never appears before anything in its dependency set.'),
    ('senior-module-extraction', 3, 'Break ties alphabetically by module name, and ignore dependency names that are not keys of moduleDeps.'),
    ('senior-module-extraction', 4, 'Return an empty list when any cycle exists, including a module that depends on itself.'),
    ('senior-module-extraction', 5, 'A null map has no order.'),
    ('senior-dead-code', 1, 'declared holds every symbol defined in the codebase, referenced holds every symbol used somewhere and entryPoints holds symbols reachable from outside the analysis.'),
    ('senior-dead-code', 2, 'Report every declared symbol that appears in neither referenced nor entryPoints, sorted alphabetically.'),
    ('senior-dead-code', 3, 'Detection is NOT transitive: a symbol is dead only when nothing references it directly, so a symbol referenced by another dead symbol is still reported as reachable.'),
    ('senior-dead-code', 4, 'A null declared or referenced set means nothing is reported, and references to symbols that were never declared are ignored.'),
    ('junior-review-checklist', 1, 'Every review starts with "readability and naming" and then "tests cover the change".'),
    ('junior-review-checklist', 2, 'When hasTests is false add "add or update tests".'),
    ('junior-review-checklist', 3, 'When touchesConfig is true add "check configuration and environment impact".'),
    ('junior-review-checklist', 4, 'When changedLines exceeds 200 add "split the change or review in small commits" as the last item.'),
    ('junior-review-checklist', 5, 'Return the focus areas in that order; changedLines must be at least 1, otherwise IllegalArgumentException.'),
    ('junior-question-quality', 1, 'A good technical question has context, attempted steps and a minimal reproduction; report each absent part.'),
    ('junior-question-quality', 2, 'Look for the markers "Context:", "I tried" and "Minimal example:", each matched case-insensitively after trimming, with its content non-blank.'),
    ('junior-question-quality', 3, 'Report, in order: "missing context", "missing attempted steps", "missing minimal reproduction".'),
    ('junior-question-quality', 4, 'A null question misses all three parts.'),
    ('mid-estimate-range', 1, 'Return a map with keys best, likely and worst; best is the optimistic estimate and likely is best multiplied by the uncertainty factor.'),
    ('mid-estimate-range', 2, 'The uncertainty factor is clamped into 1.0..5.0 before use and fractional days are rounded up with Math.ceil.'),
    ('mid-estimate-range', 3, 'worst is best plus the difference between likely and best, so the range stays symmetric.'),
    ('mid-estimate-range', 4, 'optimisticDays must be at least 1 and the uncertainty factor must not be below 1.0 (values above 5.0 are clamped); otherwise IllegalArgumentException.'),
    ('mid-incident-timeline', 1, 'Every event starts with HH:mm followed by a space and a non-blank description; anything else, including a null event, throws IllegalArgumentException.'),
    ('mid-incident-timeline', 2, 'Order events chronologically by time and keep entries of equal time in input order unless one description contains detection, then mitigation, then resolved.'),
    ('mid-incident-timeline', 3, 'Within the same minute, detection ranks before mitigation, mitigation before resolved, and unrelated descriptions keep their input order.'),
    ('mid-incident-timeline', 4, 'A null or empty list returns an empty list.'),
    ('mid-onboarding-path', 1, 'Every new engineer starts with "set up the development environment" and "run the build and the test suite".'),
    ('mid-onboarding-path', 2, 'When javaBackground is false insert "work through the Java and framework learning path" after the first two steps.'),
    ('mid-onboarding-path', 3, 'Then comes "ship a small change to production".'),
    ('mid-onboarding-path', 4, 'When hasProductionAccess is true add "walk through the production runbooks and on-call basics" after shipping.'),
    ('mid-onboarding-path', 5, 'The path always ends with "meet the team and agree on a buddy".'),
    ('lead-growth-plan', 1, 'Support exactly three promotion steps: junior to mid, mid to senior and senior to staff.'),
    ('lead-growth-plan', 2, 'junior to mid returns, in order: "deliver small features end to end with review", "write tests first and grow debugging confidence", "ask for feedback early and often".'),
    ('lead-growth-plan', 3, 'mid to senior returns: "lead a system change across services", "design for reliability, cost and operability", "mentor a junior engineer through a full feature".'),
    ('lead-growth-plan', 4, 'senior to staff returns: "own a technical direction across teams", "write the design that others implement", "multiply the team through review and mentoring".'),
    ('lead-growth-plan', 5, 'Match the levels case-insensitively after trimming; any other pair, including null, throws IllegalArgumentException.'),
    ('lead-metrics-choice', 1, 'When deliveryFocused is true return "lead time for change" and then "deployment frequency"; when both flags are false return an empty list.'),
    ('lead-metrics-choice', 2, 'When reliabilityFocused is true return "change failure rate" and then "time to restore service".'),
    ('lead-metrics-choice', 3, 'Return both groups, delivery first, without duplicates.'),
    ('lead-metrics-choice', 4, 'Never return vanity metrics such as lines of code, story points or hours worked.'),
    ('lead-stakeholder-brief', 1, 'The outline always contains exactly these sections in order: the impact line, "cost and effort", "risks and mitigations", "options considered", "recommendation and next step".'),
    ('lead-stakeholder-brief', 2, 'The first line is "lead with the impact of <decision>" with the decision trimmed and inserted.'),
    ('lead-stakeholder-brief', 3, 'A null, blank or whitespace-only decision throws IllegalArgumentException.'),
    ('principal-tech-strategy', 1, 'A strategy has exactly these sections in order: "context and forces", the horizon section, "principles that guide decisions", "options and trade-offs", "decision and investment", "measurement and review cadence".'),
    ('principal-tech-strategy', 2, 'The horizon section reads "<n> year horizon and outcomes" where n is the spelled-out number for 2 through 9.'),
    ('principal-tech-strategy', 3, 'Only the spellings two, three, four, five, six, seven, eight and nine are supported; any other horizon throws IllegalArgumentException.'),
    ('principal-org-design', 1, 'Report findings in the order ownership, service count, platform team.'),
    ('principal-org-design', 2, 'When clearOwnership is false report "ownership is unclear: assign one accountable team per service".'),
    ('principal-org-design', 3, 'When servicesPerTeam is below 1 report "<n> services per team is invalid: a team must own at least one service"; when it is above 10 report "<n> services per team is too many: split the team or merge the services".'),
    ('principal-org-design', 4, 'When platformTeamExists is false report "no platform team: create one to own shared build, deploy and observability tooling".'),
    ('principal-org-design', 5, 'A topology with no findings returns exactly "topology is healthy: ownership is clear and services are sized well".')
) AS r(challenge_slug, sort_order, description)
JOIN challenge c ON c.slug = r.challenge_slug
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_requirement existing
    WHERE existing.challenge_id = c.id AND existing.sort_order = r.sort_order
);

INSERT INTO challenge_skill (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
    ('junior-vowel-counter', 'java-fundamentals'),
    ('junior-vowel-counter', 'java-syntax'),
    ('junior-palindrome-phrase', 'java-fundamentals'),
    ('junior-palindrome-phrase', 'java-syntax'),
    ('junior-title-case', 'java-fundamentals'),
    ('junior-title-case', 'java-syntax'),
    ('junior-number-grouping', 'java-fundamentals'),
    ('junior-number-grouping', 'java-syntax'),
    ('junior-dedupe-preserving-order', 'java-fundamentals'),
    ('junior-dedupe-preserving-order', 'java-syntax'),
    ('junior-map-merge-sum', 'java-fundamentals'),
    ('junior-map-merge-sum', 'java-syntax'),
    ('junior-null-safe-join', 'java-fundamentals'),
    ('junior-null-safe-join', 'java-syntax'),
    ('junior-enum-from-text', 'java-fundamentals'),
    ('junior-enum-from-text', 'java-syntax'),
    ('mid-generic-max', 'java-fundamentals'),
    ('mid-generic-max', 'java-syntax'),
    ('mid-stream-group-count', 'java-fundamentals'),
    ('mid-stream-group-count', 'java-syntax'),
    ('mid-record-validation', 'java-fundamentals'),
    ('mid-record-validation', 'java-syntax'),
    ('mid-nested-optional-lookup', 'java-fundamentals'),
    ('mid-nested-optional-lookup', 'java-syntax'),
    ('mid-immutable-builder', 'java-fundamentals'),
    ('mid-immutable-builder', 'java-syntax'),
    ('mid-multikey-comparator', 'java-fundamentals'),
    ('mid-multikey-comparator', 'java-syntax'),
    ('mid-sealed-outcome', 'java-fundamentals'),
    ('mid-sealed-outcome', 'java-syntax'),
    ('senior-stream-partition-stats', 'java-fundamentals'),
    ('senior-stream-partition-stats', 'java-syntax'),
    ('senior-generic-repository', 'java-fundamentals'),
    ('senior-generic-repository', 'java-syntax'),
    ('senior-functional-pipeline', 'java-fundamentals'),
    ('senior-functional-pipeline', 'java-syntax'),
    ('junior-cli-flag-parser', 'java-fundamentals'),
    ('junior-exit-code-choice', 'java-fundamentals'),
    ('junior-properties-parse', 'java-fundamentals'),
    ('junior-classpath-split', 'java-fundamentals'),
    ('mid-java-version-compare', 'java-fundamentals'),
    ('mid-lts-classification', 'java-fundamentals'),
    ('mid-module-requires', 'java-fundamentals'),
    ('mid-heap-from-percentage', 'java-fundamentals'),
    ('mid-heap-from-percentage', 'observability'),
    ('mid-gc-pause-summary', 'java-fundamentals'),
    ('mid-gc-pause-summary', 'observability'),
    ('mid-allocation-budget', 'java-fundamentals'),
    ('mid-allocation-budget', 'observability'),
    ('senior-collector-choice', 'java-fundamentals'),
    ('senior-collector-choice', 'observability'),
    ('senior-warmup-strategy', 'java-fundamentals'),
    ('senior-warmup-strategy', 'observability'),
    ('senior-oom-classification', 'java-fundamentals'),
    ('senior-oom-classification', 'observability'),
    ('junior-safe-counter-logic', 'concurrency'),
    ('junior-latch-count', 'concurrency'),
    ('junior-completed-future', 'concurrency'),
    ('mid-pool-size-calculation', 'concurrency'),
    ('mid-cas-retry-loop', 'concurrency'),
    ('mid-atomic-compute-if-absent', 'concurrency'),
    ('mid-deadlock-cycle', 'concurrency'),
    ('mid-semaphore-admission', 'concurrency'),
    ('mid-backoff-schedule', 'concurrency'),
    ('mid-graceful-shutdown-order', 'concurrency'),
    ('mid-stamped-read-valid', 'concurrency'),
    ('senior-virtual-or-platform', 'concurrency'),
    ('senior-deadline-budget', 'concurrency'),
    ('senior-bounded-queue-policy', 'concurrency'),
    ('senior-forkjoin-threshold', 'concurrency'),
    ('senior-threadlocal-leak', 'concurrency'),
    ('lead-concurrency-standard', 'concurrency'),
    ('lead-virtual-thread-migration', 'concurrency'),
    ('junior-gav-parse', 'java-syntax'),
    ('junior-gav-parse', 'testing'),
    ('junior-scope-choice', 'java-syntax'),
    ('junior-scope-choice', 'testing'),
    ('junior-version-compare', 'java-syntax'),
    ('junior-version-compare', 'testing'),
    ('junior-property-substitution', 'java-syntax'),
    ('junior-property-substitution', 'testing'),
    ('junior-plugin-goal-parse', 'java-syntax'),
    ('junior-plugin-goal-parse', 'testing'),
    ('junior-module-direct-deps', 'java-syntax'),
    ('junior-module-direct-deps', 'testing'),
    ('mid-nearest-wins', 'java-syntax'),
    ('mid-nearest-wins', 'testing'),
    ('mid-exclusion-set', 'java-syntax'),
    ('mid-exclusion-set', 'testing'),
    ('mid-bom-alignment', 'java-syntax'),
    ('mid-bom-alignment', 'testing'),
    ('mid-profile-activation', 'java-syntax'),
    ('mid-profile-activation', 'testing'),
    ('mid-lifecycle-order', 'java-syntax'),
    ('mid-lifecycle-order', 'testing'),
    ('mid-gradle-task-order', 'java-syntax'),
    ('mid-gradle-task-order', 'testing'),
    ('mid-configuration-choice', 'java-syntax'),
    ('mid-configuration-choice', 'testing'),
    ('mid-catalog-alias', 'java-syntax'),
    ('mid-catalog-alias', 'testing'),
    ('senior-build-cache-key', 'java-syntax'),
    ('senior-build-cache-key', 'testing'),
    ('senior-reproducible-timestamp', 'java-syntax'),
    ('senior-reproducible-timestamp', 'testing'),
    ('senior-toolchain-matrix', 'java-syntax'),
    ('senior-toolchain-matrix', 'testing'),
    ('senior-configuration-cache-safe', 'java-syntax'),
    ('senior-configuration-cache-safe', 'testing'),
    ('senior-enforcer-rules', 'java-syntax'),
    ('senior-enforcer-rules', 'testing'),
    ('lead-build-standard', 'java-syntax'),
    ('lead-build-standard', 'testing'),
    ('lead-gradle-migration', 'java-syntax'),
    ('lead-gradle-migration', 'testing'),
    ('junior-bean-scope', 'api-design'),
    ('junior-bean-scope', 'resilience'),
    ('junior-property-bind', 'api-design'),
    ('junior-property-bind', 'resilience'),
    ('junior-status-mapping', 'api-design'),
    ('junior-status-mapping', 'resilience'),
    ('mid-autoconfig-condition', 'api-design'),
    ('mid-autoconfig-condition', 'resilience'),
    ('mid-profile-override-merge', 'api-design'),
    ('mid-profile-override-merge', 'resilience'),
    ('mid-problem-detail-build', 'api-design'),
    ('mid-problem-detail-build', 'resilience'),
    ('mid-validation-fields', 'api-design'),
    ('mid-validation-fields', 'resilience'),
    ('mid-cache-key-compose', 'api-design'),
    ('mid-cache-key-compose', 'resilience'),
    ('mid-transaction-boundary', 'api-design'),
    ('mid-transaction-boundary', 'resilience'),
    ('mid-retry-delay', 'api-design'),
    ('mid-retry-delay', 'resilience'),
    ('mid-health-aggregate', 'api-design'),
    ('mid-health-aggregate', 'resilience'),
    ('senior-aop-order', 'api-design'),
    ('senior-aop-order', 'resilience'),
    ('senior-propagation-choice', 'api-design'),
    ('senior-propagation-choice', 'resilience'),
    ('senior-api-version-route', 'api-design'),
    ('senior-api-version-route', 'resilience'),
    ('senior-filter-chain-order', 'api-design'),
    ('senior-filter-chain-order', 'resilience'),
    ('senior-modulith-boundary', 'api-design'),
    ('senior-modulith-boundary', 'resilience'),
    ('senior-native-hint-need', 'api-design'),
    ('senior-native-hint-need', 'resilience'),
    ('lead-upgrade-plan', 'api-design'),
    ('lead-upgrade-plan', 'resilience'),
    ('lead-service-template', 'api-design'),
    ('lead-service-template', 'resilience'),
    ('mid-query-method-parse', 'sql-persistence'),
    ('mid-query-method-parse', 'api-design'),
    ('mid-page-vs-slice', 'sql-persistence'),
    ('mid-page-vs-slice', 'api-design'),
    ('mid-scope-authorisation', 'sql-persistence'),
    ('mid-scope-authorisation', 'api-design'),
    ('mid-password-policy', 'sql-persistence'),
    ('mid-password-policy', 'api-design'),
    ('senior-jwt-claims', 'sql-persistence'),
    ('senior-jwt-claims', 'api-design'),
    ('senior-method-security', 'sql-persistence'),
    ('senior-method-security', 'api-design'),
    ('senior-audit-write', 'sql-persistence'),
    ('senior-audit-write', 'api-design'),
    ('junior-where-builder', 'sql-persistence'),
    ('junior-row-count', 'sql-persistence'),
    ('junior-null-semantics', 'sql-persistence'),
    ('junior-order-clause', 'sql-persistence'),
    ('mid-index-column-order', 'sql-persistence'),
    ('mid-join-fanout', 'sql-persistence'),
    ('mid-query-count', 'sql-persistence'),
    ('mid-isolation-choice', 'sql-persistence'),
    ('mid-lock-order', 'sql-persistence'),
    ('mid-explain-verdict', 'sql-persistence'),
    ('senior-partition-key', 'sql-persistence'),
    ('senior-vacuum-settings', 'sql-persistence'),
    ('senior-replica-routing', 'sql-persistence'),
    ('senior-migration-safety', 'sql-persistence'),
    ('mid-fetch-strategy', 'sql-persistence'),
    ('mid-fetch-strategy', 'object-oriented-design'),
    ('mid-batch-size', 'sql-persistence'),
    ('mid-batch-size', 'object-oriented-design'),
    ('mid-optimistic-conflict', 'sql-persistence'),
    ('mid-optimistic-conflict', 'object-oriented-design'),
    ('mid-dto-projection', 'sql-persistence'),
    ('mid-dto-projection', 'object-oriented-design'),
    ('mid-entity-mapping-review', 'sql-persistence'),
    ('mid-entity-mapping-review', 'object-oriented-design'),
    ('senior-second-level-cache', 'sql-persistence'),
    ('senior-second-level-cache', 'object-oriented-design'),
    ('senior-statistics-triage', 'sql-persistence'),
    ('senior-statistics-triage', 'object-oriented-design'),
    ('senior-nplusone-detect', 'sql-persistence'),
    ('senior-nplusone-detect', 'object-oriented-design'),
    ('mid-partition-key-choice', 'distributed-systems'),
    ('mid-partition-key-choice', 'concurrency'),
    ('mid-offset-commit', 'distributed-systems'),
    ('mid-offset-commit', 'concurrency'),
    ('mid-dlq-route', 'distributed-systems'),
    ('mid-dlq-route', 'concurrency'),
    ('mid-consumer-dedupe', 'distributed-systems'),
    ('mid-consumer-dedupe', 'concurrency'),
    ('mid-schema-compat', 'distributed-systems'),
    ('mid-schema-compat', 'concurrency'),
    ('senior-exactly-once-decision', 'distributed-systems'),
    ('senior-exactly-once-decision', 'concurrency'),
    ('senior-rebalance-impact', 'distributed-systems'),
    ('senior-rebalance-impact', 'concurrency'),
    ('senior-outbox-claim', 'distributed-systems'),
    ('senior-outbox-claim', 'concurrency'),
    ('senior-event-version-route', 'distributed-systems'),
    ('senior-event-version-route', 'concurrency'),
    ('lead-event-governance', 'distributed-systems'),
    ('lead-event-governance', 'concurrency'),
    ('lead-saga-compensation', 'distributed-systems'),
    ('lead-saga-compensation', 'concurrency'),
    ('mid-message-router', 'distributed-systems'),
    ('mid-message-router', 'api-design'),
    ('mid-splitter-aggregate', 'distributed-systems'),
    ('mid-splitter-aggregate', 'api-design'),
    ('mid-cron-next-run', 'distributed-systems'),
    ('mid-cron-next-run', 'api-design'),
    ('senior-batch-partition', 'distributed-systems'),
    ('senior-batch-partition', 'api-design'),
    ('senior-file-idempotency', 'distributed-systems'),
    ('senior-file-idempotency', 'api-design'),
    ('junior-path-template', 'api-design'),
    ('junior-path-template', 'http-rest'),
    ('junior-status-code-choice', 'api-design'),
    ('junior-status-code-choice', 'http-rest'),
    ('junior-query-filter-parse', 'api-design'),
    ('junior-query-filter-parse', 'http-rest'),
    ('mid-etag-compute', 'api-design'),
    ('mid-etag-compute', 'http-rest'),
    ('mid-cursor-pagination', 'api-design'),
    ('mid-cursor-pagination', 'http-rest'),
    ('mid-problem-json', 'api-design'),
    ('mid-problem-json', 'http-rest'),
    ('mid-content-negotiation', 'api-design'),
    ('mid-content-negotiation', 'http-rest'),
    ('mid-rate-limit-headers', 'api-design'),
    ('mid-rate-limit-headers', 'http-rest'),
    ('senior-breaking-change', 'api-design'),
    ('senior-breaking-change', 'http-rest'),
    ('senior-graphql-depth', 'api-design'),
    ('senior-graphql-depth', 'http-rest'),
    ('senior-grpc-field-safety', 'api-design'),
    ('senior-grpc-field-safety', 'http-rest'),
    ('junior-header-parse', 'http-rest'),
    ('junior-header-parse', 'api-design'),
    ('junior-uri-normalise', 'http-rest'),
    ('junior-uri-normalise', 'api-design'),
    ('junior-status-class', 'http-rest'),
    ('junior-status-class', 'api-design'),
    ('mid-cache-freshness', 'http-rest'),
    ('mid-cache-freshness', 'api-design'),
    ('mid-retry-safety', 'http-rest'),
    ('mid-retry-safety', 'api-design'),
    ('mid-timeout-budget', 'http-rest'),
    ('mid-timeout-budget', 'api-design'),
    ('mid-cors-decision', 'http-rest'),
    ('mid-cors-decision', 'api-design'),
    ('senior-tls-policy', 'http-rest'),
    ('senior-tls-policy', 'api-design'),
    ('senior-http2-decision', 'http-rest'),
    ('senior-http2-decision', 'api-design'),
    ('mid-circuit-state', 'distributed-systems'),
    ('mid-circuit-state', 'resilience'),
    ('mid-bulkhead-limit', 'distributed-systems'),
    ('mid-bulkhead-limit', 'resilience'),
    ('mid-discovery-cache', 'distributed-systems'),
    ('mid-discovery-cache', 'resilience'),
    ('mid-correlation-id', 'distributed-systems'),
    ('mid-correlation-id', 'resilience'),
    ('mid-error-budget', 'distributed-systems'),
    ('mid-error-budget', 'resilience'),
    ('senior-saga-compensate', 'distributed-systems'),
    ('senior-saga-compensate', 'resilience'),
    ('senior-tenant-routing', 'distributed-systems'),
    ('senior-tenant-routing', 'resilience'),
    ('senior-strangler-route', 'distributed-systems'),
    ('senior-strangler-route', 'resilience'),
    ('senior-contract-compat', 'distributed-systems'),
    ('senior-contract-compat', 'resilience'),
    ('lead-resilience-standard', 'distributed-systems'),
    ('lead-resilience-standard', 'resilience'),
    ('lead-monolith-split', 'distributed-systems'),
    ('lead-monolith-split', 'resilience'),
    ('senior-quality-tactic', 'architecture'),
    ('senior-quality-tactic', 'distributed-systems'),
    ('senior-adr-review', 'architecture'),
    ('senior-adr-review', 'distributed-systems'),
    ('senior-instability-metric', 'architecture'),
    ('senior-instability-metric', 'distributed-systems'),
    ('lead-roadmap-sequence', 'architecture'),
    ('lead-roadmap-sequence', 'distributed-systems'),
    ('lead-cost-capacity', 'architecture'),
    ('lead-cost-capacity', 'distributed-systems'),
    ('principal-system-shape', 'architecture'),
    ('principal-system-shape', 'distributed-systems'),
    ('principal-governance', 'architecture'),
    ('principal-governance', 'distributed-systems'),
    ('mid-value-object-equality', 'architecture'),
    ('mid-value-object-equality', 'object-oriented-design'),
    ('mid-aggregate-invariant', 'architecture'),
    ('mid-aggregate-invariant', 'object-oriented-design'),
    ('mid-domain-event-name', 'architecture'),
    ('mid-domain-event-name', 'object-oriented-design'),
    ('mid-repository-contract', 'architecture'),
    ('mid-repository-contract', 'object-oriented-design'),
    ('mid-ubiquitous-terms', 'architecture'),
    ('mid-ubiquitous-terms', 'object-oriented-design'),
    ('senior-context-map', 'architecture'),
    ('senior-context-map', 'object-oriented-design'),
    ('senior-anticorruption-translate', 'architecture'),
    ('senior-anticorruption-translate', 'object-oriented-design'),
    ('senior-event-replay', 'architecture'),
    ('senior-event-replay', 'object-oriented-design'),
    ('junior-assertion-choice', 'testing'),
    ('junior-test-name-quality', 'testing'),
    ('junior-test-structure', 'testing'),
    ('mid-parameterised-cases', 'testing'),
    ('mid-interaction-verify', 'testing'),
    ('mid-container-lifecycle', 'testing'),
    ('mid-flaky-detection', 'testing'),
    ('senior-contract-verify', 'testing'),
    ('senior-mutation-score', 'testing'),
    ('senior-pyramid-allocation', 'testing'),
    ('mid-coverage-threshold', 'testing'),
    ('mid-coverage-threshold', 'observability'),
    ('mid-severity-mapping', 'testing'),
    ('mid-severity-mapping', 'observability'),
    ('senior-benchmark-validity', 'testing'),
    ('senior-benchmark-validity', 'observability'),
    ('senior-load-model', 'testing'),
    ('senior-load-model', 'observability'),
    ('junior-log-level', 'observability'),
    ('junior-metric-name', 'observability'),
    ('junior-alert-condition', 'observability'),
    ('mid-cardinality-risk', 'observability'),
    ('mid-histogram-buckets', 'observability'),
    ('mid-trace-sampling', 'observability'),
    ('mid-burn-rate-alert', 'observability'),
    ('senior-tail-sampling', 'observability'),
    ('senior-incident-triage', 'observability'),
    ('senior-slo-alert-design', 'observability'),
    ('mid-cache-ttl', 'observability'),
    ('mid-cache-ttl', 'concurrency'),
    ('mid-invalidation-set', 'observability'),
    ('mid-invalidation-set', 'concurrency'),
    ('mid-pool-sizing', 'observability'),
    ('mid-pool-sizing', 'concurrency'),
    ('senior-target-choice', 'observability'),
    ('senior-target-choice', 'concurrency'),
    ('senior-format-choice', 'observability'),
    ('senior-format-choice', 'concurrency'),
    ('senior-regression-gate', 'observability'),
    ('senior-regression-gate', 'concurrency'),
    ('mid-error-fallback', 'concurrency'),
    ('mid-error-fallback', 'resilience'),
    ('mid-backpressure-policy', 'concurrency'),
    ('mid-backpressure-policy', 'resilience'),
    ('mid-scheduler-choice', 'concurrency'),
    ('mid-scheduler-choice', 'resilience'),
    ('mid-context-value', 'concurrency'),
    ('mid-context-value', 'resilience'),
    ('senior-blocking-detect', 'concurrency'),
    ('senior-blocking-detect', 'resilience'),
    ('senior-reactive-or-thread', 'concurrency'),
    ('senior-reactive-or-thread', 'resilience'),
    ('senior-streaming-backpressure', 'concurrency'),
    ('senior-streaming-backpressure', 'resilience'),
    ('junior-dockerfile-order', 'observability'),
    ('junior-dockerfile-order', 'resilience'),
    ('junior-env-injection', 'observability'),
    ('junior-env-injection', 'resilience'),
    ('junior-probe-choice', 'observability'),
    ('junior-probe-choice', 'resilience'),
    ('mid-resource-limits', 'observability'),
    ('mid-resource-limits', 'resilience'),
    ('mid-hpa-target', 'observability'),
    ('mid-hpa-target', 'resilience'),
    ('mid-config-merge', 'observability'),
    ('mid-config-merge', 'resilience'),
    ('mid-shutdown-grace', 'observability'),
    ('mid-shutdown-grace', 'resilience'),
    ('senior-image-reduction', 'observability'),
    ('senior-image-reduction', 'resilience'),
    ('senior-pod-security', 'observability'),
    ('senior-pod-security', 'resilience'),
    ('senior-rollout-strategy', 'observability'),
    ('senior-rollout-strategy', 'resilience'),
    ('junior-secret-source', 'architecture'),
    ('junior-secret-source', 'resilience'),
    ('junior-release-tag', 'architecture'),
    ('junior-release-tag', 'resilience'),
    ('junior-parity-check', 'architecture'),
    ('junior-parity-check', 'resilience'),
    ('mid-pipeline-gate', 'architecture'),
    ('mid-pipeline-gate', 'resilience'),
    ('mid-canary-percent', 'architecture'),
    ('mid-canary-percent', 'resilience'),
    ('mid-flag-evaluation', 'architecture'),
    ('mid-flag-evaluation', 'resilience'),
    ('mid-autoscale-signal', 'architecture'),
    ('mid-autoscale-signal', 'resilience'),
    ('senior-database-compatibility', 'architecture'),
    ('senior-database-compatibility', 'resilience'),
    ('senior-cost-triage', 'architecture'),
    ('senior-cost-triage', 'resilience'),
    ('senior-iac-drift', 'architecture'),
    ('senior-iac-drift', 'resilience'),
    ('lead-delivery-standard', 'architecture'),
    ('lead-delivery-standard', 'resilience'),
    ('lead-secret-rotation', 'architecture'),
    ('lead-secret-rotation', 'resilience'),
    ('junior-password-strength', 'architecture'),
    ('junior-password-strength', 'control-flow'),
    ('junior-secret-detection', 'architecture'),
    ('junior-secret-detection', 'control-flow'),
    ('junior-header-hardening', 'architecture'),
    ('junior-header-hardening', 'control-flow'),
    ('junior-input-sanitise', 'architecture'),
    ('junior-input-sanitise', 'control-flow'),
    ('mid-parameterised-query', 'architecture'),
    ('mid-parameterised-query', 'control-flow'),
    ('mid-output-encoding', 'architecture'),
    ('mid-output-encoding', 'control-flow'),
    ('mid-csrf-token-check', 'architecture'),
    ('mid-csrf-token-check', 'control-flow'),
    ('mid-jwt-validation', 'architecture'),
    ('mid-jwt-validation', 'control-flow'),
    ('mid-scope-check', 'architecture'),
    ('mid-scope-check', 'control-flow'),
    ('senior-crypto-choice', 'architecture'),
    ('senior-crypto-choice', 'control-flow'),
    ('senior-key-rotation', 'architecture'),
    ('senior-key-rotation', 'control-flow'),
    ('senior-audit-events', 'architecture'),
    ('senior-audit-events', 'control-flow'),
    ('senior-sbom-gate', 'architecture'),
    ('senior-sbom-gate', 'control-flow'),
    ('principal-threat-model', 'architecture'),
    ('principal-threat-model', 'control-flow'),
    ('principal-security-policy', 'architecture'),
    ('principal-security-policy', 'control-flow'),
    ('junior-json-field-read', 'java-syntax'),
    ('junior-json-field-read', 'api-design'),
    ('junior-csv-row-parse', 'java-syntax'),
    ('junior-csv-row-parse', 'api-design'),
    ('junior-yaml-flatten', 'java-syntax'),
    ('junior-yaml-flatten', 'api-design'),
    ('mid-polymorphic-write', 'java-syntax'),
    ('mid-polymorphic-write', 'api-design'),
    ('mid-format-compatibility', 'java-syntax'),
    ('mid-format-compatibility', 'api-design'),
    ('mid-number-precision', 'java-syntax'),
    ('mid-number-precision', 'api-design'),
    ('mid-datetime-format', 'java-syntax'),
    ('mid-datetime-format', 'api-design'),
    ('senior-deserialisation-safety', 'java-syntax'),
    ('senior-deserialisation-safety', 'api-design'),
    ('senior-streaming-parse', 'java-syntax'),
    ('senior-streaming-parse', 'api-design'),
    ('junior-reverse-array', 'collections'),
    ('junior-reverse-array', 'control-flow'),
    ('junior-find-maximum', 'collections'),
    ('junior-find-maximum', 'control-flow'),
    ('junior-count-occurrences', 'collections'),
    ('junior-count-occurrences', 'control-flow'),
    ('junior-remove-duplicates', 'collections'),
    ('junior-remove-duplicates', 'control-flow'),
    ('junior-sort-by-key', 'collections'),
    ('junior-sort-by-key', 'control-flow'),
    ('mid-two-sum', 'collections'),
    ('mid-two-sum', 'control-flow'),
    ('mid-sliding-window', 'collections'),
    ('mid-sliding-window', 'control-flow'),
    ('mid-lru-cache', 'collections'),
    ('mid-lru-cache', 'control-flow'),
    ('mid-top-k-frequent', 'collections'),
    ('mid-top-k-frequent', 'control-flow'),
    ('mid-graph-bfs', 'collections'),
    ('mid-graph-bfs', 'control-flow'),
    ('mid-merge-intervals', 'collections'),
    ('mid-merge-intervals', 'control-flow'),
    ('senior-dijkstra', 'collections'),
    ('senior-dijkstra', 'control-flow'),
    ('senior-knapsack', 'collections'),
    ('senior-knapsack', 'control-flow'),
    ('senior-lru-threadsafe', 'collections'),
    ('senior-lru-threadsafe', 'control-flow'),
    ('junior-guard-clause', 'object-oriented-design'),
    ('junior-guard-clause', 'testing'),
    ('junior-method-extraction', 'object-oriented-design'),
    ('junior-method-extraction', 'testing'),
    ('mid-duplication-detect', 'object-oriented-design'),
    ('mid-duplication-detect', 'testing'),
    ('mid-strategy-extraction', 'object-oriented-design'),
    ('mid-strategy-extraction', 'testing'),
    ('mid-test-seam', 'object-oriented-design'),
    ('mid-test-seam', 'testing'),
    ('mid-legacy-risk', 'object-oriented-design'),
    ('mid-legacy-risk', 'testing'),
    ('senior-characterisation', 'object-oriented-design'),
    ('senior-characterisation', 'testing'),
    ('senior-module-extraction', 'object-oriented-design'),
    ('senior-module-extraction', 'testing'),
    ('senior-dead-code', 'object-oriented-design'),
    ('senior-dead-code', 'testing'),
    ('junior-review-checklist', 'technical-leadership'),
    ('junior-question-quality', 'technical-leadership'),
    ('mid-estimate-range', 'technical-leadership'),
    ('mid-incident-timeline', 'technical-leadership'),
    ('mid-onboarding-path', 'technical-leadership'),
    ('lead-growth-plan', 'technical-leadership'),
    ('lead-metrics-choice', 'technical-leadership'),
    ('lead-stakeholder-brief', 'technical-leadership'),
    ('principal-tech-strategy', 'technical-leadership'),
    ('principal-org-design', 'technical-leadership')
) AS m(challenge_slug, skill_slug)
JOIN challenge c ON c.slug = m.challenge_slug
JOIN skill s ON s.slug = m.skill_slug
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_skill existing
    WHERE existing.challenge_id = c.id AND existing.skill_id = s.id
);

INSERT INTO tutorial_challenge (tutorial_id, challenge_id, sort_order)
SELECT t.id, c.id,
       ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY c.level, c.slug)
FROM (VALUES
    ('strings-and-text', 'junior-vowel-counter'),
    ('strings-and-text', 'junior-palindrome-phrase'),
    ('strings-and-text', 'junior-title-case'),
    ('strings-and-text', 'junior-number-grouping'),
    ('collections', 'junior-dedupe-preserving-order'),
    ('collections', 'junior-map-merge-sum'),
    ('strings-and-text', 'junior-null-safe-join'),
    ('enums-and-records', 'junior-enum-from-text'),
    ('java-generics-in-depth', 'mid-generic-max'),
    ('java-streams-in-depth', 'mid-stream-group-count'),
    ('java-records-in-depth', 'mid-record-validation'),
    ('java-optional-patterns', 'mid-nested-optional-lookup'),
    ('java-immutability-patterns', 'mid-immutable-builder'),
    ('java-streams-in-depth', 'mid-multikey-comparator'),
    ('java-sealed-types', 'mid-sealed-outcome'),
    ('java-streams-in-depth', 'senior-stream-partition-stats'),
    ('java-generics-in-depth', 'senior-generic-repository'),
    ('java-functional-interfaces', 'senior-functional-pipeline'),
    ('jdk-command-line-tools', 'junior-cli-flag-parser'),
    ('packaging-java-applications', 'junior-exit-code-choice'),
    ('java-home-and-path', 'junior-properties-parse'),
    ('classpath-vs-modulepath', 'junior-classpath-split'),
    ('java-release-cadence', 'mid-java-version-compare'),
    ('choosing-a-java-version', 'mid-lts-classification'),
    ('java-module-system-basics', 'mid-module-requires'),
    ('jvm-architecture-internals', 'mid-heap-from-percentage'),
    ('garbage-collection-basics', 'mid-gc-pause-summary'),
    ('jvm-runtime-observability', 'mid-allocation-budget'),
    ('gc-tuning-in-practice', 'senior-collector-choice'),
    ('jit-compilation-and-warmup', 'senior-warmup-strategy'),
    ('jvm-diagnostics-toolbox', 'senior-oom-classification'),
    ('concurrency-primitives', 'junior-safe-counter-logic'),
    ('thread-lifecycle-and-diagnostics', 'junior-latch-count'),
    ('future-and-completablefuture', 'junior-completed-future'),
    ('executor-service-patterns', 'mid-pool-size-calculation'),
    ('atomics-and-cas', 'mid-cas-retry-loop'),
    ('concurrent-collections-in-practice', 'mid-atomic-compute-if-absent'),
    ('deadlock-livelock-detection', 'mid-deadlock-cycle'),
    ('backpressure-and-flow-control', 'mid-semaphore-admission'),
    ('deadline-and-timeout-propagation', 'mid-backoff-schedule'),
    ('async-vs-sync-tradeoffs', 'mid-graceful-shutdown-order'),
    ('locks-vs-synchronized', 'mid-stamped-read-valid'),
    ('virtual-threads-in-practice', 'senior-virtual-or-platform'),
    ('deadline-and-timeout-propagation', 'senior-deadline-budget'),
    ('backpressure-and-flow-control', 'senior-bounded-queue-policy'),
    ('parallel-streams-and-forkjoin', 'senior-forkjoin-threshold'),
    ('threadlocal-and-context-propagation', 'senior-threadlocal-leak'),
    ('backpressure-and-flow-control', 'lead-concurrency-standard'),
    ('java-virtual-threads', 'lead-virtual-thread-migration'),
    ('maven-pom-anatomy', 'junior-gav-parse'),
    ('maven-dependency-scopes', 'junior-scope-choice'),
    ('maven-release-and-versioning', 'junior-version-compare'),
    ('maven-profiles-and-properties', 'junior-property-substitution'),
    ('maven-plugins-and-executions', 'junior-plugin-goal-parse'),
    ('maven-multi-module-builds', 'junior-module-direct-deps'),
    ('maven-transitive-dependencies-and-exclusions', 'mid-nearest-wins'),
    ('maven-transitive-dependencies-and-exclusions', 'mid-exclusion-set'),
    ('maven-dependency-management-and-boms', 'mid-bom-alignment'),
    ('maven-profiles-and-properties', 'mid-profile-activation'),
    ('maven-build-lifecycle-and-phases', 'mid-lifecycle-order'),
    ('gradle-tasks-and-build-lifecycle', 'mid-gradle-task-order'),
    ('gradle-dependency-configurations', 'mid-configuration-choice'),
    ('gradle-version-catalogs', 'mid-catalog-alias'),
    ('gradle-incremental-builds-and-caching', 'senior-build-cache-key'),
    ('maven-reproducible-builds', 'senior-reproducible-timestamp'),
    ('maven-toolchains', 'senior-toolchain-matrix'),
    ('gradle-configuration-cache', 'senior-configuration-cache-safe'),
    ('maven-enforcer-and-quality-gates', 'senior-enforcer-rules'),
    ('maven-reproducible-builds', 'lead-build-standard'),
    ('migrating-maven-to-gradle', 'lead-gradle-migration'),
    ('spring-bean-lifecycle-and-scopes', 'junior-bean-scope'),
    ('spring-configuration-properties-and-profiles', 'junior-property-bind'),
    ('spring-error-handling-and-problem-details', 'junior-status-mapping'),
    ('spring-autoconfiguration-and-conditional-beans', 'mid-autoconfig-condition'),
    ('spring-configuration-properties-and-profiles', 'mid-profile-override-merge'),
    ('spring-error-handling-and-problem-details', 'mid-problem-detail-build'),
    ('spring-validation-and-binding', 'mid-validation-fields'),
    ('spring-cache-abstraction', 'mid-cache-key-compose'),
    ('spring-transaction-management', 'mid-transaction-boundary'),
    ('spring-retry-and-backoff', 'mid-retry-delay'),
    ('spring-actuator-basics', 'mid-health-aggregate'),
    ('spring-aop-fundamentals', 'senior-aop-order'),
    ('spring-transaction-management', 'senior-propagation-choice'),
    ('spring-7-api-versioning', 'senior-api-version-route'),
    ('spring-security-filter-chain', 'senior-filter-chain-order'),
    ('spring-modulith', 'senior-modulith-boundary'),
    ('spring-aot-and-native-images', 'senior-native-hint-need'),
    ('spring-framework-7-overview', 'lead-upgrade-plan'),
    ('spring-ecosystem-and-boot-overview', 'lead-service-template'),
    ('spring-data-jpa-queries', 'mid-query-method-parse'),
    ('spring-data-jpa-queries', 'mid-page-vs-slice'),
    ('spring-oauth2-resource-server', 'mid-scope-authorisation'),
    ('spring-security-authentication', 'mid-password-policy'),
    ('spring-oauth2-resource-server', 'senior-jwt-claims'),
    ('spring-security-method-authorization', 'senior-method-security'),
    ('spring-security-authentication', 'senior-audit-write'),
    ('sql-query-fundamentals', 'junior-where-builder'),
    ('sql-query-fundamentals', 'junior-row-count'),
    ('sql-query-fundamentals', 'junior-null-semantics'),
    ('sql-query-fundamentals', 'junior-order-clause'),
    ('sql-indexing-strategy', 'mid-index-column-order'),
    ('sql-joins-in-depth', 'mid-join-fanout'),
    ('sql-query-planner-and-explain', 'mid-query-count'),
    ('sql-transactions-and-locking', 'mid-isolation-choice'),
    ('sql-transactions-and-locking', 'mid-lock-order'),
    ('sql-query-planner-and-explain', 'mid-explain-verdict'),
    ('postgresql-partitioning', 'senior-partition-key'),
    ('postgresql-vacuum-and-bloat', 'senior-vacuum-settings'),
    ('postgresql-replication-basics', 'senior-replica-routing'),
    ('database-migrations-at-scale', 'senior-migration-safety'),
    ('jpa-fetch-strategies', 'mid-fetch-strategy'),
    ('hibernate-batch-processing', 'mid-batch-size'),
    ('jpa-locking-strategies', 'mid-optimistic-conflict'),
    ('jpa-criteria-and-specifications', 'mid-dto-projection'),
    ('hibernate-mapping-basics', 'mid-entity-mapping-review'),
    ('hibernate-second-level-cache', 'senior-second-level-cache'),
    ('hibernate-statistics-and-tuning', 'senior-statistics-triage'),
    ('n-plus-one-problem', 'senior-nplusone-detect'),
    ('kafka-partitioning-strategy', 'mid-partition-key-choice'),
    ('kafka-consumers-and-offsets', 'mid-offset-commit'),
    ('kafka-retries-and-dead-letters', 'mid-dlq-route'),
    ('kafka-delivery-semantics', 'mid-consumer-dedupe'),
    ('kafka-schema-evolution', 'mid-schema-compat'),
    ('kafka-exactly-once-processing', 'senior-exactly-once-decision'),
    ('kafka-consumer-groups-and-rebalancing', 'senior-rebalance-impact'),
    ('transactional-outbox-pattern', 'senior-outbox-claim'),
    ('event-schema-governance', 'senior-event-version-route'),
    ('event-schema-governance', 'lead-event-governance'),
    ('distributed-transactions-and-sagas', 'lead-saga-compensation'),
    ('spring-integration-basics', 'mid-message-router'),
    ('spring-integration-basics', 'mid-splitter-aggregate'),
    ('scheduling-and-quartz', 'mid-cron-next-run'),
    ('batch-processing-with-spring-batch', 'senior-batch-partition'),
    ('file-and-ftp-integration', 'senior-file-idempotency'),
    ('rest-resource-modeling', 'junior-path-template'),
    ('api-error-contracts', 'junior-status-code-choice'),
    ('pagination-and-filtering', 'junior-query-filter-parse'),
    ('http-caching-in-depth', 'mid-etag-compute'),
    ('pagination-and-filtering', 'mid-cursor-pagination'),
    ('api-error-contracts', 'mid-problem-json'),
    ('api-versioning-strategies', 'mid-content-negotiation'),
    ('api-rate-limiting-and-quotas', 'mid-rate-limit-headers'),
    ('api-versioning-strategies', 'senior-breaking-change'),
    ('graphql-security-and-limits', 'senior-graphql-depth'),
    ('grpc-and-protobuf-basics', 'senior-grpc-field-safety'),
    ('http-headers-that-matter', 'junior-header-parse'),
    ('http-methods-semantics', 'junior-uri-normalise'),
    ('http-status-code-craft', 'junior-status-class'),
    ('http-caching-in-depth', 'mid-cache-freshness'),
    ('timeouts-and-retry-matrix', 'mid-retry-safety'),
    ('timeouts-and-retry-matrix', 'mid-timeout-budget'),
    ('content-security-and-cors', 'mid-cors-decision'),
    ('tls-handshake-essentials', 'senior-tls-policy'),
    ('http-2-and-http-3', 'senior-http2-decision'),
    ('circuit-breaker-patterns', 'mid-circuit-state'),
    ('bulkheads-and-pool-isolation', 'mid-bulkhead-limit'),
    ('service-discovery-in-practice', 'mid-discovery-cache'),
    ('correlation-ids-and-request-context', 'mid-correlation-id'),
    ('service-level-objectives', 'mid-error-budget'),
    ('distributed-transactions-and-sagas', 'senior-saga-compensate'),
    ('multi-tenancy-strategies', 'senior-tenant-routing'),
    ('strangler-fig-migration', 'senior-strangler-route'),
    ('service-contract-evolution', 'senior-contract-compat'),
    ('service-resilience', 'lead-resilience-standard'),
    ('service-boundaries', 'lead-monolith-split'),
    ('architecture-quality-attributes', 'senior-quality-tactic'),
    ('engineering-decision-records', 'senior-adr-review'),
    ('architecture-economics', 'senior-instability-metric'),
    ('platform-evolution', 'lead-roadmap-sequence'),
    ('cost-aware-architecture', 'lead-cost-capacity'),
    ('service-boundaries', 'principal-system-shape'),
    ('platform-api-design', 'principal-governance'),
    ('value-objects-modeling', 'mid-value-object-equality'),
    ('aggregates-and-consistency-boundaries', 'mid-aggregate-invariant'),
    ('domain-events-in-the-model', 'mid-domain-event-name'),
    ('repositories-as-domain-abstractions', 'mid-repository-contract'),
    ('ubiquitous-language-in-code', 'mid-ubiquitous-terms'),
    ('context-mapping-patterns', 'senior-context-map'),
    ('hexagonal-architecture-and-ddd', 'senior-anticorruption-translate'),
    ('domain-events-in-the-model', 'senior-event-replay'),
    ('junit5-fundamentals', 'junior-assertion-choice'),
    ('junit5-fundamentals', 'junior-test-name-quality'),
    ('junit5-fundamentals', 'junior-test-structure'),
    ('junit5-parameterized-tests', 'mid-parameterised-cases'),
    ('mockito-essentials', 'mid-interaction-verify'),
    ('testcontainers-fundamentals', 'mid-container-lifecycle'),
    ('flaky-tests-and-ci-reliability', 'mid-flaky-detection'),
    ('contract-testing', 'senior-contract-verify'),
    ('mutation-testing-with-pit', 'senior-mutation-score'),
    ('testing-boundaries', 'senior-pyramid-allocation'),
    ('code-coverage-with-jacoco', 'mid-coverage-threshold'),
    ('static-analysis-quality-gates', 'mid-severity-mapping'),
    ('microbenchmarking-with-jmh', 'senior-benchmark-validity'),
    ('load-testing-essentials', 'senior-load-model'),
    ('structured-logging-in-java', 'junior-log-level'),
    ('micrometer-metrics-fundamentals', 'junior-metric-name'),
    ('alerting-on-symptoms-not-causes', 'junior-alert-condition'),
    ('metric-cardinality-management', 'mid-cardinality-risk'),
    ('histogram-percentiles-and-buckets', 'mid-histogram-buckets'),
    ('distributed-tracing-with-opentelemetry', 'mid-trace-sampling'),
    ('alerting-on-symptoms-not-causes', 'mid-burn-rate-alert'),
    ('trace-context-propagation', 'senior-tail-sampling'),
    ('incident-debugging-with-observability', 'senior-incident-triage'),
    ('service-level-objectives', 'senior-slo-alert-design'),
    ('caching-strategies', 'mid-cache-ttl'),
    ('cache-consistency', 'mid-invalidation-set'),
    ('postgresql-connection-pooling', 'mid-pool-sizing'),
    ('throughput-vs-latency', 'senior-target-choice'),
    ('choosing-a-serialization-format', 'senior-format-choice'),
    ('performance-regression-prevention', 'senior-regression-gate'),
    ('reactor-error-handling', 'mid-error-fallback'),
    ('reactor-backpressure-in-practice', 'mid-backpressure-policy'),
    ('reactor-context-and-threading', 'mid-scheduler-choice'),
    ('reactor-context-and-threading', 'mid-context-value'),
    ('blocking-code-in-reactive-pipelines', 'senior-blocking-detect'),
    ('reactive-vs-virtual-threads', 'senior-reactive-or-thread'),
    ('reactor-backpressure-in-practice', 'senior-streaming-backpressure'),
    ('docker-layer-caching-for-java', 'junior-dockerfile-order'),
    ('kubernetes-configmaps-and-secrets', 'junior-env-injection'),
    ('kubernetes-probes-and-health', 'junior-probe-choice'),
    ('kubernetes-resource-limits-jvm', 'mid-resource-limits'),
    ('kubernetes-hpa-scaling', 'mid-hpa-target'),
    ('kubernetes-configmaps-and-secrets', 'mid-config-merge'),
    ('graceful-shutdown-in-containers', 'mid-shutdown-grace'),
    ('container-image-security', 'senior-image-reduction'),
    ('container-image-security', 'senior-pod-security'),
    ('kubernetes-deployments-and-services', 'senior-rollout-strategy'),
    ('secrets-management-in-the-cloud', 'junior-secret-source'),
    ('ci-cd-github-actions-java', 'junior-release-tag'),
    ('environment-parity', 'junior-parity-check'),
    ('ci-cd-quality-gates', 'mid-pipeline-gate'),
    ('canary-deployments', 'mid-canary-percent'),
    ('feature-flags-in-practice', 'mid-flag-evaluation'),
    ('autoscaling-strategies', 'mid-autoscale-signal'),
    ('blue-green-deployments', 'senior-database-compatibility'),
    ('cost-aware-architecture', 'senior-cost-triage'),
    ('infrastructure-as-code-terraform', 'senior-iac-drift'),
    ('safe-delivery-strategies', 'lead-delivery-standard'),
    ('secrets-management-in-the-cloud', 'lead-secret-rotation'),
    ('secure-password-storage', 'junior-password-strength'),
    ('secrets-in-source-avoidance', 'junior-secret-detection'),
    ('security-headers-and-csp', 'junior-header-hardening'),
    ('input-validation-strategies', 'junior-input-sanitise'),
    ('sql-injection-prevention-java', 'mid-parameterised-query'),
    ('xss-prevention-java', 'mid-output-encoding'),
    ('csrf-protection-java', 'mid-csrf-token-check'),
    ('jwt-best-practices', 'mid-jwt-validation'),
    ('securing-rest-apis', 'mid-scope-check'),
    ('cryptography-basics-for-java-devs', 'senior-crypto-choice'),
    ('cryptography-basics-for-java-devs', 'senior-key-rotation'),
    ('security-logging-and-auditing', 'senior-audit-events'),
    ('supply-chain-security-slsa', 'senior-sbom-gate'),
    ('threat-modeling-basics', 'principal-threat-model'),
    ('data-governance', 'principal-security-policy'),
    ('json-with-jackson-basics', 'junior-json-field-read'),
    ('csv-and-tabular-data', 'junior-csv-row-parse'),
    ('yaml-for-configuration', 'junior-yaml-flatten'),
    ('jackson-polymorphic-serialization', 'mid-polymorphic-write'),
    ('json-schema-and-validation', 'mid-format-compatibility'),
    ('dates-numbers-and-locale-serialization', 'mid-number-precision'),
    ('dates-numbers-and-locale-serialization', 'mid-datetime-format'),
    ('deserialization-security', 'senior-deserialisation-safety'),
    ('streaming-large-payloads', 'senior-streaming-parse'),
    ('arrays-and-strings-patterns', 'junior-reverse-array'),
    ('big-o-in-practice', 'junior-find-maximum'),
    ('hashing-patterns', 'junior-count-occurrences'),
    ('arrays-and-strings-patterns', 'junior-remove-duplicates'),
    ('sorting-algorithms-in-depth', 'junior-sort-by-key'),
    ('hashing-patterns', 'mid-two-sum'),
    ('two-pointers-and-sliding-windows', 'mid-sliding-window'),
    ('choosing-data-structures-at-work', 'mid-lru-cache'),
    ('heaps-and-top-k', 'mid-top-k-frequent'),
    ('graphs-basics-bfs-dfs', 'mid-graph-bfs'),
    ('sorting-algorithms-in-depth', 'mid-merge-intervals'),
    ('shortest-path-intuition', 'senior-dijkstra'),
    ('dynamic-programming-intuition', 'senior-knapsack'),
    ('concurrent-collections-in-practice', 'senior-lru-threadsafe'),
    ('replacing-conditional-logic', 'junior-guard-clause'),
    ('extracting-methods-and-classes', 'junior-method-extraction'),
    ('removing-duplication-carefully', 'mid-duplication-detect'),
    ('replacing-conditional-logic', 'mid-strategy-extraction'),
    ('breaking-dependencies-in-legacy', 'mid-test-seam'),
    ('working-with-legacy-code', 'mid-legacy-risk'),
    ('incremental-framework-upgrades', 'senior-characterisation'),
    ('modularizing-a-monolith', 'senior-module-extraction'),
    ('dead-code-and-orphan-removal', 'senior-dead-code'),
    ('code-review-culture', 'junior-review-checklist'),
    ('asking-better-technical-questions', 'junior-question-quality'),
    ('estimating-work-realistically', 'mid-estimate-range'),
    ('blameless-incident-reviews', 'mid-incident-timeline'),
    ('documentation-and-knowledge-sharing', 'mid-onboarding-path'),
    ('growing-from-junior-to-senior', 'lead-growth-plan'),
    ('engineering-metrics-that-help', 'lead-metrics-choice'),
    ('stakeholder-communication', 'lead-stakeholder-brief'),
    ('long-term-java-strategy', 'principal-tech-strategy'),
    ('mentoring-junior-engineers', 'principal-org-design')
) AS m(tutorial_slug, challenge_slug)
JOIN tutorial t ON t.slug = m.tutorial_slug
JOIN challenge c ON c.slug = m.challenge_slug
WHERE NOT EXISTS (
    SELECT 1 FROM tutorial_challenge existing
    WHERE existing.tutorial_id = t.id AND existing.challenge_id = c.id
);

