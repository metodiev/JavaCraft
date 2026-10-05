-- V12 — Spring Framework 7 and Spring Boot 4 tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('spring-framework-7-overview', 'Spring Framework 7 Overview', 'Review the Java, Jakarta EE, and API changes that define the Spring Framework 7 generation.', 'Senior', 36, true, 1),
    ('spring-boot-4-overview', 'Spring Boot 4 Overview', 'Understand how modularization, new starters, and baseline requirements change Spring Boot 4 applications.', 'Senior', 32, true, 1),
    ('migrating-spring-boot-3-to-4', 'Migrating from Spring Boot 3 to 4', 'Plan a staged upgrade through BOM changes, removed APIs, configuration renames, and test updates.', 'Senior', 40, true, 1),
    ('spring-7-null-safety-jspecify', 'JSpecify Null Safety in Spring 7', 'Use JSpecify annotations to make nullability explicit and catch null pointer risks at compile time.', 'Senior', 30, true, 1),
    ('spring-7-api-versioning', 'API Versioning in Spring 7', 'Version HTTP APIs with the built-in Spring MVC and WebFlux support and communicate deprecation properly.', 'Senior', 34, true, 1),
    ('spring-7-resilience-features', 'Resilience Features in Spring 7', 'Apply core retry and concurrency limiting to method invocations and reason about their production limits.', 'Senior', 32, true, 1),
    ('spring-jackson-3-integration', 'Jackson 3 Integration in Spring', 'Move JSON serialization to Jackson 3 with new packages, mapper defaults, and a staged migration path.', 'Senior', 34, true, 1),
    ('spring-aot-and-native-images', 'AOT and Native Images with Spring Boot', 'Prepare applications for build-time AOT processing and GraalVM native images with correct hints and CI coverage.', 'Senior', 38, true, 1),
    ('spring-modulith', 'Modular Monoliths with Spring Modulith', 'Structure a modular monolith, verify module boundaries, connect modules with events, and generate documentation.', 'Lead', 40, true, 1),
    ('spring-observability-and-tracing', 'Observability and Tracing in Spring', 'Connect metrics, logs, and traces through the Micrometer Observation API and context propagation.', 'Lead', 38, true, 1),
    ('spring-virtual-threads', 'Virtual Threads in Spring Boot', 'Enable virtual threads, recognize where they help, and avoid pinning and thread-local problems.', 'Lead', 36, true, 1),
    ('spring-boot-testcontainers', 'Integration Testing with Testcontainers', 'Replace mocks with real dependencies using service connections, managed lifecycles, and dev services.', 'Lead', 38, true, 1),
    ('spring-graphql-basics', 'GraphQL with Spring for GraphQL', 'Build schema-first GraphQL services with controller mappings and batching that avoids repeated queries.', 'Principal', 42, true, 1),
    ('spring-websockets', 'WebSocket Messaging with Spring', 'Compare WebSocket with polling and SSE, configure STOMP messaging, and plan for horizontal scaling.', 'Principal', 40, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('spring-framework-7-overview', 1, 'Java and Jakarta baselines', $body$Spring Framework 7 keeps a JDK 17 baseline while recommending JDK 25 for production, and it moves the web stack to a Jakarta EE 11 baseline: Servlet 6.1, JPA 3.2, and Bean Validation 3.1. That means Tomcat 11 or Jetty 12.1 class containers, Hibernate ORM 7.1 or 7.2, and Hibernate Validator 9.x. Kotlin 2.2, JUnit 6, and GraalVM 25 are the matching toolchain releases. The production consequence is that a framework upgrade is also a container and persistence provider upgrade. Check runtime images, application server versions, and vendor support windows before scheduling the change, and treat unsupported containers as a hard blocker rather than an afterthought.$body$, $code$// Spring Framework 7 requires a Jakarta EE 11 baseline:
// Servlet 6.1 containers (Tomcat 11, Jetty 12.1), JPA 3.2,
// and Bean Validation 3.1. These imports fail to resolve
// on an older EE 9 or EE 10 classpath.
import jakarta.servlet.http.HttpServletRequest;
import jakarta.persistence.EntityManager;$code$),
    ('spring-framework-7-overview', 2, 'Removal of legacy APIs', $body$Several long-lived APIs are gone rather than deprecated. The spring-jcl module is replaced by Apache Commons Logging with no API change for typical applications. Support for javax.annotation and javax.inject annotations is removed, so PostConstruct, Resource, and Inject usages must move to the jakarta packages. ListenableFuture is removed in favor of CompletableFuture, Undertow support is dropped because it does not implement Servlet 6.1, and path extension and suffix matching options were deleted. RestTemplate is documented as deprecated and planned for the Deprecated annotation in 7.1 in favor of RestClient, while Jackson 2 support is deprecated in favor of Jackson 3. Scan the upgrade notes and fix every deprecation before adding new features.$body$, $code$import jakarta.annotation.PostConstruct;
import jakarta.inject.Inject;

class ReportService {

    @Inject
    ReportRepository repository;

    @PostConstruct
    void warmUp() {
        repository.preload();
    }
}$code$),
    ('spring-framework-7-overview', 3, 'Resilience and core additions', $body$Spring Framework 7 merges trimmed Spring Retry features into the framework. The spring-core module now provides retry support in the org.springframework.core.retry package with RetryTemplate, RetryPolicy, and related types, while spring-context adds the Retryable and ConcurrencyLimit annotations, enabled through EnableResilientMethods on a configuration class. A default policy retries any exception up to three times after the initial failure with a one second delay. The same generation adds a JmsClient for message sending, a programmatic BeanRegistrar for bean registration, and SpEL guardrails such as a default limit of 10,000 operations per expression evaluation. Treat framework retry as a foundation: circuit breaking and bulkheading remain concerns for other libraries such as Resilience4j.$body$, $code$// Spring Framework 7 adds a JmsClient alongside JdbcClient.
jmsClient.destination("notifications").send(payload);

// Programmatic retry now ships in spring-core.
RetryTemplate retry = new RetryTemplate(RetryPolicy.withMaxRetries(4));
retry.invoke(() -> gateway.fetchStatus(orderId));$code$),
    ('spring-boot-4-overview', 1, 'Modular auto-configuration packaging', $body$In Spring Boot 3, one large spring-boot-autoconfigure jar carried support for every technology. Spring Boot 4 splits that jar into focused modules named spring-boot-technology with root packages under org.springframework.boot.technology, for example spring-boot-graphql and org.springframework.boot.graphql. Because modules are scoped, accidental auto-configuration mostly disappears: a project that only uses WebClient no longer pulls in web server auto-configuration. Each starter also has a matching test starter. The migration cost is real: technologies that previously worked because their library was on the classpath, such as Flyway, now require an explicit starter. Review every dependency that was auto-configured by presence alone and add the corresponding starter before upgrading.$body$, $code$// Spring Boot 4 replaces spring-boot-autoconfigure with focused
// modules: spring-boot-<technology> and packages under
// org.springframework.boot.<technology>.
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-webmvc'
    implementation 'org.springframework.boot:spring-boot-starter-flyway'
}$code$),
    ('spring-boot-4-overview', 2, 'Starters and baseline requirements', $body$Spring Boot 4 requires Java 17 or later, recommends the newest LTS release, and needs Spring Framework 7.x, Kotlin 2.2, and GraalVM 25 for native images. Starter naming became consistent: spring-boot-starter-web is now spring-boot-starter-webmvc and spring-boot-starter-aop became spring-boot-starter-aspectj. Every main starter has a test companion named spring-boot-starter-technology-test, which brings the shared test starter transitively. Applications that need more time can add spring-boot-starter-classic and spring-boot-starter-test-classic to restore the old broad classpath and migrate imports incrementally. That bridge is temporary and should be removed before the next major upgrade, so track it as migration debt with an owner and a date.$body$, $code$<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc-test</artifactId>
    <scope>test</scope>
</dependency>$code$),
    ('spring-boot-4-overview', 3, 'Testing and JSON defaults', $body$Testing annotations changed in ways that break compilation. MockBean and SpyBean are removed in favor of MockitoBean and MockitoSpyBean, which work on fields and on test classes but not inside configuration classes. SpringBootTest no longer provides MockMvc or TestRestTemplate beans; add AutoConfigureMockMvc or AutoConfigureTestRestTemplate explicitly, or use the new RestTestClient. Jackson 3 is the default JSON library, so mappers, modules, and some default output ordering and date rendering change. Boot also auto-configures format-specific JsonMapper and XmlMapper beans, and replacing them requires defining a bean of the same type. Plan the JSON changes as a separate, well-tested step.$body$, $code$@SpringBootTest
@AutoConfigureMockMvc
class OrderApiTests {

    @Autowired
    MockMvc mockMvc;

    @MockitoBean
    OrderRepository repository;

    @Test
    void returnsOrder() throws Exception {
        mockMvc.perform(get("/orders/42")).andExpect(status().isOk());
    }
}$code$),
    ('migrating-spring-boot-3-to-4', 1, 'Prepare on the 3.5 line', $body$Before touching the major version, upgrade to the latest 3.5.x maintenance release and remove all calls to deprecated APIs. Compile with deprecation warnings visible and treat new warnings as work items, because Boot 4 deletes what 3.x deprecated. Compare dependency management between 3.5 and 4.0 to find library version jumps, and identify third-party projects such as Spring Cloud that must move at the same time. Confirm that the runtime meets the new requirements: Java 17 minimum, Servlet 6.1 containers, and GraalVM 25 for native images. The point of this phase is to separate mechanical framework migration from genuine behavior changes, so each later step has a small, reviewable diff and a clear rollback path.$body$, $code$<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>4.0.0</version>
    <relativePath/>
</parent>$code$),
    ('migrating-spring-boot-3-to-4', 2, 'Swap the BOM and starters', $body$Move the parent or dependency management to a Boot 4 release, then let the compiler and the property migrator report what changed. Add the spring-boot-properties-migrator module temporarily to detect renamed configuration properties at startup and remove it once the rename list is empty. Add starters for technologies that previously relied on classpath detection, such as Flyway and Liquibase, rename the web starter to webmvc, and add the test starter for each technology under test. Property names moved as well: spring.dao.exceptiontranslation.enabled is now spring.persistence.exceptiontranslation.enabled, and management.tracing.enabled is now management.tracing.export.enabled. Keep the classic starters as a bridge only when they measurably shorten the migration.$body$, $code$<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-properties-migrator</artifactId>
    <scope>runtime</scope>
</dependency>$code$),
    ('migrating-spring-boot-3-to-4', 3, 'Stage the rollout with tests', $body$Removed APIs produce compile errors, which is the cheapest possible failure mode. Fix those first, then repair tests: add AutoConfigureMockMvc where MockMvc is used, replace MockBean with MockitoBean, and update moved packages such as BootstrapRegistry and EnvironmentPostProcessor. For JSON, either adopt Jackson 3 defaults and update assertions about property order and date formats, or set spring.jackson.use-jackson2-defaults=true, or use the deprecated spring-boot-jackson2 module as a short-lived stop-gap. Deploy the migrated build to a staging environment that mirrors production containers, run the full integration suite, and release behind a canary so a rollback stays available while metrics and error rates settle.$body$, $code$@SpringBootTest
@AutoConfigureMockMvc
class MigrationSmokeTests {

    @Autowired
    MockMvc mockMvc;

    @Test
    void servesExistingContract() throws Exception {
        mockMvc.perform(get("/api/orders"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith("application/json"));
    }
}$code$),
    ('spring-7-null-safety-jspecify', 1, 'NullMarked sets the default', $body$JSpecify makes nullability part of the type system instead of a runtime surprise. Annotating a package with NullMarked in package-info.java declares that every type usage in that package is non-null unless stated otherwise, and Nullable marks the exceptions. Because the annotations are type-use annotations, they are written directly before the annotated type, for example private Nullable String fileEncoding. Spring Framework 7 annotates its entire codebase this way, including generic type arguments, arrays, and vararg elements, and the previous JSR 305 annotations from the org.springframework.lang package are deprecated with documented replacements. Applications can adopt the same convention package by package without changing runtime behavior.$body$, $code$// package-info.java: non-null by default, nullable where marked.
@NullMarked
package example.orders;

import org.jspecify.annotations.NullMarked;$code$),
    ('spring-7-null-safety-jspecify', 2, 'Compile-time feedback and Kotlin', $body$The value of null-safety annotations comes from tools, not from the framework. IDEs that understand JSpecify, including IntelliJ IDEA 2025.3 and later, and build-time checkers such as NullAway report when a possibly-null value reaches a non-null position, turning some NullPointerException risks into review comments or build failures. Kotlin consumers benefit without extra annotation processing because Kotlin 2 translates JSpecify nullness directly into Kotlin nullability, which removes platform types from Spring APIs. In Java, annotations do not enforce anything at runtime, so validation of external input, database results, and deserialized payloads remains necessary. Treat checker output as a design signal: often the cleanest fix is to return an Optional or restructure the API.$body$, $code$// JSpecify annotations apply to type usage.
class MessageBuilder {

    private @Nullable String fileEncoding;

    String build(@Nullable String message, @Nullable Throwable cause) {
        return message == null ? "no message" : message;
    }
}$code$),
    ('spring-7-null-safety-jspecify', 3, 'Adopting JSpecify in applications', $body$Adopt in stages. Start by consuming Spring null-safe APIs and fixing the warnings that surface, especially around dependency injection and optional lookups. Then annotate the packages you own with NullMarked, keeping the boundary honest: mark genuinely nullable returns and parameters with Nullable rather than threading defensive null checks through every caller. Adding a checker such as NullAway to the build is a separate, larger commitment because existing code may produce many findings at once; some teams annotate first and enforce later. Migrating away from the deprecated Spring nullability annotations is mechanical, but watch cases where inherited annotations previously satisfied a checker, since the new pragmatic checks consider only local annotations. Keep each package internally consistent.$body$, $code$String name = service.displayName(userId);
if (name == null) {
    name = "unknown";
}
return greet(name);$code$),
    ('spring-7-api-versioning', 1, 'Configure version resolution', $body$There is no single standard way to version an HTTP API, so Spring 7 requires an explicit choice. Enable versioning by implementing configureApiVersioning on WebMvcConfigurer or WebFluxConfigurer and configuring the ApiVersionConfigurer, for example to read an API-Version request header. Built-in resolvers also support a request parameter, a path segment at a configured index, or a media type parameter, and custom resolvers can implement ApiVersionResolver. A central strategy parses raw version text with an ApiVersionParser, validates requests, and drives request mapping. Supported versions are inferred from declared mappings by default, or can be declared explicitly. The pitfall is inconsistency: pick one resolution mechanism per API surface and document it for clients and gateways.$body$, $code$@Configuration
class WebConfig implements WebMvcConfigurer {

    @Override
    public void configureApiVersioning(ApiVersionConfigurer configurer) {
        configurer.useRequestHeader("API-Version");
    }
}$code$),
    ('spring-7-api-versioning', 2, 'Map requests to versions', $body$Once versioning is enabled, the version attribute on request mappings selects handlers. A fixed value such as 1.2 matches only that version. A baseline value such as 1.2+ matches that version and every supported version above it. Omitting the attribute matches any version but is superseded whenever a more specific mapping exists. When several candidates are at or below the requested version, Spring chooses the highest one closest to the request. By default a version is required and a missing or unsupported version is rejected with a 400 response, but configuration can make the version optional or define a default, in which case the most recent supported version is used. Choose the strict behavior deliberately and test it.$body$, $code$@RestController
class AccountController {

    @GetMapping(value = "/accounts/{id}", version = "1.2")
    Account getAccountV12(@PathVariable Long id) {
        return accounts.find(id);
    }
}$code$),
    ('spring-7-api-versioning', 3, 'Signal deprecation to clients', $body$A version header is not enough; clients need a timeline. Configure an ApiVersionDeprecationHandler so responses for deprecated versions carry protocol-level headers. The standard handler sets Deprecation and Sunset headers following RFC 9745 and RFC 8594, plus Link headers that can point to documentation or a successor version. Spring clients, including RestClient, WebClient, and HTTP service interfaces, understand API versioning, and MockMvc and WebTestClient can exercise versioned requests, so the negotiated behavior is testable end to end. A practical rule is to support at most two or three versions, publish the sunset date when a version is deprecated, and treat removal of a version as a reviewed, communicated breaking change rather than an implementation detail.$body$, $code$@RestController
class AccountController {

    // Baseline mapping: serves 1.0 and every supported version above.
    @GetMapping(value = "/accounts/{id}", version = "1.0+")
    Account getAccountV10AndAbove(@PathVariable Long id) {
        return accounts.find(id);
    }
}$code$),
    ('spring-7-resilience-features', 1, 'Retry support in spring-core', $body$Retry is now part of the framework rather than an external project. The spring-core module contains the org.springframework.core.retry package with RetryTemplate, RetryPolicy, and the Retryable functional contract. A default RetryTemplate retries any exception up to three times after the initial attempt with a one second delay between attempts, and the policy can be restricted to specific exception types and adjusted through factory methods. Because Spring Boot 4 no longer manages the Spring Retry dependency, applications still using that project must declare an explicit version or move to the framework support. Plan the move: behavior defaults, attribute names, and listener extension points differ, so treat it as a behavior migration and cover retried paths with tests.$body$, $code$RetryPolicy policy = RetryPolicy.withMaxRetries(4);
RetryTemplate retry = new RetryTemplate(policy);

String status = retry.invoke(() -> gateway.fetchStatus(orderId));
String receipt = retry.invoke(() -> gateway.acknowledge(orderId));$code$),
    ('spring-7-resilience-features', 2, 'Declarative retry and limits', $body$Declarative support comes from two annotations. Retryable is applied at method or type level and adapts automatically to reactive methods by decorating the returned pipeline. Its attributes include includes and excludes for exception matching, maxRetries, delay, jitter, multiplier, and maxDelay; a plain method invocation runs through a RetryTemplate with a matching policy. ConcurrencyLimit caps simultaneous executions, which matters when nothing else bounds parallelism, especially with virtual threads. Both annotations are enabled by EnableResilientMethods on a configuration class, or individually with a RetryAnnotationBeanPostProcessor or ConcurrencyLimitBeanPostProcessor bean. The annotations are metadata that the application opts into, so a missing enablement is a silent no-op; verify limits and retries with tests or metrics.$body$, $code$@Retryable(
        includes = MessageDeliveryException.class,
        maxRetries = 4,
        delay = 100,
        jitter = 10,
        multiplier = 2,
        maxDelay = 1000)
public void sendNotification() {
    notifications.deliver(pending);
}$code$),
    ('spring-7-resilience-features', 3, 'Policy choices that hold up', $body$Retry converts transient failure into latency, so it must be bounded and honest. Retry only operations that are safe to repeat, or protect side effects with idempotency keys, and retry only exception categories that can succeed later. Bound total time with maxRetries and maxDelay, add jitter so coordinated clients do not retry in lockstep, and let the final failure propagate instead of returning a fallback that hides an outage. Retries amplify load on a struggling dependency, so pair them with circuit breaking and, where appropriate, concurrency limits from the framework or a portfolio library such as Resilience4j. Document the retry policy next to the call site and review it whenever the downstream service changes its failure modes.$body$, $code$@Configuration
@EnableResilientMethods
class ResilienceConfig {
}

class NotificationService {

    @ConcurrencyLimit(10)
    public void sendNotification() {
        notifications.deliver(pending);
    }
}$code$),
    ('spring-jackson-3-integration', 1, 'Tooling packages and defaults', $body$Jackson 3 changes the package namespace from com.fasterxml.jackson to tools.jackson, with one deliberate exception: the jackson-annotations module keeps the com.fasterxml.jackson.annotation package so annotations such as JsonProperty and JsonView continue to work during migration. Spring Boot 4 and Spring Framework 7 switch classpath detection and dependencies to Jackson 3, auto-configure Jackson 3, and deprecate Jackson 2 support. Some defaults changed as well: properties are now serialized in alphabetical order by default, which breaks tests that compare raw JSON strings, and dates serialize as ISO-8601 strings instead of numeric timestamps. Treat these default changes as test-visible behavior changes and review golden files rather than disabling the new behavior.$body$, $code$import tools.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.annotation.JsonProperty;

record OrderRequest(@JsonProperty String reference, int quantity) {
}$code$),
    ('spring-jackson-3-integration', 2, 'From ObjectMapper to JsonMapper', $body$Jackson 3 favors format-specific immutable mappers, and Spring now uses JsonMapper for JSON instead of the broad ObjectMapper. Spring Framework intentionally does not provide an equivalent of Jackson2ObjectMapperBuilder; customization happens through the Jackson JsonMapper.Builder, and Boot auto-configures JsonMapper and XmlMapper beans. Many modules, including parameter names and java.time support, are built in or discovered through the service loader, so manual module registration is usually unnecessary. To replace the auto-configured JSON mapper, define a JsonMapper bean; defining a plain ObjectMapper bean is not sufficient. When you build a mapper manually, register it with the message converters or the client that needs it, and keep that mapper immutable so configuration cannot drift.$body$, $code$JsonMapper mapper = JsonMapper.builder()
        .findAndAddModules()
        .build();

byte[] json = mapper.writeValueAsBytes(request);$code$),
    ('spring-jackson-3-integration', 3, 'Migration options and stop-gaps', $body$Migration can proceed at three speeds. The preferred path is a full move to Jackson 3: update imports and dependency coordinates, adjust builders, and accept the new defaults with updated assertions. A middle path sets spring.jackson.use-jackson2-defaults=true, which makes the auto-configured JsonMapper behave as closely as possible to Jackson 2 defaults from Boot 3 while still running Jackson 3. The slowest and least desirable path adds the deprecated spring-boot-jackson2 module, which restores Jackson 2 auto-configuration with spring.jackson2 properties while a library you depend on catches up. Whichever path you choose, note that Jackson 2 support is scheduled for removal in a later generation, so schedule the final migration instead of parking on a stop-gap.$body$, $code$# Preferred: migrate to Jackson 3 defaults and update tests.
# Middle path: keep Jackson 2 style defaults temporarily.
spring.jackson.use-jackson2-defaults=true

# Last resort stop-gap module: spring-boot-jackson2 (deprecated),
# configured through spring.jackson2.* properties.$code$),
    ('spring-aot-and-native-images', 1, 'What AOT processing decides', $body$AOT processing inspects the application context at build time and resolves discovery and conditional decisions that normally happen at startup. That produces generated Java sources, bytecode for dynamic proxies, and RuntimeHints describing reflection, resources, serialization, and proxies. It also freezes assumptions: the classpath is fixed, profile-based configuration is chosen at build time, and environment properties that drive conditional decisions are evaluated then. Bean definitions created from instance suppliers or registered as singletons after refresh cannot be transformed, and imprecise bean return types degrade the generated code. Design constraints follow from these rules, so keep configuration classes simple, declare concrete bean types, and use explicit profiles rather than runtime-toggled bean presence.$body$, $code$class OrderHints implements RuntimeHintsRegistrar {

    @Override
    public void registerHints(RuntimeHints hints, ClassLoader loader) {
        hints.reflection().registerType(Order.class);
        hints.resources().registerPattern("i18n/**");
    }
}$code$),
    ('spring-aot-and-native-images', 2, 'Hints for reflection and resources', $body$Native images analyze closed-world reachability, so anything loaded reflectively needs a hint. Spring Framework 7 uses the unified reachability metadata format with GraalVM 25. Resource hints now use glob patterns; a pattern such as /files/*.ext matches files directly under /files but not deeper entries, so use /files/**/*.ext when recursion is required, and hint excludes are no longer supported. Registering a reflection hint for a type now implies constructors, methods, and fields introspection, which makes most MemberCategory flags unnecessary; plain type registration is usually enough. Add hints through a RuntimeHintsRegistrar and keep the hint list small, since every registration extends the image and hides genuine reachability problems.$body$, $code$class DynamicFeatureTests {

    @DisabledInAotMode
    @Test
    void generatesProxiesAtRuntime() {
        assertThat(feature.createProxy()).isNotNull();
    }
}$code$),
    ('spring-aot-and-native-images', 3, 'Native builds in CI', $body$Native support should be a pipeline concern, not a release-week adventure. Add the process-aot execution of the Spring Boot Maven plugin, or the equivalent Gradle task, and use the native profile to wire the native build tools. Because a native image build is slow and memory hungry, run it at least nightly and on changes that touch configuration, reflection, or serialization, caching what the build allows. Tests that depend on dynamic behavior can be marked with DisabledInAotMode so the AOT test run stays green while the limitation stays visible. Track image build time, startup time, and memory against the JVM build, since fast startup matters most for scale-to-zero and function workloads, while long-running services may see little benefit for the operational cost.$body$, $code$<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>process-aot</goal>
            </goals>
        </execution>
    </executions>
</plugin>$code$),
    ('spring-modulith', 1, 'Package structure defines modules', $body$Spring Modulith treats an application main package as a module, and each direct subpackage of the main package as its own module. Types in a module base package form the module API, while nested packages such as order.internal are internals that other modules must not reference. There is no annotation required for this basic arrangement; the project inspects the package structure at runtime in tests. Nested modules can be declared explicitly with ApplicationModule, and a module can be marked open when its internals are a deliberate shared surface. The main pitfall is naming: if internals are not consistently placed in subpackages, nothing prevents cross-module references, and the architecture decays silently. Establish the convention before the codebase grows.$body$, $code$// package-info.java in the order module.
@ApplicationModule(allowedDependencies = "inventory")
package example.order;

import org.springframework.modulith.ApplicationModule;$code$),
    ('spring-modulith', 2, 'Verification keeps boundaries honest', $body$Verification turns conventions into tests. Calling ApplicationModules.of(Application.class).verify() checks three rules: no cycles between modules, access to other modules only through their API packages, and compliance with explicitly declared allowed dependencies when ApplicationModule(allowedDependencies) is configured. A violation throws, so the check belongs in the regular test suite and fails the build. When a violation is intentional and temporary, detectViolations() returns them so they can be filtered and documented rather than ignored. Module-level integration tests can be written with ApplicationModuleTest, which bootstraps only the module under test and its dependencies, and PublishedEvents can be injected to assert which events a business operation published.$body$, $code$class ModularityTests {

    @Test
    void verifiesModuleBoundaries() {
        ApplicationModules.of(Application.class).verify();
    }
}$code$),
    ('spring-modulith', 3, 'Events and generated documentation', $body$Modules should interact through events rather than direct calls into each other internals. Spring Modulith provides ApplicationModuleListener as a shortcut for an asynchronous transactional event listener, and its event publication registry records pending publications inside the original transaction so failed or missed deliveries can be republished after a restart. This converts an in-process event into an at-least-once delivery with a visible backlog, which is a different consistency contract than plain Spring events. For documentation, ApplicationModules can be handed to a Documenter that writes PlantUML component diagrams and an Application Module Canvas listing beans, aggregate roots, events, and configuration per module. Generated documentation keeps diagrams honest and reviewable in pull requests instead of drifting.$body$, $code$@Component
class InventoryManagement {

    @ApplicationModuleListener
    void on(OrderCompleted event) {
        restock(event.orderId());
    }
}$code$),
    ('spring-observability-and-tracing', 1, 'One observation, metrics and traces', $body$Micrometer Observation is the single instrumentation point for metrics and traces. Code creates an Observation with a name and an ObservationRegistry, and handlers turn it into a timer, long task timer, counters, and a span for the current trace, depending on configuration. Spring instrumentation and Boot auto-configuration produce observations such as http.server.requests and accept customization through observation conventions, predicates, filters, and registry customizers. A key design rule concerns cardinality: low-cardinality key values such as method, status, or region belong in metrics, while unbounded values such as user identifiers or full URIs belong only in traces, because metric tag explosions are expensive to store and query. Keep names and tags consistent so dashboards and alerts survive refactoring.$body$, $code$Observation.createNotStarted("order.process", registry)
        .lowCardinalityKeyValue("region", region)
        .observe(() -> handler.handle(order));

// Low cardinality tags reach metrics; high cardinality ones
// are reserved for traces.$code$),
    ('spring-observability-and-tracing', 2, 'Propagating context across threads', $body$Tracing only works when the current observation follows the work. The context propagation library reinstates observation state across threads and reactive pipelines, but the defaults are conservative. In reactive applications, set spring.reactor.context-propagation=auto so thread-local values are restored inside operators. For asynchronous methods using the auto-configured executor, set spring.task.execution.propagate-context=true; when you supply your own executor, register a ContextPropagatingTaskDecorator, since a plain task decorator is not applied automatically. Log correlation depends on the same mechanism: spans populate the logging context so lines carry trace and span identifiers. The common failure is fire-and-forget code that starts work with an executor or scheduler nobody decorated, producing traces that stop at the asynchronous boundary.$body$, $code$# Restore thread-local values inside reactive operators.
spring.reactor.context-propagation=auto

# Propagate observations into asynchronous methods on the executor.
spring.task.execution.propagate-context=true$code$),
    ('spring-observability-and-tracing', 3, 'Instrumenting code and exporting', $body$Framework instrumentation covers HTTP, JMS, and scheduled tasks, but application-level operations usually need their own observations so business latency is visible. Create them programmatically for reliable naming and tags, or enable Micrometer annotations such as Observed, Timed, and Counted with management.observations.annotations.enabled=true plus an AspectJ weaver dependency. For export, the dedicated OpenTelemetry starter brings the dependencies and auto-configures the SDK to ship metrics and traces over OTLP. Be deliberate about sampling: head sampling keeps overhead predictable but can drop rare failures, so keep metrics as the complete record and use traces for detail. Export failures should never affect request handling, and noisy but low-value spans should be filtered rather than tolerated.$body$, $code$// Requires management.observations.annotations.enabled=true
// and an AspectJ weaver dependency.
@Observed(name = "payment.capture")
public Receipt capture(Payment payment) {
    return gateway.capture(payment);
}$code$),
    ('spring-virtual-threads', 1, 'Enabling virtual threads in Boot', $body$Spring Boot exposes virtual threads through one switch: set spring.threads.virtual.enabled=true on Java 21 or later. When enabled, servlet containers such as Tomcat and Jetty process requests on virtual threads, the auto-configured application task executor becomes a SimpleAsyncTaskExecutor backed by virtual threads, and integrations such as asynchronous request handling use it. Boot also notes that thread pool properties stop applying, because virtual threads are scheduled on a JVM-wide carrier pool rather than a dedicated pool. The current documentation recommends Java 24 or later for the best experience. Because the change affects every blocking path at once, enable it in a representative environment, measure throughput and latency, and watch downstream resources such as database connection pools.$body$, $code$# Requires Java 21 or later; Java 24 or later is recommended.
spring.threads.virtual.enabled=true

# While enabled, containers such as Tomcat handle requests on
# virtual threads and pool sizing properties no longer apply.$code$),
    ('spring-virtual-threads', 2, 'Where virtual threads help', $body$Virtual threads make waiting cheap. They pay off when request handling spends time blocked on network calls, file access, message brokers, or JDBC with a limited number of concurrently executing requests: a thread that blocks no longer consumes a platform thread, so a modest carrier pool can serve many thousands of in-flight requests. They do not make CPU-bound work faster, and they do not increase the capacity of a database, a remote service, or a connection pool. Without another limit, unbounded concurrency reaches downstream systems and can turn a slow dependency into an outage, so combine virtual threads with bounded resources: pool sizes for expensive resources, semaphores, or the framework concurrency limiting support. Measure concurrency needs from empirical evidence rather than from the number of threads.$body$, $code$@Bean
AsyncTaskExecutor applicationTaskExecutor() {
    SimpleAsyncTaskExecutor executor = new SimpleAsyncTaskExecutor();
    executor.setVirtualThreads(true);
    executor.setConcurrencyLimit(50);
    return executor;
}$code$),
    ('spring-virtual-threads', 3, 'Pinning and thread-local caveats', $body$Pinning is what happens when a virtual thread cannot unmount from its carrier, blocking a platform thread while it waits. Historically, blocking inside synchronized blocks and methods caused pinning; Java 24 removed nearly all of those cases through JEP 491, so synchronized no longer prevents unmounting. Remaining sources, such as class initialization and native frames, are rarer and should be diagnosed with JDK Flight Recorder or the jcmd tool rather than guessed at. Thread-locals deserve separate attention: each virtual thread gets its own copy of mutable thread-local state, and applications that create hundreds of thousands of threads can multiply what were previously pooled values into substantial memory. Keep thread-local state small, avoid using thread-locals to cache per-worker data, and never assume a thread is reused.$body$, $code$// Every virtual thread that touches this gets its own copy,
// so large values multiply quickly at high thread counts.
static final ThreadLocal<byte[]> BUFFER =
        ThreadLocal.withInitial(() -> new byte[64 * 1024]);

void handle() {
    BUFFER.get()[0] = 1;
}$code$),
    ('spring-boot-testcontainers', 1, 'Service connections replace plumbing', $body$A service connection is a contract between a container and auto-configuration. Annotating a container Bean or a static Container field with ServiceConnection makes Spring Boot publish ConnectionDetails for the matching technology, and auto-configuration consumes them in preference to connection properties. That removes DynamicPropertySource blocks and property juggling from tests while keeping real clients, drivers, and dialects in play. Spring Boot has supported the concept since 3.1 and continues it in Boot 4, which upgrades to Testcontainers 2.0 and extends support to more container types. Use containers where behavior is engine-specific: SQL dialects, transaction semantics, serialization, and protocol details that an in-memory substitute would silently fake. Mocks still have a place for orchestration logic.$body$, $code$@TestConfiguration(proxyBeanMethods = false)
class ContainersConfig {

    @Bean
    @ServiceConnection
    Neo4jContainer neo4jContainer() {
        return new Neo4jContainer("neo4j:5");
    }
}$code$),
    ('spring-boot-testcontainers', 2, 'Managing container lifecycle', $body$How containers are managed determines how stable tests are. When containers are Spring beans, they start before other beans and stop after them, and they live as long as the cached application context, which is what the TestContext framework expects. The JUnit extension stops containers when the class ends, while a cached context created for that test configuration may still be reused by later classes, leaving beans that reference a dead container. That failure mode is timing dependent and costs hours to debug. When containers must be declared as static fields, use the interface pattern and import the declarations into the Spring test context, which keeps the lifecycle aligned with the application context. Watch memory and disk usage, because cached contexts retain ports and containers.$body$, $code$@SpringBootTest
@Testcontainers
class OrderRepositoryTests {

    @Container
    @ServiceConnection
    static Neo4jContainer neo4j = new Neo4jContainer("neo4j:5");
}$code$),
    ('spring-boot-testcontainers', 3, 'Development-time service options', $body$Testcontainers does not have to stop at tests. Boot dev services support two styles for local development. The Docker Compose module finds a compose file, starts the declared services, creates service connections for supported images, and stops them at shutdown, so an application runs against real infrastructure with no code change. Testcontainers at development time launches the real application with a test classpath and container beans, typically through SpringApplication.from with the test configuration, which keeps definitions in Java instead of YAML. Both approaches reduce the distance between development and production behavior, but they demand Docker on every developer machine and a team policy for image versions. Pin image tags so environments stay consistent, and keep heavy services optional for quick unit work.$body$, $code$interface MyContainers {

    @Container
    @ServiceConnection
    Neo4jContainer neo4j = new Neo4jContainer("neo4j:5");
}

@ImportTestcontainers(MyContainers.class)
@SpringBootTest
class OrderRepositoryTests {
}$code$),
    ('spring-graphql-basics', 1, 'Schema first with SDL', $body$A Spring for GraphQL application needs a schema at startup. By default Boot picks up .graphqls or .gqls files under classpath:graphql, and spring.graphql.schema.locations and spring.graphql.schema.file-extensions customize discovery. The schema is the contract: it declares types, queries, mutations, and the exact field shapes clients can rely on. Controller methods bind to fields: QueryMapping for queries, MutationMapping for mutations, SchemaMapping for nested fields, with Argument for input arguments and Controller for the stereotype. A Boot starter and a transport starter are both required, because GraphQL itself is transport agnostic. The pitfall is letting the schema drift from the domain; treat schema changes as API changes with review, versioning notes, and tests.$body$, $code$@Controller
class GreetingController {

    @QueryMapping
    String hello() {
        return "Hello, world!";
    }
}$code$),
    ('spring-graphql-basics', 2, 'Thin and explicit fetchers', $body$Fetchers should resolve a field and delegate, not contain business logic. A fetcher typically loads an object or calls a service; authorization, validation, and transaction boundaries belong in the service layer, where they can be reused and tested. GraphQL responses return HTTP 200 with an errors array even when fields fail, so error handling is part of the API contract rather than something the status code communicates. Avoid returning persistence entities directly; map to types defined in the schema so internal fields cannot leak. Resolver return types matter too: blocking fetchers on reactive transports stop scaling, and mixing return types such as Mono, Flux, and CompletableFuture without a rule makes behavior hard to reason about. Document the convention and enforce it in review.$body$, $code$type Query {
    books: [Book]
}

type Book {
    id: ID!
    title: String!
    author: Author
}$code$),
    ('spring-graphql-basics', 3, 'Avoiding the N plus one problem', $body$A nested field is resolved for every parent object, so a query that returns one hundred books and asks for each author can issue one hundred separate lookups. That is the N plus one select problem, and GraphQL exposes it more easily than REST because clients choose the shape. Batching solves it: register a batch loading function through BatchLoaderRegistry, or annotate a handler with BatchMapping so all parents resolve in one call, returning a map from parent to value. DataLoaders batch and cache within a single request only, so the fix must be per-request and must not assume cross-request caching. Instrument and test nested queries under realistic loads, because the problem grows with result size.$body$, $code$@Controller
class BookController {

    @BatchMapping
    Mono<Map<Book, Author>> author(List<Book> books) {
        return authorService.loadFor(books);
    }
}$code$),
    ('spring-websockets', 1, 'Choosing a push transport', $body$Not every live update needs a socket. Polling is simplest, works with any infrastructure, and is often adequate when updates are infrequent or slight staleness is acceptable. Server-sent events stream one-way updates over HTTP, reconnect automatically in browsers, and pass through most proxies with less ceremony than a socket. WebSocket provides a full-duplex connection with low overhead per message, and STOMP layered on top adds destinations, subscriptions, and message semantics so handlers look like controllers. Choose the weakest mechanism that meets the latency and direction requirements: server push only needs SSE, request and response patterns need polling or HTTP, and interactive flows where both sides push regularly justify WebSocket. Complexity must be paid for by a user-visible requirement.$body$, $code$@Configuration
@EnableWebSocketMessageBroker
class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/portfolio");
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.setApplicationDestinationPrefixes("/app");
    }
}$code$),
    ('spring-websockets', 2, 'Configuring STOMP endpoints', $body$A STOMP configuration annotates a configuration class with EnableWebSocketMessageBroker and implements WebSocketMessageBrokerConfigurer. Endpoints are registered with the registry, for example at /portfolio, which is the URL a client connects to for the handshake. In the broker configuration, set application destination prefixes such as /app for messages routed to MessageMapping methods, and enable a simple broker for prefixes such as /topic and /queue so subscriptions and broadcasts are handled in memory. Handlers can use DestinationVariable, SubscribeMapping, and SendTo or SendToUser to control replies. The simple broker is convenient but in-memory, so an external broker relay is the production path when several instances must see the same subscriptions, and heartbeats require a scheduler.$body$, $code$@Controller
class PortfolioController {

    @MessageMapping("/orders/{symbol}")
    @SendTo("/topic/prices")
    Price update(@DestinationVariable String symbol, Order order) {
        return market.bestPrice(symbol);
    }
}$code$),
    ('spring-websockets', 3, 'Scaling WebSocket workloads', $body$WebSocket connections are long-lived and stateful, which changes scaling math. Each connected client occupies memory and a subscription entry, and a broadcast to a popular topic fans out to every subscriber, so message size and frequency multiply quickly. Inbound and outbound messages flow through dedicated channels backed by thread pools; IO-bound handlers need a larger inbound pool, while slow clients make the outbound pool the bottleneck because messages queue for delivery. Horizontally, instances must share subscriptions through a broker relay or route clients to the instance holding their session, and load balancers need session affinity and idle timeout settings that exceed normal HTTP values. Authenticate at the handshake, authorize per destination, and bound message sizes and send rates.$body$, $code$@Override
public void configureClientInboundChannel(ChannelRegistration registration) {
    registration.taskExecutor().corePoolSize(16).maxPoolSize(32);
}

@Override
public void configureClientOutboundChannel(ChannelRegistration registration) {
    registration.taskExecutor().corePoolSize(8).maxPoolSize(16);
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
    'spring-framework-7-overview', 'spring-boot-4-overview',
    'migrating-spring-boot-3-to-4', 'spring-7-null-safety-jspecify',
    'spring-7-api-versioning', 'spring-7-resilience-features',
    'spring-jackson-3-integration', 'spring-aot-and-native-images',
    'spring-modulith', 'spring-observability-and-tracing',
    'spring-virtual-threads', 'spring-boot-testcontainers',
    'spring-graphql-basics', 'spring-websockets'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
