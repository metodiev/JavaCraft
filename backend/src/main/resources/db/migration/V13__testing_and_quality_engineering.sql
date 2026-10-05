-- V13 — Testing and quality engineering tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('junit5-fundamentals', 'JUnit 5 Test Fundamentals', 'Write focused unit tests with clear lifecycle, naming, and assertion structure.', 'Junior', 24, true, 1),
    ('junit5-parameterized-tests', 'Parameterized Tests in JUnit 5', 'Drive one test method with many inputs using JUnit 5 parameterized sources and readable names.', 'Junior', 26, true, 1),
    ('junit5-extension-model', 'The JUnit 5 Extension Model', 'Extend JUnit 5 with custom callbacks and understand how extension registration works.', 'Mid', 30, true, 1),
    ('assertj-fluent-assertions', 'Fluent Assertions with AssertJ', 'Write AssertJ assertions whose failure messages explain exactly what broke.', 'Mid', 28, true, 1),
    ('mockito-essentials', 'Mockito Essentials for Service Tests', 'Use Mockito mocks, stubs, and verification deliberately, and know when to skip mocking.', 'Mid', 32, true, 1),
    ('test-doubles-and-design', 'Test Doubles and Testable Design', 'Choose fakes, stubs, spies, and mocks by coupling, and let test pain expose design smells.', 'Mid', 34, true, 1),
    ('testcontainers-fundamentals', 'Integration Testing with Testcontainers', 'Run tests against disposable real dependencies such as PostgreSQL with Testcontainers.', 'Mid', 36, true, 1),
    ('http-stubbing-with-wiremock', 'HTTP Stubbing with WireMock', 'Stub external HTTP services with WireMock and verify client behavior under realistic failures.', 'Mid', 32, true, 1),
    ('architecture-tests-with-archunit', 'Architecture Tests with ArchUnit', 'Encode module and layering rules as ArchUnit tests that fail the build on drift.', 'Mid', 30, true, 1),
    ('code-coverage-with-jacoco', 'Code Coverage with JaCoCo', 'Measure coverage correctly with JaCoCo and set thresholds that reward meaningful tests.', 'Senior', 32, true, 1),
    ('static-analysis-quality-gates', 'Static Analysis Quality Gates', 'Combine SpotBugs, PMD, and Checkstyle into a CI gate without drowning in warnings.', 'Senior', 30, true, 1),
    ('mutation-testing-with-pit', 'Mutation Testing with PIT', 'Use PIT mutation testing to find weak assertions and judge test suite strength.', 'Senior', 34, true, 1),
    ('microbenchmarking-with-jmh', 'Microbenchmarking with JMH', 'Benchmark JVM code with JMH and read the numbers honestly.', 'Senior', 36, true, 1),
    ('load-testing-essentials', 'Load Testing Essentials', 'Compare load, stress, and soak testing, and choose the metrics that matter.', 'Senior', 40, true, 1),
    ('flaky-tests-and-ci-reliability', 'Flaky Tests and CI Reliability', 'Detect, quarantine, and root-cause flaky tests instead of retrying them forever.', 'Senior', 34, true, 1),
    ('property-based-testing', 'Property-Based Testing', 'Express invariants with property-based tests and shrink failures to minimal counterexamples.', 'Senior', 32, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('junit5-fundamentals', 1, 'A fresh object per test', $body$JUnit 5 creates a new test class instance for every test method by default, so mutable fields reset automatically. Instance state cannot leak between methods, which removes a common source of order-dependent failures, and test method order is deliberately unspecified. Never rely on one test running before another. Use `@BeforeEach` to build collaborators and `@AfterEach` to release resources such as threads or temporary files, while `@BeforeAll` methods stay static and run once per class. A test that passes alone but fails in the suite is usually sharing state or depending on order rather than exercising the code under test.$body$, $code$class CartTest {
    private Cart cart;

    @BeforeEach
    void createCart() {
        cart = new Cart();
    }

    @Test
    void addsAnItem() {
        cart.add("book");
        assertEquals(1, cart.size());
    }
}$code$),
    ('junit5-fundamentals', 2, 'Names that state expected behavior', $body$A test name should state a fact about the system, such as rejects an expired token rather than test token 2. JUnit 5 lets you keep a technical method name for searching and add `@DisplayName` for reports, so failures read like a specification. Structure the body as given, when, then: build inputs, perform the single action, assert the outcome. One behavior per method keeps the first failure meaningful. Prefer naming the condition and the outcome instead of repeating implementation steps, and keep names stable because teams grep them for years.$body$, $code$@Test
@DisplayName("withdraw rejects an amount above the balance")
void withdrawFailsWhenAmountExceedsBalance() {
    Account account = new Account(50);

    assertThrows(
        InsufficientFundsException.class,
        () -> account.withdraw(60));
}$code$),
    ('junit5-fundamentals', 3, 'Assertions that localize failures', $body$An assertion should fail with enough context to understand what broke without reproducing anything. Pass the expected value first, because JUnit reports expected and actual values, which makes regressions readable. Group related checks with `assertAll` so one run reports every broken invariant instead of stopping at the first. Assert the specific behavior under test rather than a broad object equality that would also fail for unrelated formatting changes. Avoid catch-and-ignore blocks, and remember that `assertThrows` returns the exception so you can assert its message. If debugging a failure requires a debugger session, the assertion is not pulling its weight.$body$, $code$Order order = service.place(request);

assertAll(
    () -> assertEquals(Status.NEW, order.status()),
    () -> assertEquals(2, order.lines().size()),
    () -> assertEquals(1599, order.totalCents())
);$code$),
    ('junit5-parameterized-tests', 1, 'One method, many inputs', $body$`@ParameterizedTest` runs one method once per supplied argument set and reports each invocation separately, so a failing case is identifiable. `@ValueSource` covers single values, `@CsvSource` maps columns onto parameters, `@EnumSource` walks enum constants, and `@MethodSource` returns argument streams from a factory method. Prefer parameterized tests over copy-pasted methods that differ only in constants, because the inputs become visible data instead of buried duplication. Keep each invocation independent and avoid branching inside the test body, since different behavior per argument usually means several test cases are hiding inside one method.$body$, $code$@ParameterizedTest
@ValueSource(ints = {0, -1, Integer.MIN_VALUE})
void rejectsNonPositiveQuantity(int quantity) {
    assertThrows(
        IllegalArgumentException.class,
        () -> new OrderLine("book", quantity));
}$code$),
    ('junit5-parameterized-tests', 2, 'Conversion and null handling', $body$Parameterized tests convert string sources to declared parameter types implicitly, including numeric types and enums. When conversion rules are subtle, write an `ArgumentConverter` and attach it with `@ConvertWith` so the transformation is explicit and reusable. `@CsvSource` treats blank entries as missing, while `nullValues` lets you declare which tokens become null. Watch unquoted CSV columns that contain commas or leading spaces, and set `delimiter` when the default comma fights your data. If an input requires interpretation before it reaches the test, encode that interpretation once in a converter rather than repeatedly inside individual test methods.$body$, $code$@ParameterizedTest
@CsvSource({
    "1000, 0.10, 1100",
    "250, 0.20, 300"
})
void appliesTaxRate(int cents, double rate, int expected) {
    assertEquals(expected, tax.apply(cents, rate));
}$code$),
    ('junit5-parameterized-tests', 3, 'Readable names for each case', $body$Without help, parameterized invocations are labeled with an index, which tells a reviewer nothing. Use the `name` attribute with placeholders such as `{0}` and `{1}`, or `@DisplayName`, so the report reads like a sentence and identifies the offending value directly. Build tool output and CI dashboards surface these names, so clear labels shorten triage. Combine parameter indexes with parameter names when a value needs a friendlier label. Avoid dumping entire objects into names, because unwieldy labels slow scanning. Each generated invocation should be distinguishable and self-explanatory in a failure list without opening the test source.$body$, $code$@ParameterizedTest(name = "quantity {0} is rejected")
@ValueSource(ints = {0, -1})
void rejectsNonPositiveQuantity(int quantity) {
    assertThrows(IllegalArgumentException.class,
        () -> new OrderLine("book", quantity));
}$code$),
    ('junit5-extension-model', 1, 'Callbacks at defined lifecycle points', $body$The JUnit 5 extension model exposes interfaces such as `BeforeEachCallback`, `AfterEachCallback`, `BeforeAllCallback`, and `TestWatcher`. The engine invokes them at documented points around test execution, which makes them the right place for cross-cutting concerns: logging, timing, temporary resources, or conditional skips. An extension receives an `ExtensionContext` with reflective access to the test method and class. Prefer several small extensions over one oversized hook, and keep them free of hidden global state. Putting business assertions into callbacks is a pitfall, because failures are then attributed to the wrong place. An extension should support a test, never decide what the test verifies.$body$, $code$class TimingExtension implements BeforeEachCallback {

    static final Namespace NAMESPACE =
        Namespace.create(TimingExtension.class);

    @Override
    public void beforeEach(ExtensionContext context) {
        context.getStore(NAMESPACE).put("start", System.nanoTime());
    }
}$code$),
    ('junit5-extension-model', 2, 'Register extensions explicitly', $body$Register an extension with `@ExtendWith` on a test class or method; annotate a class to apply it everywhere inside. For repeated combinations, create a meta-annotation that is itself annotated with `@ExtendWith` and use that annotation instead. Automatic registration through `ServiceLoader` exists, but it requires enabling the `junit.jupiter.extensions.autodetection.enabled` configuration parameter, and platform-wide behavior is easy to forget during review. Ordering between extensions can be influenced with `@Order`. Prefer explicit registration in the test, because a reader should see every behavior a test depends on without discovering hidden configuration files.$body$, $code$@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@ExtendWith(TimingExtension.class)
@interface Timed { }

class ReportServiceTest {
    @Timed
    @Test
    void rendersMonthlySummary() { }
}$code$),
    ('junit5-extension-model', 3, 'Store state inside the context', $body$Extensions should not keep mutable fields shared across tests, because instances may be reused across contexts and parallel execution amplifies races. Put per-test values in the `ExtensionContext` store, addressed by a `Namespace` that identifies your extension. Values stay scoped to the context that stored them and are released with it, which avoids leaks between classes. Keep the store small: capture identifiers or handles, not large object graphs. When an extension must react to failures, implement `TestExecutionExceptionHandler` and rethrow deliberately. Stateless extensions plus context-scoped storage stay correct when tests run in parallel, which is increasingly the default in CI.$body$, $code$class ScratchDirectoryExtension implements BeforeEachCallback {

    @Override
    public void beforeEach(ExtensionContext context) throws Exception {
        Path dir = Files.createTempDirectory("test-");
        context.getStore(Namespace.create(getClass()))
            .put("scratch", dir);
    }
}$code$),
    ('assertj-fluent-assertions', 1, 'Failures written as sentences', $body$AssertJ assertions chain, and each step describes intent, for example asserting an order is not null and extracting its total to compare with an expected value. When a chain fails, AssertJ prints the actual value and the path that failed, which often removes the need to reproduce locally. Use `as` to attach a description, especially in loops or parameterized tests where the failing element is not obvious from the value alone. Prefer a specific terminal assertion such as `isEqualTo` or `containsExactly` over generic truthiness, because a boolean check discards evidence that makes failures actionable. Choose the assertion whose failure message you would want to read at two in the morning.$body$, $code$Order order = service.place(request);

assertThat(order.lines())
    .as("lines of order %s", order.id())
    .extracting(OrderLine::sku)
    .containsExactly("book", "pen");

assertThat(order.status()).isEqualTo(Status.NEW);$code$),
    ('assertj-fluent-assertions', 2, 'Collections and maps deserve detail', $body$Collection assertions compare content instead of identities: `containsExactly` enforces order and duplicates, `containsExactlyInAnyOrder` relaxes order only, and `containsOnly` ignores extras when they are genuinely irrelevant. `extracting` projects elements to the fields that matter, which keeps assertions about domain objects concise. Map assertions including `containsEntry`, `containsOnlyKeys`, and `doesNotContainKey` express expectations without manual key iteration. For nested structures, `satisfiesExactly` verifies each element with its own assertion and produces precise failures. Comparing `toString` output couples tests to formatting. Assert the property you actually depend on, at the granularity that produces a readable diff.$body$, $code$Map<String, Integer> inventory = warehouse.snapshot();

assertThat(inventory)
    .containsEntry("book", 3)
    .doesNotContainKey("lamp")
    .containsOnlyKeys("book", "pen");

assertThat(inventory.keySet())
    .allSatisfy(sku -> assertThat(sku).isNotBlank());$code$),
    ('assertj-fluent-assertions', 3, 'Soft assertions and custom types', $body$A chain stops at the first failure, so verifying many fields of one response takes several runs. `SoftAssertions` or `assertSoftly` collects failures and reports them together, which is useful for wide objects and contract checks; call `assertAll` at the end, or use the block form that does it for you. When a domain concept appears across many tests, write a custom assertion extending `AbstractAssert` with a static `assertThat` entry point, so rules such as is fully paid live in one place. Keep custom assertions thin, delegating to standard ones. Use soft assertions for many independent checks on one result, and custom assertions when the same domain rule repeats across the suite.$body$, $code$SoftAssertions softly = new SoftAssertions();

softly.assertThat(account.name()).isNotBlank();
softly.assertThat(account.balance()).isPositive();

softly.assertAll();$code$),
    ('mockito-essentials', 1, 'Stub only what the path needs', $body$`mock` creates a double, and `when` followed by `thenReturn` programs a response. Stub only the calls the behavior under test actually makes; `MockitoExtension` uses strict stubs by default and raises `UnnecessaryStubbingException` when a stubbed call is never used, which catches tests that outlived their code. Configure defaults with `RETURNS_DEEP_STUBS` sparingly, because deep stubbing hides a long collaborator chain that usually signals a design problem. Prefer real objects for value types and plain data, since mocking a record or a collection is noise. Every stub should be justified by an assertion or a control-flow decision in the test, otherwise delete it.$body$, $code$RateRepository repository = mock(RateRepository.class);
when(repository.find("EUR", "USD"))
    .thenReturn(Optional.of(new Rate("EUR", "USD", 1.08)));

PricingService service = new PricingService(repository);

assertEquals(1080, service.convert(1000, "EUR", "USD"));$code$),
    ('mockito-essentials', 2, 'Verify behavior, not noise', $body$`verify` checks interactions that are part of the expected behavior, such as publishing an event or charging a card. `times`, `atLeastOnce`, and `never` express quantity, and `ArgumentCaptor` captures an argument when the exact instance is not otherwise observable. Do not verify every collaborator call, because interaction-heavy tests break whenever refactoring changes internal messaging while behavior stays identical. Use argument matchers consistently: mixing raw values and matchers in one call is rejected, and `any()` accepts null while `anyString()` does not. Verify an interaction only when that interaction is the observable outcome you were asked to produce.$body$, $code$ArgumentCaptor<AuditEntry> entry =
    ArgumentCaptor.forClass(AuditEntry.class);

verify(audit, times(1)).record(entry.capture());

assertThat(entry.getValue().actor()).isEqualTo("checkout");$code$),
    ('mockito-essentials', 3, 'When not to mock at all', $body$Mocking replaces dependencies that are slow, nondeterministic, or outside your control: networks, clocks, queues, and remote APIs. For pure logic, calculations, parsers, and value objects, real instances produce clearer and faster tests. For collaborators you own, hand-written fakes or in-memory implementations often beat generated mocks because they preserve real behavior and can be reused across the suite. If a unit test needs a large cast of mocks to execute one method, the class is doing too much or reaching for dependencies it could receive as values. Mock at architectural boundaries; use real code inside them.$body$, $code$class InMemoryRateLookup implements RateLookup {

    private final Map<String, Rate> rates = new HashMap<>();

    void put(Rate rate) {
        rates.put(rate.from() + rate.to(), rate);
    }

    @Override
    public Optional<Rate> find(String from, String to) {
        return Optional.ofNullable(rates.get(from + to));
    }
}$code$),
    ('test-doubles-and-design', 1, 'Precise vocabulary, precise tests', $body$Test doubles describe intent. A dummy is passed but never used, a stub returns canned answers, a spy records interactions while keeping real behavior, a mock is pre-programmed with expectations, and a fake has a working simplified implementation. The words matter because they predict how a test reacts to change: stubs rarely break under refactoring, while strict mocks couple a test to call sequences. Many teams say mock when they mean stub, which leads to over-specified tests. Choose the weakest double that supports the assertion you need, and name helpers after the role they play. Prefer state-based verification with fakes over interaction-based verification with mocks.$body$, $code$class FakeClock extends Clock {

    private Instant now = Instant.parse("2026-01-01T00:00:00Z");

    @Override
    public Instant instant() { return now; }

    @Override
    public ZoneId getZone() { return ZoneOffset.UTC; }

    @Override
    public Clock withZone(ZoneId zone) { return this; }
}$code$),
    ('test-doubles-and-design', 2, 'Pick the double from the coupling', $body$The right double depends on what you are coupled to. For interfaces you own, an in-memory fake provides realistic semantics and one place to maintain behavior. For third-party protocols, a stub or mock at your adapter boundary keeps foreign quirks out of domain tests. Spies help when wrapping legacy code that cannot be restructured yet, because they observe without replacing behavior. Fakes also double as executable documentation of a contract. Be suspicious of mocks for types inside your own module: the usual reason a collaborator is hard to instantiate is that it carries responsibilities it should not have, and a mock hides that feedback. Mock what you do not control.$body$, $code$class InMemoryInventory implements InventoryGateway {

    private final Map<String, Integer> stock = new HashMap<>();

    @Override
    public int available(String sku) {
        return stock.getOrDefault(sku, 0);
    }
}$code$),
    ('test-doubles-and-design', 3, 'Test pain as a design signal', $body$Difficulty writing a test is information. Needing five mocks, static access to clocks and randomness, or heavy reflection usually means the production code has hidden dependencies, temporal coupling, or too many responsibilities. The fix belongs in production code: inject collaborators through constructors, pass time as a `Clock`, isolate I/O behind ports, and keep constructors free of work. Watch for tests that break on every refactoring but never catch real bugs, because they couple to structure rather than behavior. Treating testability as a first-class requirement improves both the tests and the design they describe. If the test is hard to write, change the code, not the test.$body$, $code$class OrderService {

    private final Clock clock;
    private final RateLookup rates;

    OrderService(Clock clock, RateLookup rates) {
        this.clock = clock;
        this.rates = rates;
    }
}$code$),
    ('testcontainers-fundamentals', 1, 'Real dependencies, disposable instances', $body$Testcontainers starts a real database or broker in a container for the duration of a test class. `@Testcontainers` manages the lifecycle of fields annotated `@Container`, stopping them after the class unless static sharing says otherwise. Using the production engine matters most where behavior differs: SQL dialects, isolation levels, constraint errors, time zone handling, and driver quirks. In-memory substitutes frequently accept SQL that the real engine rejects. Containers cost startup time and require a working container runtime, so keep images small and pinned to explicit tags. Use a real dependency where the behavior under test is the dependency itself, and a fake where the dependency is merely a collaborator.$body$, $code$@Testcontainers
class AccountRepositoryTest {
    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:16-alpine");

    @Test
    void storesAnAccount() {
        AccountRepository repository = new AccountRepository(
            postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword());
        repository.save(new Account("acc-1", 500));
        assertThat(repository.find("acc-1")).isPresent();
    }
}$code$),
    ('testcontainers-fundamentals', 2, 'Wait on readiness, never on sleep', $body$A container reports started before the application inside it accepts connections. Wait strategies express readiness: `Wait.forListeningPort()` for a mapped port, `Wait.forLogMessage` for a server log line, or an HTTP wait for a health endpoint. Combine a wait strategy with `withStartupTimeout` so a genuinely slow start fails with a clear error instead of hanging the build. Fixed `Thread.sleep` calls are the usual cause of flaky container tests on loaded CI machines, because they encode an assumption about speed that is not true everywhere. Prefer waiting on an observable signal the service itself emits. If the test waits without checking a condition, it will eventually fail for the wrong reason.$body$, $code$new PostgreSQLContainer<>("postgres:16-alpine")
    .waitingFor(Wait.forLogMessage(
        ".*database system is ready to accept connections.*", 1))
    .withStartupTimeout(Duration.ofSeconds(60))
    .withCommand("postgres", "-c", "log_statement=none");$code$),
    ('testcontainers-fundamentals', 3, 'Keep the CI bill and runtime sane', $body$Every container start consumes CPU, memory, and pipeline minutes. Start expensive containers once per class or per suite instead of per method, share a single instance across read-only test classes, and let Ryuk clean up leftovers after the JVM exits. Reuse with `withReuse(true)` plus the matching client property is useful locally but risky on ephemeral CI agents, so scope it deliberately. Keep parallel test execution in mind: a shared database means shared state, so isolate schemas or data per worker. Enable container logging only when diagnosing failures. Treat container startup as a cost to amortize, and never let integration tests grow into an unfocused hourly job.$body$, $code$static final PostgreSQLContainer<?> POSTGRES =
    new PostgreSQLContainer<>("postgres:16-alpine")
        .withDatabaseName("orders")
        .withUsername("test")
        .withPassword("test")
        .withReuse(true);
// started once per JVM; Ryuk removes it after JVM exit$code$),
    ('http-stubbing-with-wiremock', 1, 'Own the protocol conversation', $body$WireMock runs an HTTP server that returns programmed responses, so your client talks real HTTP without a real partner. Stub by method, URL, headers, and body, then return status, headers, and payloads. Run it in-process with `WireMockServer` on a dynamic port and inject the base URL into client configuration, which keeps parallel tests safe. This exercises serialization, status handling, and parser behavior that a hand-written stub object would skip. Keep stubs close to the test that needs them so the protocol contract stays visible. Stub the wire, not the interface, when the risk lives in HTTP behavior such as headers, timeouts, or malformed payloads.$body$, $code$WireMockServer server = new WireMockServer(options().dynamicPort());
server.start();

server.stubFor(get(urlEqualTo("/rates/EUR"))
    .willReturn(aResponse()
        .withStatus(200)
        .withHeader("Content-Type", "application/json")
        .withBody("{\"rate\":1.08}")));

String baseUrl = server.baseUrl();$code$),
    ('http-stubbing-with-wiremock', 2, 'Inject the failures you cannot cause', $body$The most valuable use of an HTTP stub is producing failures the real service will not deliver on demand. Add `withFixedDelay` to test timeouts, random delay distributions to model long tails, and faults such as `CONNECTION_RESET_BY_PEER` or `MALFORMED_RESPONSE_CHUNK` to exercise resilience code. Combine a delay with a client deadline and assert that the fallback path actually engaged, not merely that no exception escaped. Scenario state lets one endpoint change behavior across successive calls, which is how you simulate a dependency recovering. Fault tests that assert nothing about recovery give false confidence. For every failure mode your client claims to handle, write a stub that produces it.$body$, $code$stubFor(get(urlEqualTo("/rates/EUR"))
    .willReturn(aResponse()
        .withFault(Fault.CONNECTION_RESET_BY_PEER)));

stubFor(get(urlEqualTo("/rates/USD"))
    .willReturn(aResponse()
        .withFixedDelay(5_000)
        .withStatus(200)));$code$),
    ('http-stubbing-with-wiremock', 3, 'Verify client behavior, not server trivia', $body$Verification should answer whether the client behaved correctly: how many calls it made, whether it retried, and whether it sent the right idempotency key. `verify` with request matchers and counts expresses that, and scenarios can confirm a recovery sequence. Avoid asserting an exact total number of requests unless that number is part of the contract, because internal caching or batching may change it legitimately. Remember that the stub configures what the server sends, while the assertion should describe what the client does in response. Reset stubs between tests when state is shared. Assert the contract you own and depend on, and leave the rest unverified.$body$, $code$server.stubFor(get(urlEqualTo("/rates/EUR"))
    .inScenario("recovery")
    .whenScenarioStateIs(Scenario.STARTED)
    .willReturn(aResponse().withStatus(503))
    .willSetStateTo("healthy"));

verify(2, getRequestedFor(urlEqualTo("/rates/EUR")));$code$),
    ('architecture-tests-with-archunit', 1, 'Rules compiled into the build', $body$Architecture rules usually live in diagrams and review comments, where they decay quietly. ArchUnit imports compiled classes and lets you express those rules as ordinary JUnit tests, so a violation fails the build like any regression. Start with the boundaries you rely on: which packages may depend on which, which layers stay independent, and which naming conventions mark an adapter. Rules run fast because they analyze bytecode, and they double as documentation that cannot drift from reality. Keep rule names stated as constraints so failures explain the intended architecture. If a boundary matters enough to discuss in review, it matters enough to encode once and enforce continuously.$body$, $code$@AnalyzeClasses(packages = "com.javacraft.payments")
class LayeringTest {

    @ArchTest
    static final ArchRule servicesDoNotDependOnWeb =
        noClasses().that().resideInAPackage("..service..")
            .should().dependOnClassesThat()
            .resideInAPackage("..web..");
}$code$),
    ('architecture-tests-with-archunit', 2, 'Layers, slices, and cycles', $body$The core vocabulary is dependency direction: classes in one package should not depend on, or be accessed by, classes in another, expressed with `noClasses` rules that fail on violation. Layer checks state that controllers may use services and services may use persistence, but never the reverse. Slice assertions group classes by a pattern, such as the first package segment after the root, and can require the resulting graph to be free of cycles; that is the fastest way to catch accidental tangles before they harden. Import packages explicitly rather than the whole classpath so rules stay fast and comprehensible. Enforce direction and cycles, and leave stylistic preferences to formatting tools.$body$, $code$ArchRule noCycles = SlicesRuleDefinition
    .slices().matching("com.javacraft.payments.(*)..")
    .should().beFreeOfCycles();

noCycles.check(new ClassFileImporter()
    .importPackages("com.javacraft.payments"));$code$),
    ('architecture-tests-with-archunit', 3, 'Adopt rules without blocking delivery', $body$Turning on dozens of rules at once buries a team in violations. ArchUnit freeze mode records existing violations and fails only when new ones appear, so you can enforce the status quo and reduce the recorded set over time. Introduce one rule at a time with a named owner, and delete rules that no longer reflect a real constraint, because a stale rule teaches people to bypass checks. Keep architecture tests in the same pipeline stage as other tests so drift is discovered at review time rather than during an incident. Every enforced rule should carry a sentence explaining the risk it prevents.$body$, $code$ArchRule rule = noClasses().that().resideInAPackage("..service..")
    .should().dependOnClassesThat().resideInAPackage("..web..");

ArchRule frozen = FreezingArchRule.freeze(rule);
frozen.check(classes);$code$),
    ('code-coverage-with-jacoco', 1, 'What coverage measures and misses', $body$JaCoCo instruments bytecode and reports which lines, branches, and instructions executed during tests. Execution is not verification: a test that calls code without asserting anything still produces coverage. That gap is why coverage alone is a weak quality signal, and why teams that mandate it sometimes collect impressive numbers over trivial tests. Use the report to find unexercised paths, especially error handling and boundary branches that were never run. Treat low coverage as a question rather than a verdict: it asks whether the missing code matters and whether it should exist at all. Coverage finds what was never tested; it cannot tell you what was tested well.$body$, $code$<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <executions>
    <execution>
      <goals>
        <goal>prepare-agent</goal>
      </goals>
    </execution>
  </executions>
</plugin>$code$),
    ('code-coverage-with-jacoco', 2, 'Branch coverage asks harder questions', $body$Line coverage treats a partially executed condition as covered, while branch coverage counts each outcome of a decision. A method with three guard clauses may show full line coverage after a single happy path, yet most branches remain unvisited. Filter reports by package and class to inspect the code you actually own, and read the branch column when reviewing risk. Combine coverage with mutation testing when you need evidence about assertion strength, because the two address different failure modes. Exclude generated sources, configuration classes, and framework boilerplate through explicit configuration instead of leaving unexplained gaps. Watch branches on decision-heavy code, and accept lower coverage in thin adapters that only delegate.$body$, $code$<limit>
  <counter>BRANCH</counter>
  <value>COVEREDRATIO</value>
  <minimum>0.75</minimum>
</limit>$code$),
    ('code-coverage-with-jacoco', 3, 'Thresholds that do not breed fake tests', $body$A coverage threshold can enforce a floor, but an aggressive one invites assertion-free tests written to satisfy the check. Bind the `check` goal to bundle-level limits, set a modest minimum, and ratchet it upward deliberately as the suite grows. Fail the build on regressions rather than demanding perfection, and allow explicitly configured exclusions with a written reason. Review coverage in the pull request diff so reviewers see untested new code in context, which is more useful than a single project percentage. A threshold between sixty and eighty percent with meaningful assertions beats one hundred percent of noise.$body$, $code$<execution>
  <id>check</id>
  <goals><goal>check</goal></goals>
  <configuration>
    <rules>
      <rule>
        <element>BUNDLE</element>
      </rule>
    </rules>
  </configuration>
</execution>$code$),
    ('static-analysis-quality-gates', 1, 'Different tools catch different defects', $body$Checkstyle enforces formatting and naming conventions, PMD analyzes source for patterns such as empty catch blocks and duplicated code, SpotBugs inspects bytecode for bug patterns like null dereferences and exposed mutable state, and Error Prone runs inside the compiler to catch mistakes such as misuse of equals or fallthrough switches. They overlap partially, and adding all of them at maximum settings does not multiply value. Choose tools by the defects you actually see, then document why each rule set exists. Security-focused rule packs deserve separate, explicit attention. Every enabled rule should map to a bug class or a convention the team genuinely follows.$body$, $code$<plugin>
  <groupId>com.github.spotbugs</groupId>
  <artifactId>spotbugs-maven-plugin</artifactId>
  <configuration>
    <effort>Max</effort>
    <threshold>Medium</threshold>
  </configuration>
</plugin>$code$),
    ('static-analysis-quality-gates', 2, 'Wire the gate into the build', $body$Run analyzers on every build so findings surface while context is fresh, not weeks later in a scheduled scan. Maven plugins bind to the verify phase, where `check` goals can fail the build when they exceed a configured finding budget; the same commands run locally and in the pipeline. Start by failing only on new or high-severity findings. Suppress individual warnings with narrow, justified annotations such as `SuppressFBWarnings` including a reason, and never suppress an entire package to make a dashboard green. A check that developers cannot run before pushing will teach them to bypass the pipeline instead.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <executions>
    <execution>
      <phase>verify</phase>
      <goals><goal>check</goal></goals>
    </execution>
  </executions>
</plugin>$code$),
    ('static-analysis-quality-gates', 3, 'Prevent alert fatigue', $body$Analyzers lose credibility when reports contain hundreds of cosmetic findings mixed with one real bug. Tune rule sets to high-signal checks first, exclude generated code explicitly, and set severity thresholds that separate blocking from informational results. Track finding counts over time and treat a rising trend as a review topic rather than an automatic failure. When a rule cannot be satisfied, record a decided exception instead of disabling it silently, so the reasoning survives team changes. Introduce new rules gradually, explaining the defect class each one prevents. Fewer rules that everyone understands and fixes beat a comprehensive list nobody reads.$body$, $code$@SuppressFBWarnings(
    value = "EI_EXPOSE_REP2",
    justification = "Immutable value, safely shared")
public Reporter(Instant createdAt) {
    this.createdAt = createdAt;
}$code$),
    ('mutation-testing-with-pit', 1, 'Mutants expose weak assertions', $body$PIT seeds small faults into compiled bytecode: negating conditionals, changing boundary operators, replacing return values, and removing calls. Each mutant is a hypothesis that the change breaks behavior. If the test suite fails on the mutant, it is killed; if tests still pass, the mutant survived and marks a place where assertions are missing or too weak. Mutation testing measures the quality of verification rather than the fact of execution, which is exactly what line coverage cannot see. PIT is computationally expensive because it reruns tests against every mutant, so scoping and feedback limits matter. A surviving mutant is a question, and sometimes the honest answer is dead code.$body$, $code$<plugin>
  <groupId>org.pitest</groupId>
  <artifactId>pitest-maven</artifactId>
  <configuration>
    <targetClasses>
      <param>com.javacraft.pricing.*</param>
    </targetClasses>
  </configuration>
</plugin>$code$),
    ('mutation-testing-with-pit', 2, 'Interpret the mutation score honestly', $body$The score is roughly killed mutants divided by all non-equivalent mutants. Equivalent mutants change bytecode without changing observable behavior, so no test can kill them; they depress the score for reasons unrelated to test quality. Do not treat the number as a target to maximize. Read surviving mutants by category: boundary survivors often indicate off-by-one assertions that are too loose, while returned-value survivors usually mean the assertion checks a weaker property than the method guarantees. Filter unwanted mutation operators only with a stated reason, since disabling the noisy ones quietly hides the feedback you bought the tool for. Fix assertions, or delete code that nothing observable depends on.$body$, $code$<plugin>
  <groupId>org.pitest</groupId>
  <artifactId>pitest-maven</artifactId>
  <configuration>
    <mutationThreshold>70</mutationThreshold>
  </configuration>
</plugin>$code$),
    ('mutation-testing-with-pit', 3, 'Run it selectively where it pays', $body$A full mutation run can take hours on a large codebase, so make it selective. Restrict `targetClasses` to a module or package and `targetTests` to the covering tests, use history for faster repeat runs, and configure a mutation threshold only where the suite is mature enough to meet it. In continuous integration, run scoped jobs on the classes touched by a change set, and schedule a broader run nightly rather than blocking every pull request. Time limits and thread counts bound the cost of pathological mutants. Apply mutation testing to critical decision logic, and let simple adapters rely on integration tests.$body$, $code$mvn -DwithHistory test-compile \
    org.pitest:pitest-maven:mutationCoverage \
    -DtargetClasses='com.javacraft.pricing.*' \
    -DtargetTests='com.javacraft.pricing.*Test' \
    -Dthreads=4 \
    -DoutputFormats=HTML,XML$code$),
    ('microbenchmarking-with-jmh', 1, 'Why naive benchmarks mislead', $body$Hand-rolled timing loops around `System.nanoTime` measure the optimizer as much as the code. The JIT compiles hot paths during measurement, dead code is eliminated when results are unused, constants fold at compile time, and warmup phases dominate short runs. JIT compilation, garbage collection, and CPU frequency changes all perturb results across repetitions. Microbenchmarks answer narrow questions about small units under artificial conditions; they cannot predict end-to-end latency, contention, or cache behavior in a real service. Profiling production-like workloads comes first, and a benchmark follows only when a specific hot path needs comparative evidence. Treat every microbenchmark result as valid only inside the harness that produced it.$body$, $code$long start = System.nanoTime();
for (int i = 0; i < 1_000_000; i++) {
    result = parser.parse(text);
}
long elapsed = System.nanoTime() - start;$code$),
    ('microbenchmarking-with-jmh', 2, 'Let JMH run the experiment', $body$JMH generates a harness that handles warmup, forking, and measurement. Annotate benchmark methods with `@Benchmark`, choose an output mode such as average time or throughput, and hold inputs in `@State` objects so the optimizer cannot hoist them out of the measured region. Consume computed values through the return value or a `Blackhole` so dead code elimination cannot delete the work. Warmup and measurement iterations accumulate stable statistics, and forking isolates JVM profiles across parameter sets. Keep each benchmark focused on one question with realistic input sizes, because a benchmark of a trivial method with tiny data says little about the same method under production load.$body$, $code$@Benchmark
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
public int parse(UuidState state) {
    return Uuid.parse(state.text).hashCode();
}$code$),
    ('microbenchmarking-with-jmh', 3, 'Read the numbers with suspicion', $body$JMH reports an average with an error margin; overlapping intervals between variants mean the difference is not established. Inspect percentiles when latency tails matter, since averages hide pauses that dominate user experience. Run benchmarks on idle, dedicated machines with fixed CPU settings, and pin down JVM flags, heap sizes, and data shapes so results stay comparable over time. Store results with the code that produced them so a future change can be evaluated against a consistent baseline. Never convert a microbenchmark win into a production claim without end-to-end evidence. Benchmark to compare alternatives under controlled conditions, not to promise production behavior.$body$, $code$@Fork(2)
@Warmup(iterations = 5, time = 1)
@Measurement(iterations = 5, time = 1)
@State(Scope.Benchmark)
public class UuidBenchmark {

    private String text = UUID.randomUUID().toString();
}$code$),
    ('load-testing-essentials', 1, 'Load, stress, and soak answer different questions', $body$A load test validates that the system meets its objectives at expected peak traffic. A stress test deliberately pushes until something breaks, and how it fails is the result. A soak test holds a realistic load for hours to expose leaks, connection exhaustion, and slow degradation. Mixing goals in one run produces numbers nobody can interpret. Define the question, the success criteria, and the exit conditions before starting generators, and include a ramp so behavior under changing load is visible. Watch resource saturation on all tiers, not just the entry point, because the first exhausted dependency sets the real ceiling. One purpose per test run, with thresholds stated in advance.$body$, $code$export const options = {
  stages: [
    { duration: '2m', target: 50 },
    { duration: '30m', target: 50 },
    { duration: '1m', target: 0 },
  ],
};$code$),
    ('load-testing-essentials', 2, 'Tools and traffic models', $body$k6 scripts scenarios in JavaScript and reports thresholds that fail the run automatically; Gatling offers a Scala DSL, strong reporting, and efficient resource usage; JMeter provides a graphical interface and broad protocol coverage that suits protocol-heavy or non-HTTP testing. The deeper distinction is the traffic model: closed models hold a fixed number of virtual users, so a slow response reduces the request rate, while open models keep arriving regardless of response time and better represent real users. Choose a tool your team can maintain in version control and run headless in CI. Codify the performance objective as an automated threshold, or the load test is just an experiment nobody can repeat.$body$, $code$export const options = {
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<200', 'p(99)<400'],
  },
};$code$),
    ('load-testing-essentials', 3, 'Metrics and environment realism', $body$Report percentiles, not averages: p95 and p99 show the experience of slow requests, which is where users complain. Track error rate by status class, sustained throughput, and saturation signals such as queue depth, thread pools, and database connections; correlate generator output with server metrics to locate the bottleneck rather than guessing. Run against a production-like environment with comparable topology, data volume, and configuration, because a scaled-down stage will mislead about caching and query plans. Isolate test tenants and data so load runs do not corrupt real records. A performance number without the environment and workload that produced it is not evidence.$body$, $code$k6 run load-test.js
gatling.sh -s CatalogSimulation
jmeter -n -t catalog.jmx -l results.jtl
# Compare p95 and error rate against the same
# environment baseline before accepting the run.$code$),
    ('flaky-tests-and-ci-reliability', 1, 'Flakes are defects in the suite', $body$A test that passes and fails without any code change is nondeterministic, and nondeterminism usually comes from uncontrolled time, shared state, unbounded waits, port collisions, test order, or external services. The cost is not the rerun; it is the erosion of trust, which trains people to ignore red builds. Flakes also mask genuine regressions that happen to coincide with a rerun. Reproduce them under load and with the same parallelism as CI, because a failure on a developer laptop often requires that contention. Capture diagnostics on failure, including logs, timings, and the random seed, so the first occurrence already contains evidence. Treat every flake as a bug with an owner.$body$, $code$Instant deadline = Instant.now().plusSeconds(5);

await()
    .atMost(Duration.ofSeconds(5))
    .until(() -> repository.find(orderId).isPresent());

assertThat(repository.find(orderId).orElseThrow().createdAt())
    .isBeforeOrEqualTo(deadline);$code$),
    ('flaky-tests-and-ci-reliability', 2, 'Quarantine with an expiry date', $body$When a flaky test blocks delivery, quarantine is a containment tool: tag it, move it to a separate non-blocking job, and record an owner and a deadline. The quarantine list must shrink, because tests that sit there forever are deleted work in disguise, and their coverage quietly disappears. Retrying failures, for example with the surefire `rerunFailingTestsCount` option, is a tax paid on every run and conceals the root cause it was meant to survive. Use reruns only as a short-lived observation window while diagnosis happens, and count them in a visible metric. Every quarantine entry needs a linked cause and a review date.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-surefire-plugin</artifactId>
  <configuration>
    <rerunFailingTestsCount>1</rerunFailingTestsCount>
  </configuration>
</plugin>$code$),
    ('flaky-tests-and-ci-reliability', 3, 'Root-cause the pattern, not the instance', $body$Diagnosis starts by classifying the failure: timing, ordering, isolation, resource, or environment. Fixes follow the class. Inject a clock instead of reading the wall clock, await a condition instead of sleeping, give each test its own schema or tenant, allocate dynamic ports, and seed randomness so failures reproduce. Make the test suite deterministic by construction rather than by retry policy, and run the fixed test under stress before trusting it. Track flake rate per test over time to confirm improvement and to catch regressions in test infrastructure itself. A flaky test you cannot reproduce is unresolved, not fixed.$body$, $code$- name: Quarantined tests
  continue-on-error: true
  run: mvn -B test -Dgroups=flaky
# tagged tests stay visible without blocking merges
# owner and expiry date recorded in the test annotation$code$),
    ('property-based-testing', 1, 'Properties replace example lists', $body$A property states something that must hold for every valid input: encode then decode returns the original, sorting preserves elements and produces a nondecreasing order, and idempotent operations do not change state on the second call. Frameworks such as jqwik generate inputs for `@Property` methods with `@ForAll` parameters, running many samples by default and printing the seed that reproduces a run. Generation explores combinations no one would enumerate, especially boundaries around zero, empty strings, and collection sizes. Properties suit parsers, encoders, sorters, and state machines, where a general rule is easier to trust than a hand-picked table of examples.$body$, $code$@Property
void encodeDecodeRoundTrip(@ForAll String text) {
    String encoded = Codec.encode(text);
    assertThat(Codec.decode(encoded)).isEqualTo(text);
}$code$),
    ('property-based-testing', 2, 'Generators, constraints, and shrinking', $body$Built-in arbitraries generate integers, strings, lists, and objects; constraints narrow the input space to meaningful values, and `@Provide` methods supply domain-specific generators such as valid SKUs or currency amounts. Constraints belong in the generator, not in ignore statements scattered through test bodies, because discarded samples waste the sampling budget for no coverage. When a property fails, the framework shrinks the counterexample to a minimal failing input, which is usually far more informative than the original. Keep the shrunk value as an explicit regression test so the exact case stays pinned even if generation changes later. Design generators that produce only inputs your contract considers valid.$body$, $code$@Property
void discountNeverExceedsPrice(
        @ForAll @BigRange(min = "0", max = "100") BigDecimal price) {
    assertThat(Pricing.discount(price))
        .isBetween(BigDecimal.ZERO, price);
}$code$),
    ('property-based-testing', 3, 'Choose properties worth proving', $body$The strongest properties are round trips, invariants across transformations, idempotence, commutativity where operations should be order-independent, and monotonic relations such as a larger input not producing a smaller total. Weak properties that merely restate the implementation, or compare a function against a reimplementation of itself, add runtime without reducing risk. Avoid property explosion: a handful of meaningful invariants covers more ground than dozens of trivial ones. Keep property tests fast, because hundreds of generated cases per run multiply any slow fixture. A property earns its place when breaking it would indicate a real defect rather than a refactoring.$body$, $code$@Provide
Arbitrary<String> skus() {
    return Arbitraries.strings()
        .withCharRange('A', 'Z')
        .ofLength(8);
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
    'junit5-fundamentals', 'junit5-parameterized-tests', 'junit5-extension-model',
    'assertj-fluent-assertions', 'mockito-essentials', 'test-doubles-and-design',
    'testcontainers-fundamentals', 'http-stubbing-with-wiremock',
    'architecture-tests-with-archunit', 'code-coverage-with-jacoco',
    'static-analysis-quality-gates', 'mutation-testing-with-pit',
    'microbenchmarking-with-jmh', 'load-testing-essentials',
    'flaky-tests-and-ci-reliability', 'property-based-testing'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
