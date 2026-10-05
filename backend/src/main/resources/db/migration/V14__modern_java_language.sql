-- V14 — Modern Java language tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('java-generics-in-depth', 'Generics, Bounds, and Wildcards', 'Use type parameters, bounds, and wildcards deliberately, and understand what erasure does to runtime behavior.', 'Mid', 30, true, 1),
    ('java-streams-in-depth', 'Streams, Pipelines, and Collectors', 'Build lazy stream pipelines, choose collectors, and know when parallel streams or plain loops are clearer.', 'Mid', 32, true, 1),
    ('java-optional-patterns', 'Optional Patterns for Missing Values', 'Model absence with Optional in return types, compose chains with map and flatMap, and avoid common misuse.', 'Mid', 26, true, 1),
    ('java-functional-interfaces', 'Functional Interfaces in Java', 'Compose java.util.function types, define custom functional interfaces, and handle checked exception friction at the edges.', 'Mid', 28, true, 1),
    ('java-pattern-matching', 'Pattern Matching in Modern Java', 'Match types, switch over patterns, and deconstruct records while keeping exhaustiveness and preview status in mind.', 'Senior', 36, true, 1),
    ('java-sealed-types', 'Sealed Types and Closed Domains', 'Model closed domains with sealed interfaces and classes, and let the compiler enforce exhaustive handling.', 'Senior', 32, true, 1),
    ('java-records-in-depth', 'Records in Depth', 'Use compact constructors, validation, and record patterns, and recognize when a record is the wrong tool.', 'Mid', 30, true, 1),
    ('java-text-blocks', 'Text Blocks for Readable Strings', 'Write multi-line strings with predictable indentation for SQL and JSON, and control escapes and newlines.', 'Junior', 22, true, 1),
    ('java-var-and-type-inference', 'Var and Local Type Inference', 'Use var for local variables where the initializer is clear, and keep explicit types where they communicate intent.', 'Junior', 18, true, 1),
    ('java-immutability-patterns', 'Immutability Patterns in Java', 'Protect shared state with final fields, defensive copies, immutable collections, and safe publication.', 'Junior', 26, true, 1),
    ('java-completable-future', 'Composing Work with CompletableFuture', 'Compose asynchronous work with thenCompose and thenCombine, handle failures, and avoid blocking get calls.', 'Senior', 38, true, 1),
    ('java-virtual-threads', 'Virtual Threads for Blocking I/O', 'Use virtual threads for blocking I/O, understand pinning, and manage thread-local state at scale.', 'Senior', 36, true, 1),
    ('java-structured-concurrency', 'Structured Concurrency in Practice', 'Understand structured concurrency concepts, its current preview status, and stable fallbacks while the API evolves.', 'Senior', 34, true, 1),
    ('java-locks-and-atomics', 'Locks, Atomics, and Contention', 'Choose among synchronized, ReentrantLock, atomics, and StampedLock by contention profile and required guarantees.', 'Lead', 42, true, 1),
    ('java-nio-and-file-io', 'NIO, Paths, and File Handling', 'Work with Path and Files, stream large files, set charsets, and replace files atomically.', 'Mid', 30, true, 1),
    ('java-reflection-and-annotations', 'Reflection and Annotation Retention', 'Use reflection at framework boundaries, choose annotation retention policies, and respect module access limits.', 'Mid', 30, true, 1),
    ('solid-principles-in-java', 'SOLID Principles in Java', 'Apply each SOLID principle with Java examples, and avoid the over-application that harms simple designs.', 'Mid', 32, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('java-generics-in-depth', 1, 'Type parameters catch mistakes early', $body$Generics let one class or method work across types while the compiler still verifies what each call site stores and reads. Prefer bounded parameters such as `T extends Comparable<T>` when the body calls methods on the type, and avoid raw types, which silently erase checking and produce warnings at every use. A type parameter that appears only in return position is descriptive rather than controlling, so verify that it matches the actual payload. The production payoff is fewer casts and failures moved from runtime to build time. When a public method returns a generic type, keep the parameter honest instead of returning broad `Object` values that push casting back to callers.$body$, $code$static <T extends Comparable<T>> T latest(List<T> values) {
    if (values.isEmpty()) {
        throw new IllegalArgumentException("values");
    }
    T best = values.get(0);
    for (T value : values) {
        if (value.compareTo(best) > 0) {
            best = value;
        }
    }
    return best;
}$code$),
    ('java-generics-in-depth', 2, 'Wildcards follow producer and consumer', $body$A bounded wildcard makes an API more flexible without weakening type safety. Use `? extends T` when a method only reads values from the argument, because any collection of a subtype will do; use `? super T` when a method writes values, because a collection of a supertype can accept them. This is the producer extends, consumer super rule, and copy helpers use both bounds at once. Wildcards on return types force callers to handle an unknown type for no benefit, so prefer a concrete type parameter there. A parameter that is both read and written usually needs an exact `T`.$body$, $code$static <T> void copy(List<? extends T> source, List<? super T> target) {
    for (T value : source) {
        target.add(value);
    }
}$code$),
    ('java-generics-in-depth', 3, 'Erasure shapes what survives', $body$Generic type arguments exist only at compile time and are erased from the running program. Consequently, code cannot create `new T[]`, cannot branch on `instanceof List<String>`, and cannot overload two methods that differ only in type arguments. If runtime type information is needed, pass a `Class<T>` token explicitly and use its cast method, which centralizes one checked cast. Generic varargs produce unchecked warnings because the compiler cannot guarantee the array contents; `@SafeVarargs` is a promise to make only when no reference to the array escapes. Prefer collections over generic arrays in public APIs, and treat every unchecked warning as a design question rather than noise.$body$, $code$record Typed<T>(Class<T> type) {
    T require(Object value) {
        return type.cast(value);
    }
}$code$),
    ('java-streams-in-depth', 1, 'Pipelines run only on demand', $body$Intermediate operations such as filter, map, and sorted only describe work; nothing executes until a terminal operation such as toList, count, or forEach requests a result. That laziness enables short-circuiting, so anyMatch can stop after the first match and never read the remaining elements. It also means an unused pipeline is dead code that looks busy. Side effects inside intermediate stages, including logging in peek, may run an unpredictable number of times and should not influence results. Build the pipeline logically, starting with a source, then transformations, then a terminal step whose name states what the caller receives.$body$, $code$List<String> services = List.of("svc-billing", "api-gateway");

Optional<String> firstMatch =
    services.stream()
        .filter(name -> name.startsWith("svc-"))
        .findFirst();

boolean anyApi = services.stream()
    .anyMatch(name -> name.startsWith("api-"));$code$),
    ('java-streams-in-depth', 2, 'Collectors concentrate the finishing work', $body$Collectors package reductions into reusable pieces, where groupingBy partitions elements by a classifier, partitioningBy splits on a predicate, and downstream collectors such as counting or mapping summarize each group. Choose the destination map deliberately, and remember that toMap throws when two elements share a key unless a merge function resolves the collision. Avoid collectors that depend on encounter order unless the source guarantees it. In production, a collector often expresses a report more clearly than any loop, but deeply nested downstream collectors hide intent. Extract such a reduction into a named method that documents the shape it produces, and test it with unordered input.$body$, $code$Map<String, Long> byStatus = orders.stream()
    .collect(Collectors.groupingBy(
        Order::status,
        Collectors.counting()));

long open = byStatus.getOrDefault("OPEN", 0L);$code$),
    ('java-streams-in-depth', 3, 'Parallel streams and plain loops', $body$Parallel streams fork work across the common pool, so they help CPU-bound transformations of large, easily splittable data and hurt when tasks block on I/O or share mutable state. They also make ordering, exception behavior, and resource usage harder to reason about, and the shared pool can starve unrelated callers. Measure before adopting parallelism, because a sequential stream is usually fast enough. Plain loops remain the better tool when you need an early exit, a mutable accumulator, or complex branch-specific behavior that a pipeline cannot express clearly. For custom intermediate operations, stream gatherers were finalized in JDK 24 and now cover cases that previously required a loop.$body$, $code$long runningTotal = 0;
for (Order order : orders) {
    if (order.cancelled()) {
        continue;
    }
    if (runningTotal + order.totalCents() > budgetCents) {
        break;
    }
    runningTotal += order.totalCents();
}$code$),
    ('java-optional-patterns', 1, 'Absence belongs in return types', $body$Optional communicates that a lookup may legitimately find nothing, so callers must decide what to do instead of forgetting a null check. It belongs in return positions, not in fields, method parameters, or collection elements, where it adds a wrapper without removing null and complicates equality, persistence, and serialization. Create values with Optional.of only when a null input would be a bug, use ofNullable for values that may be absent, and prefer orElseThrow with a meaningful domain exception at boundaries. Never call get without proof of presence. For primitives, OptionalInt and OptionalLong avoid boxing and make arithmetic intent explicit.$body$, $code$static Customer requireCustomer(Repository repo, String id) {
    return repo.findCustomer(id).orElseThrow(
        () -> new CustomerNotFoundException(id));
}

static void auditLookup(Repository repo, String id) {
    Optional<Customer> found = repo.findCustomer(id);
    found.ifPresent(customer -> audit.record(customer.id()));
}$code$),
    ('java-optional-patterns', 2, 'Chains replace nested checks', $body$map transforms a present value without unwrapping it, filter drops values that fail a predicate, and flatMap handles transformations that themselves return an Optional, preventing nested wrappers. Chained calls read as a sequence of decisions and replace the isPresent block that hides a branch. Use or to fall back to another source lazily and orElseGet when the fallback is expensive, since orElse evaluates its argument eagerly even when a value exists. Keep chains honest about failure, because returning a default can hide a broken invariant; choose defaults that are valid business outcomes rather than placeholders that mask bugs. Prefer a chain over nested conditionals, but stop before it becomes a puzzle.$body$, $code$static String billingEmail(Customer customer) {
    return Optional.ofNullable(customer.contact())
        .map(Contact::email)
        .filter(email -> !email.isBlank())
        .orElse("billing@example.com");
}$code$),
    ('java-optional-patterns', 3, 'Keep Optional out of structures', $body$Optional is a small value type for method results; embedding it in entities, map values, or request records spreads wrappers through every layer and interacts badly with frameworks that reflect over fields. A getter that returns Optional for a field that is never absent weakens the model, while a plain accessor plus a separate query method can be clearer. At application boundaries, decide once whether absence is expressed as null, as Optional, or as a domain-specific empty object, and convert at the edge rather than mixing conventions. Returning Optional from a mapper is reasonable; storing it is usually a design smell. Document the convention in the type itself.$body$, $code$Optional<Invoice> invoice = findInvoice(order.id());

PdfDocument document = invoice
    .flatMap(Invoice::pdf)
    .map(PdfDocument::render)
    .orElseGet(PdfDocument::empty);

if (invoice.isEmpty()) {
    log.warn("No invoice for order {}", order.id());
}$code$),
    ('java-functional-interfaces', 1, 'Pick the narrowest function type', $body$The java.util.function package offers shapes for the common cases, where Function transforms, Predicate tests, Consumer accepts, Supplier produces, and the operator types combine values of the same type. Specialized variants such as IntFunction or ToLongFunction avoid boxing on hot paths, which matters in tight loops and stream pipelines over primitives. Choosing the narrowest interface keeps signatures readable and tells callers exactly what the parameter does. Avoid inventing a new interface when a standard one communicates the same idea; reserve custom types for when a domain name adds real meaning or the signature differs from every standard shape. Fewer custom types means less vocabulary for reviewers to learn.$body$, $code$Predicate<String> blank = String::isBlank;
Predicate<String> useful = blank.negate();

Function<Order, Receipt> toReceipt = billing::render;
Function<Order, String> summarize = toReceipt.andThen(Receipt::summary);

if (useful.test(summarize.apply(order))) {
    archive(order);
}$code$),
    ('java-functional-interfaces', 2, 'Compose small functions deliberately', $body$Function composition builds a pipeline of small steps, where andThen runs the first function and passes its result to the second, compose does the reverse, and Predicate offers and, or, and negate. Small composed functions are easy to test alone and reuse across call sites. Long chains still read top to bottom but can obscure the data flow, so extract named steps when a composition exceeds a few links. Watch for double execution, because composing two functions that each call a remote service turns one logical operation into two, which is easy to miss when the composition is assembled in another class. Name composed functions after the decision they represent.$body$, $code$@FunctionalInterface
interface DiscountRule {
    long discountCents(Order order);
}

DiscountRule overThreshold = order ->
    order.totalCents() >= 5000 ? 500 : 0;$code$),
    ('java-functional-interfaces', 3, 'Checked exceptions at the edges', $body$Core functional interfaces do not declare checked exceptions, so a lambda that reads a file or opens a connection cannot throw them directly. The usual answer is to handle the exception inside the lambda and convert it into a domain exception that callers already understand. Wrappers that rethrow checked exceptions through unchecked types hide failures from the compiler and surprise maintainers, so prefer an explicit adapter that documents the conversion. Keep I/O at the outer edges of the application and pass already-loaded data into functional pipelines, and you will rarely fight this friction. When a conversion happens, include the original cause so diagnostics survive.$body$, $code$@FunctionalInterface
interface ThrowingSupplier<T> {
    T get() throws Exception;
}

static <T> T unwrap(ThrowingSupplier<T> supplier) {
    try {
        return supplier.get();
    } catch (Exception failure) {
        throw new IllegalStateException(failure);
    }
}$code$),
    ('java-pattern-matching', 1, 'Instanceof patterns remove casts', $body$A type pattern inside instanceof tests and binds the value in one step, so the old test-then-cast idiom disappears along with the possibility of casting the wrong variable. The pattern variable is definitely assigned only where the compiler can prove the test succeeded, which keeps reads safe inside the guarded branch. Flow scoping means the variable may remain usable after the if statement when the condition guarantees the match, a subtle rule worth checking with the compiler rather than guessing. Prefer patterns whenever a cast follows an instanceof; the two-line form is a relic that reviewers should flag. Unnamed patterns and variables, finalized in JDK 22, allow the underscore form when a component is deliberately ignored.$body$, $code$static int length(Object value) {
    if (value instanceof String text) {
        return text.length();
    }
    if (value instanceof Collection<?> items) {
        return items.size();
    }
    return 0;
}$code$),
    ('java-pattern-matching', 2, 'Switch patterns and exhaustiveness', $body$Pattern matching for switch, finalized in JDK 21, allows case labels that test types, null behavior that is now explicit, and guarded labels written with when. When the selector type is sealed or an enum, the compiler can verify that every possibility is handled, so adding a new permitted subtype becomes a compile error instead of a runtime surprise. Keep the switch expression form when each branch must produce a value, because the compiler enforces assignment on every path. A default clause silences exhaustiveness checking, so use it only for genuinely open inputs. Ordering matters, since a subtype label must appear before a broader one.$body$, $code$static String describe(Shape shape) {
    return switch (shape) {
        case Circle circle -> "circle r=" + circle.radius();
        case Rectangle rectangle -> "rect " + rectangle.width();
        default -> "unknown shape";
    };
}$code$),
    ('java-pattern-matching', 3, 'Deconstruct records in patterns', $body$Record patterns, finalized in JDK 21, take a record apart with a nested pattern that both tests the type and binds components, and they compose to arbitrary depth. A nested pattern reading a range from a wrapping type avoids chains of temporary locals that obscure which values matter. The compiler checks that the pattern shape matches the record declaration, so a changed component list fails the build at every matching site, which is exactly the attention such a change deserves. Use unnamed patterns for components that do not affect behavior. Relevant previews have continued to evolve, so confirm the status of primitive type patterns and similar extensions before using them in production code.$body$, $code$static double span(Message message) {
    return switch (message) {
        case Reading(int low, int high) -> high - low;
        case Alert(Reading range, String level) ->
            range.high() - range.low();
        default -> 0;
    };
}$code$),
    ('java-sealed-types', 1, 'Close a hierarchy on purpose', $body$A sealed interface or class lists the permitted subtypes with permits, or relies on co-location to infer them, so only those types may implement it. This expresses a closed domain where the author knows every case, which is exactly what exhaustive switches and safer evolution require. Sealed types describe semantics, not package privacy, because permitted subtypes can live elsewhere in the same module. Keep the hierarchy shallow and let each permitted type carry behavior, rather than turning the sealed root into a dumping ground for shared code. Sealed types were finalized in JDK 17 and are a stable language feature, not preview.$body$, $code$sealed interface LedgerEntry
        permits Deposit, Withdrawal, Transfer {}

record Deposit(String account, long cents) implements LedgerEntry {}
record Withdrawal(String account, long cents) implements LedgerEntry {}
record Transfer(String from, String to, long cents) implements LedgerEntry {}$code$),
    ('java-sealed-types', 2, 'Exhaustive handling without defaults', $body$Sealed roots and pattern switches work together, because the compiler knows the complete set of subtypes and verifies that a switch expression handles all of them. That means a new permitted subtype breaks every non-exhaustive switch at compile time, forcing an explicit decision instead of a silent default path. Keep the switch exhaustive and avoid a catch-all default, which would re-open the domain the seal just closed. Place the switch where behavior must be decided, and keep arithmetic or formatting logic in small methods on each subtype. This combination is the main production payoff of sealing: correctness pressure applied by the compiler.$body$, $code$static long signedAmount(LedgerEntry entry) {
    return switch (entry) {
        case Deposit deposit -> deposit.cents();
        case Withdrawal withdrawal -> -withdrawal.cents();
        case Transfer transfer -> -transfer.cents();
    };
}$code$),
    ('java-sealed-types', 3, 'Choosing sealing versus extension', $body$Sealing suits domains that are genuinely finite today, such as job outcomes, payment results, or protocol messages, and it documents that assumption where the type is declared. It fits poorly when extension is an intended feature, such as plugin interfaces or framework extension points, because every new implementer would require editing the API owner. Weigh the operational cost of exhaustive switches: adding a subtype is meant to be disruptive, and teams that dislike that should revisit the domain model rather than weaken the seal. Keep permitted types near the root so the list stays easy to audit, and consider non-sealed only when a supporting extension path is truly required.$body$, $code$sealed interface JobResult permits JobResult.Done, JobResult.Failed {
    record Done(String output) implements JobResult {}
    record Failed(String reason) implements JobResult {}
}

static String describe(JobResult result) {
    return switch (result) {
        case JobResult.Done done -> "done: " + done.output();
        case JobResult.Failed failed -> "failed: " + failed.reason();
    };
}$code$),
    ('java-records-in-depth', 1, 'Compact constructors enforce invariants', $body$A record declares its state through components that generate a canonical constructor, accessors, equals, hashCode, and toString, all of which suit transparent value carriers. A compact constructor lets you validate or normalize before the fields are assigned, and reassigning the parameter changes what is stored. Copy mutable inputs such as lists here, because record fields are final references but the referents can still change. Records were finalized in JDK 16 and are stable. They are not a replacement for every class: behavior-rich entities, objects with identity, and types that must extend a class all remain ordinary classes.$body$, $code$record Money(long cents, Currency currency) {
    Money {
        if (cents < 0) {
            throw new IllegalArgumentException("cents");
        }
        Objects.requireNonNull(currency, "currency");
    }
}$code$),
    ('java-records-in-depth', 2, 'Record patterns reuse the shape', $body$Record patterns deconstruct a record into its components, which pairs naturally with sealed roots so callers can switch over a closed domain of data carriers. Prefer patterns over manual accessor chains when the switch already establishes the type, and name components in the pattern so the mapping stays readable. Validation performed in a compact constructor still applies, because patterns bind what was actually stored. Avoid hiding expensive work behind accessors, since callers reasonably assume record reads are cheap. The record pattern feature is final in JDK 21, but related extensions such as primitive patterns remain preview, so check a feature status before relying on it.$body$, $code$static String label(Payment payment) {
    return switch (payment) {
        case Card(String last4, long cents) -> "card " + last4;
        case Cash(long cents) -> "cash";
        default -> "other";
    };
}$code$),
    ('java-records-in-depth', 3, 'When not to use a record', $body$A record is the wrong tool when the type has a lifecycle, when equality should not compare all state, or when a small change to the public shape must remain source-compatible. Records also expose every component through generated accessors and the canonical constructor, so they cannot hide internal representation while preserving the same API, and they cannot extend another class. Records that end up with dozens of components usually indicate a missing aggregate or a grouping that should become its own type. When a value needs only a couple of states, consider an enum or a dedicated small class instead. Let the shape of the data choose the construct.$body$, $code$record Connection(String host, int port) {
    URI toUri() {
        return URI.create("tcp://" + host + ":" + port);
    }
}

Connection primary = new Connection("db.internal", 5432);$code$),
    ('java-text-blocks', 1, 'Opening delimiters and incidental whitespace', $body$A text block starts with three double quotes followed by a line terminator, and the compiler removes incidental indentation shared by all content lines while keeping deliberate extra indentation. The closing delimiter position controls that common margin, so move it to tune the result. Escapes work as usual, and the backslash line-continuation escape joins lines without inserting a newline, which is useful for long SQL fragments. Text blocks were finalized in JDK 15. Use them for embedded SQL, JSON, or HTML rather than building strings from concatenation, and verify the resulting indentation with a test, because invisible margin errors are a common source of confusing comparisons.$body$, $code$String query = """
    SELECT id, status
    FROM job
    WHERE status = ?
    ORDER BY id
    """;$code$),
    ('java-text-blocks', 2, 'Escapes and embedded quotes', $body$Inside a text block, quotes no longer need escaping unless three appear consecutively, so JSON stays legible. Backslash escapes such as the newline form and the escaped quote still apply, and a trailing backslash at a line end suppresses that line break entirely. Interpolation does not exist in standard Java: string templates were previewed in recent releases, and the JEP that would have finalized them was withdrawn, so build dynamic text with concatenation, a formatter, or a dedicated library instead. Keep dynamic fragments out of the block and assemble them with an explicit method call, which keeps the template readable and testable. Avoid storing secrets directly in source text.$body$, $code$String payload = """
    {"service": "billing", "enabled": true}
    """.strip();

String body = """
    {"trace": "%s", "result": %d}
    """.formatted(traceId, count);$code$),
    ('java-text-blocks', 3, 'Normalize before comparing', $body$Line endings in a text block are normalized to a single newline character, which removes an entire class of platform-dependent bugs in expected values and fixtures. When embedding SQL or JSON that other systems consume, consider stripping leading and trailing blank lines with strip, and state clearly whether indentation inside the payload matters. For machine parsing, a text block is still just a string, so prefer a real parser or formatter over hand-built content. Compare normalized values in tests rather than raw source, and keep large documents in resource files when they grow beyond a few lines, because compiled-in text cannot be edited without a rebuild.$body$, $code$String expected = """
    {
      "status": "READY"
    }
    """.strip();

boolean matches = expected.equals(normalize(actual));$code$),
    ('java-var-and-type-inference', 1, 'Var only when obvious', $body$The var keyword infers the type of a local variable from its initializer, and it works only for locals, for-each variables, try-with-resources variables, and lambda parameters with annotations. It does not exist for fields, method parameters, or return types, so it can never change an API signature. The rule of thumb is that the name plus the right-hand side should make the type unmistakable, as with constructors or factory calls that state it. When the inferred type is surprising, such as a raw stream call returning a wildcarded collection, use an explicit type or split the expression so a reader is not misled. Inference was added by JEP 286 in Java 10 and is stable.$body$, $code$var jobs = new ArrayList<Job>();
var deadline = Instant.now().plus(Duration.ofMinutes(5));
var lookup = Map.of("queued", 3, "running", 1);

for (var job : jobs) {
    schedule(job, deadline);
}

long queued = lookup.getOrDefault("queued", 0);$code$),
    ('java-var-and-type-inference', 2, 'When inference hurts readability', $body$Var reduces duplication on both sides of an assignment, but it also removes the one place a reader used to find the type without opening another file. Short names such as var x = result() force readers to hunt for the return type, so prefer descriptive names and keep initializers close to use. Var works well for short-lived locals inside a method and poorly when a value crosses a boundary the reader cannot see. Team style matters more than the keyword itself, so pick one convention and apply it consistently. If a reviewer must follow three calls to learn a type, that is a signal to write the type explicitly.$body$, $code$var entries = expensiveLookup();

long totalCents = 0;
for (var entry : entries) {
    totalCents += entry.amountCents();
}
log.info("scanned {} entries", entries.size());$code$),
    ('java-var-and-type-inference', 3, 'Var with resources and lambdas', $body$In a try-with-resources header, var infers the resource type from the initializer, which shortens noisy chains and keeps the close behavior identical. Lambda parameters may use var, but only when annotated, since annotations on inferred parameters require an explicit type token. Avoid mixing var and explicit types arbitrarily within one method, because inconsistency makes the inference harder to trust. Remember that var does not avoid the cast or the generics that the initializer already declares, so it never fixes a design problem in the expression. It is syntax compression, not a semantic change.$body$, $code$try (var connection = dataSource.getConnection();
     var statement = connection.prepareStatement(SQL)) {
    statement.setString(1, jobId);
    try (var results = statement.executeQuery()) {
        while (results.next()) {
            consume(results.getString("status"));
        }
    }
}$code$),
    ('java-immutability-patterns', 1, 'Final fields and defensive copies', $body$An immutable object never changes after construction, so any thread can share it without synchronization. Mark fields final, keep referenced objects immutable as well, and copy mutable inputs and outputs so callers cannot reach the internal state. The copy must happen on the way in and on the way out, because one-sided copying still leaks a mutable view. Records help, but they are only shallowly immutable, so a record holding a list still needs a compact constructor that copies it. Immutability is a design commitment rather than a keyword, and the payoff is code that is easy to reason about, cache, and use as a map key.$body$, $code$final class Route {
    private final List<String> stops;

    Route(List<String> stops) {
        this.stops = List.copyOf(stops);
    }

    List<String> stops() {
        return stops;
    }
}$code$),
    ('java-immutability-patterns', 2, 'Immutable collections and views', $body$List.of, Set.of, and Map.of create compact immutable collections that reject nulls and duplicates at creation, and List.copyOf and Map.copyOf take a protective snapshot of an existing collection. These snapshots are exact copies, so later changes to the source collection do not appear in the destination. The unmodifiable wrappers behave differently, because they are live views that still change when the backing collection changes, which surprises callers who assume stability. In shared caches and configuration objects, prefer copies. Sequenced collections, added in JDK 21, give the same APIs for first and last elements across list-like structures while preserving immutability where declared.$body$, $code$List<String> regions = List.copyOf(configured);
Set<Tag> tags = Set.of(Tag.URGENT, Tag.BILLING);
Map<String, Integer> limits = Map.of(
    "queued", 10,
    "running", 4);$code$),
    ('java-immutability-patterns', 3, 'Safe sharing across threads', $body$Immutable objects are automatically thread-safe only when they are also safely published, meaning other threads see fully constructed state, which final fields guarantee when the object reference is not published unsafely. Confinement through local variables and method parameters still beats shared mutable state, and any remaining mutable fields need synchronization or an atomic type. Prefer rebuilding a new value over mutating a shared one, and keep updates close to the mutation point so readers can follow the data flow. For counters and accumulators under concurrency, atomic classes are the immutable-friendly choice because they encapsulate the transition in one operation.$body$, $code$final class ServerConfig {
    private final int port;
    private final List<String> hosts;

    ServerConfig(int port, List<String> hosts) {
        this.port = port;
        this.hosts = List.copyOf(hosts);
    }
}$code$),
    ('java-completable-future', 1, 'Compose instead of nesting', $body$CompletableFuture chains asynchronous stages with thenApply for a transformation, thenCompose when the next step returns another future, and thenCombine when two independent results must meet. Compose flattens what would otherwise become a nested future of a future, which is the asynchronous version of the flatMap rule. Each stage runs on whichever thread completes the previous one unless an executor is supplied, so clearly bound blocking work to your own executor rather than the common pool. Return the future to the caller instead of joining inside a helper, which keeps composition available at higher levels.$body$, $code$CompletableFuture<Receipt> process(Order order) {
    return loadCustomer(order.customerId())
        .thenCompose(customer -> reserve(order))
        .thenCombine(loadTaxRate(order), Billing::renderReceipt);
}$code$),
    ('java-completable-future', 2, 'Failure paths are part of the pipeline', $body$A failed stage is skipped and the failure propagates to dependents, so handle, exceptionally, and whenComplete decide how the chain recovers or reports. Handle receives either a result or a failure and always produces a value, which suits converting a technical failure into a domain outcome. Exceptionally recovers only from failure and keeps the value otherwise. Keep compensation logic inside the chain rather than wrapping the whole pipeline in a try block, because join and get throw wrapped exceptions that are easy to misread. Always log or propagate the original cause, since losing it turns an actionable incident into a mystery.$body$, $code$CompletableFuture<Result> safe =
    charge(order)
        .handle((receipt, failure) ->
            failure == null
                ? Result.ok(receipt)
                : Result.failed(failure));$code$),
    ('java-completable-future', 3, 'Executors and acceptable blocking', $body$The default async methods use the common ForkJoinPool, which is sized for CPU-bound work and shared across the JVM, so a single slow blocking task can starve unrelated pipelines. Supply an executor when the work blocks on I/O, and set a timeout at the boundary where the caller actually waits, since neither orTimeout nor completeOnTimeout cancels the underlying operation. Avoid calling get on the request path; prefer returning the future to the framework or chaining all the way to a terminal stage. For straightforward blocking request handling, a virtual thread executor is often simpler than a deep CompletableFuture chain, and it composes well with existing sequential code.$body$, $code$try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    CompletableFuture<Response> future =
        CompletableFuture.supplyAsync(() -> fetch(id), executor)
            .orTimeout(2, TimeUnit.SECONDS);
}$code$),
    ('java-virtual-threads', 1, 'Create threads that scale', $body$Virtual threads are lightweight threads scheduled by the JDK rather than the operating system, so applications can run millions of them while the carrier pool stays small. Finalized in JDK 21, they suit thread-per-request code that spends its time waiting on blocking I/O, such as HTTP calls, JDBC, or file access. They do not make CPU-bound work faster, and they do not fix a connection pool that is too small; throughput still obeys the slowest dependency. Use Thread.ofVirtual or a virtual-thread-per-task executor, keep tasks independent, and avoid depending on the number of carriers. Pools of virtual threads are usually an anti-pattern, since each task can simply own a thread.$body$, $code$try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    Future<Profile> profile = executor.submit(() -> loadProfile(id));
    Future<Orders> orders = executor.submit(() -> loadOrders(id));
    return new Page(profile.get(), orders.get());
}$code$),
    ('java-virtual-threads', 2, 'Pinning and blocking traps', $body$A virtual thread is pinned when it cannot unmount from its carrier, and older releases pinned on synchronized blocks that block inside them. Modern releases, starting with the work delivered in JDK 24, removed nearly all of that pinning, so synchronized code no longer bleeds platform threads the way it once did. Native calls and a few remaining constructs can still pin, so diagnostics matter more than folklore: run with the thread dump or the JDK Flight Recorder event for pinned threads and fix what the evidence shows. Also check that blocking drivers and libraries are virtual-thread friendly, and keep pool sizes for external resources explicit.$body$, $code$System.out.println(Thread.currentThread());
Thread worker = Thread.ofVirtual()
    .name("profile-loader")
    .start(() -> load(id));
worker.join();$code$),
    ('java-virtual-threads', 3, 'Thread-locals and context under load', $body$Every virtual thread can carry thread-local variables, and many frameworks use them for security or transaction context, but a thread local per task multiplies memory once there are huge numbers of threads, and inherited values can leak between unrelated tasks. Prefer explicit parameters or scoped values, finalized in JDK 25, for immutable request context that callees read and children inherit. Avoid caching expensive objects such as formatters in a thread local, because virtual threads are short-lived and each instance would be created again. Keep context propagation at clear boundaries, and document what a downstream layer may assume about the current thread. Diagnostics are easier when context lives in plain values.$body$, $code$private static final ScopedValue<String> TRACE =
    ScopedValue.newInstance();

ScopedValue.where(TRACE, traceId)
    .run(() -> handle(request));

String current = TRACE.orElse("no-trace");$code$),
    ('java-structured-concurrency', 1, 'Scoped subtasks with clear lifetimes', $body$Structured concurrency treats a group of related subtasks as one unit of work whose lifetime is confined to a lexical scope, so a failure cancels the siblings and interruption propagates automatically. This removes the classic thread leak where one ExecutorService task fails while another keeps running for minutes. The shape to expect is a try-with-resources scope that forks subtasks, joins them, and exposes their results, with each subtask short-lived and independent. Structured concurrency solves coordination and cancellation; virtual threads solve the cost of blocking threads. The two are complementary, and neither replaces the other. Model the scope so that every exit path cancels outstanding work.$body$, $code$try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    var tasks = List.of(
        (Callable<String>) () -> findUser(id),
        (Callable<String>) () -> fetchOrder(id));
    for (Future<String> result : executor.invokeAll(tasks)) {
        handle(result.get());
    }
}$code$),
    ('java-structured-concurrency', 2, 'Current API status and shape', $body$StructuredTaskScope has been a preview API for several releases now, and its shape has changed more than once: early versions used subclassing with shutdown policies, then factory methods replaced public constructors, and the join policy moved into a Joiner type. It remains preview in the most recent releases, so production use requires compiling with preview features enabled and accepting that the API may change again. Verify the status and exact names against the JEP for the release you target before writing code. Concepts such as scoped lifetimes, cancellation on failure, and bounded subtask results are stable even while the surface syntax evolves, so design around those ideas.$body$, $code$// Preview API shape; requires --enable-preview
try (var scope = StructuredTaskScope.open()) {
    var user = scope.fork(() -> findUser(id));
    var order = scope.fork(() -> fetchOrder(id));
    scope.join();
    return new Page(user.get(), order.get());
}$code$),
    ('java-structured-concurrency', 3, 'Stable fallbacks while preview evolves', $body$When a preview API is not acceptable for production, ExecutorService with invokeAll already groups subtasks and cancels the rest when a task fails or the caller is interrupted, which covers many of the same reliability goals with stable syntax. Add explicit timeouts on the waiting side, propagate interruption by restoring the interrupt flag, and make subtasks idempotent so a cancellation retry is safe. Handle cancellation as a distinct outcome rather than letting it surface as a generic failure, because a timed-out task was never completed. Wrap submission and waiting so the lifetime of every task is visible in one method, since unstructured futures scattered across layers recreate the leaks structured concurrency prevents. Keep this cancellation discipline even after the preview API finalizes.$body$, $code$try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (Future<String> future : executor.invokeAll(
            tasks, 2, TimeUnit.SECONDS)) {
        consume(future.get());
    }
} catch (InterruptedException interrupted) {
    Thread.currentThread().interrupt();
} catch (CancellationException cancelled) {
    log.warn("a subtask was cancelled by timeout");
}$code$),
    ('java-locks-and-atomics', 1, 'Synchronized is the default choice', $body$The synchronized keyword provides mutual exclusion and a happens-before relationship, so a write inside one critical section is visible to the next thread that enters it. Prefer it for short, uncontended critical sections that guard a small set of fields, and document the invariant the lock protects. Hold locks for the shortest time possible and never call foreign code while holding one, because long critical sections serialize throughput and invite deadlocks. Lock ordering must be global and consistent; two locks acquired in opposite orders will eventually deadlock. When the critical section includes blocking I/O or must support try-lock, choose a more expressive lock instead, and measure contention before adding complexity.$body$, $code$final class Counter {
    private final Object lock = new Object();
    private long total;

    void add(long delta) {
        synchronized (lock) {
            total += delta;
        }
    }

    long total() {
        synchronized (lock) {
            return total;
        }
    }
}$code$),
    ('java-locks-and-atomics', 2, 'Atomics and advanced locks', $body$AtomicLong and AtomicReference replace a lock with a compare-and-set retry loop, which scales well when many threads update a single counter or state reference. For read-mostly structures, StampedLock offers an optimistic read that avoids locking entirely; the read result must be validated with a stamp, and the pattern is easy to get wrong, so use it only after profiling shows reader contention. ReentrantLock adds tryLock with a timeout, interruptible acquisition, and fair mode, and ReentrantReadWriteLock helps when reads vastly outnumber writes. Note that a virtual thread blocking inside a monitor is no longer badly pinned in recent releases, so the old advice to avoid synchronized with virtual threads needs re-checking against your JDK.$body$, $code$private final AtomicLong submitted = new AtomicLong();

boolean accepted(long limit) {
    long current = submitted.incrementAndGet();
    if (current > limit) {
        submitted.decrementAndGet();
        return false;
    }
    return true;
}$code$),
    ('java-locks-and-atomics', 3, 'Choose by contention profile', $body$Start with synchronized, then move to an atomic when measurements show a hot counter, and only then consider StampedLock or read-write locks where a read-mostly profile justifies the extra complexity. Each step trades simplicity for a narrower guarantee, so the reason should be recorded where the next engineer will find it. Volatile provides visibility but not atomicity, so it cannot protect a check-then-act sequence. Keep the guarded state in one place, prefer immutability over coordination, and remember that reducing shared mutable state is often faster than any lock choice. Treat lock-free designs as a last resort that demands stress tests before it earns trust.$body$, $code$final StampedLock lock = new StampedLock();

long read() {
    long stamp = lock.tryOptimisticRead();
    long value = shared;
    if (!lock.validate(stamp)) {
        stamp = lock.readLock();
        try {
            value = shared;
        } finally {
            lock.unlockRead(stamp);
        }
    }
    return value;
}$code$),
    ('java-nio-and-file-io', 1, 'Paths, Files, and explicit failures', $body$Path and Files replaced much of the older File API and make intent explicit: reading a whole file, listing a directory, or checking existence are separate calls that throw informative exceptions. Always specify a charset, because a platform default differs between machines and corrupts data silently; use StandardCharsets.UTF_8 for interchange formats. Prefer Path.of and resolve to build locations instead of string concatenation, and validate any path that comes from outside the application to prevent traversal. Handle IOException where the operation happens; it signals a real environmental failure that callers should see rather than swallow.$body$, $code$Path input = Path.of("data", "orders.csv");

List<String> lines = Files.readAllLines(input, StandardCharsets.UTF_8);

Path output = Path.of("out").resolve("summary.txt");
Files.createDirectories(output.getParent());
Files.writeString(output, summarize(lines), StandardCharsets.UTF_8);$code$),
    ('java-nio-and-file-io', 2, 'Stream large files in constant memory', $body$Files.readAllLines is convenient but loads the entire file, so it fails on inputs that exceed heap and blocks longer than necessary. Files.lines returns a lazy stream that reads incrementally and must be closed, which makes try-with-resources the right shape; pair it with a cheap aggregation or a bounded buffer. For binary data, use buffered streams and a fixed-size buffer, and never trust a length header before allocating. Always close what you open. If the file feeds a batch job, decide whether partial results are acceptable on failure, because streaming couples reading to processing in ways that are harder to retry.$body$, $code$try (Stream<String> lines = Files.lines(path, StandardCharsets.UTF_8)) {
    long failed = lines
        .map(this::parse)
        .filter(Record::isFailed)
        .count();
    return failed;
}$code$),
    ('java-nio-and-file-io', 3, 'Temp files and atomic replacement', $body$Write a new version beside the target and move it into place so readers never observe a half-written file. Files.createTempFile creates a unique file in a controlled directory, and Files.move with the atomic-move option replaces the target when the same filesystem supports it. Check the returned result, because atomicity is best effort when the move crosses filesystems. Delete temporary files in finally blocks or use delete-on-close, and set restrictive permissions for files that contain sensitive data since temporary directories are shared. For configuration reloads, an atomic replace gives readers either the old or the new content, never a mix.$body$, $code$Path temp = Files.createTempFile(dir, "config-", ".tmp");
try {
    Files.writeString(temp, rendered, StandardCharsets.UTF_8);
    Files.move(temp, target,
        StandardCopyOption.REPLACE_EXISTING,
        StandardCopyOption.ATOMIC_MOVE);
} finally {
    Files.deleteIfExists(temp);
}$code$),
    ('java-reflection-and-annotations', 1, 'Reflection costs and its boundaries', $body$Reflection discovers types and members at runtime, which frameworks rely on for dependency injection, mapping, and serialization. Each reflective lookup is slower than a direct call, and the gap grows when access checks or argument boxing are involved, so cache Method, Field, or Constructor handles instead of searching repeatedly in a loop. Reflection also defeats IDE navigation and compile-time checking, so keep it inside infrastructure code and expose ordinary typed methods to the rest of the application. Prefer method handles or the newer class-file and varhandle APIs for hot paths, and treat reflection as a boundary tool rather than a routine programming style.$body$, $code$Method method = type.getDeclaredMethod("render", Request.class);
method.setAccessible(true);

long started = System.nanoTime();
String rendered = (String) method.invoke(component, request);
long micros = (System.nanoTime() - started) / 1_000;

if (micros > budgetMicros) {
    log.warn("reflective render took {} us", micros);
}$code$),
    ('java-reflection-and-annotations', 2, 'Retention decides who can see it', $body$An annotations retention policy determines its lifetime: SOURCE is discarded by the compiler for tools such as linters, CLASS survives into the class file for bytecode analysis, and RUNTIME stays visible to reflection at run time. Only RUNTIME annotations can be inspected by a framework through reflection, and marking everything RUNTIME adds class-file metadata for a capability nothing uses. State a target as well, because an annotation without a target can land anywhere and mislead readers. When designing framework annotations, document both the retention and the target because consumers depend on those choices. A retention change is a breaking change for tools that read it.$body$, $code$@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Audited {
    String value() default "default";
}$code$),
    ('java-reflection-and-annotations', 3, 'Module limits and alternatives', $body$The module system restricts reflective access across module boundaries: deep reflection into another module is denied unless the module opens the package or the annotation is explicitly exported. Applications that Upgrade frameworks sometimes need to open packages via command-line flags or module descriptors, which is a deliberate concession rather than a default. Check accessibility before invoking members and fail with a message naming the module and package, because the default exception is easy to misread. Prefer service providers, explicit factories, or annotation processors when they can replace runtime discovery, and reserve reflection for where its late binding genuinely pays for the opacity it adds.$body$, $code$Constructor<Handler> constructor = type.getDeclaredConstructor();

if (!constructor.canAccess(null)) {
    throw new IllegalStateException(
        "Open package " + type.getPackageName() + " to instantiate");
}$code$),
    ('solid-principles-in-java', 1, 'Single responsibility and open closed', $body$Single responsibility means a class has one reason to change, not that it contains one method, so group code by the actor it serves: HTTP parsing, pricing rules, and persistence each change for different reasons. The open-closed principle says behavior should be extendable without editing stable code, which Java supports through interfaces, composition, and sealed hierarchies when the set of variants is intentionally fixed. Both principles push work toward small collaborators, and both can be overused: splitting a cohesive class into fragments that each need the same parameters makes the design harder to follow, and creating an extension point for the first variant adds indirection with no payoff. Extract a seam when a second use case appears, not before.$body$, $code$interface DiscountPolicy {
    long discountCents(Order order);
}

final class NoDiscount implements DiscountPolicy {
    public long discountCents(Order order) {
        return 0;
    }
}$code$),
    ('solid-principles-in-java', 2, 'Liskov and interface segregation', $body$Liskov substitution means a subtype must honor the contract of its supertype, including preconditions, postconditions, and thrown exceptions, so an implementation that rejects an input the base type accepts is a design error rather than a caller mistake. Common violations arrive through inheritance used only for reuse, which is why composition is usually safer. Interface segregation favors several small role interfaces over one broad interface that forces implementers to stub methods they do not support, and it keeps test doubles honest. The over-application appears as dozens of one-method interfaces that exist only to satisfy a diagram. Merge interfaces when callers always use them together, and keep roles that genuinely vary independently separate.$body$, $code$interface Reader {
    String read(String key);
}

interface Writer {
    void write(String key, String value);
}

final class CacheClient implements Reader, Writer {
    public String read(String key) {
        return store.get(key);
    }

    public void write(String key, String value) {
        store.put(key, value);
    }
}$code$),
    ('solid-principles-in-java', 3, 'Dependency inversion without ceremony', $body$Dependency inversion says high-level policy should depend on abstractions owned by that policy, with details injected from outside, so a service defines the port it needs rather than importing a concrete client. In Java, the abstraction is usually a small interface, and construction-time injection through the constructor keeps required dependencies visible and testable. The over-application is introducing an interface for every class and a container for every object graph, which multiplies names without enabling a second implementation. Add an abstraction at points where policy must outlive a technology choice, where tests need to substitute behavior, or where two real implementations exist. Keep everything else direct and concrete, and let the compiler find the places that need a seam.$body$, $code$interface Clock {
    Instant now();
}

final class TokenService {
    private final Clock clock;

    TokenService(Clock clock) {
        this.clock = clock;
    }
}$code$)
) AS s(slug, sort_order, title, body, starter_code)
JOIN tutorial t ON t.slug = s.slug
WHERE NOT EXISTS (
    SELECT 1
    FROM tutorial_section existing
    WHERE existing.tutorial_id = t.id AND existing.sort_order = s.sort_order
);

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id, t.id,
       COALESCE((SELECT MAX(existing.sort_order)
                 FROM learning_path_tutorial existing
                 WHERE existing.learning_path_id = lp.id), 0)
       + ROW_NUMBER() OVER (PARTITION BY lp.id ORDER BY t.slug)
FROM learning_path lp
JOIN tutorial t ON t.level = CASE lp.slug
    WHEN 'junior-java-developer' THEN 'Junior'
    WHEN 'mid-java-engineer' THEN 'Mid'
    WHEN 'senior-java-engineer' THEN 'Senior'
    WHEN 'lead-java-engineer' THEN 'Lead'
    WHEN 'principal-java-engineer' THEN 'Principal'
END
WHERE t.slug IN (
    'java-generics-in-depth', 'java-streams-in-depth', 'java-optional-patterns',
    'java-functional-interfaces', 'java-pattern-matching', 'java-sealed-types',
    'java-records-in-depth', 'java-text-blocks', 'java-var-and-type-inference',
    'java-immutability-patterns', 'java-completable-future', 'java-virtual-threads',
    'java-structured-concurrency', 'java-locks-and-atomics', 'java-nio-and-file-io',
    'java-reflection-and-annotations', 'solid-principles-in-java'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
