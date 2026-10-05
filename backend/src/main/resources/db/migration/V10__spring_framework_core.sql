-- V10 — Spring Framework 6 core and web tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('spring-ecosystem-and-boot-overview', 'Spring Ecosystem and Boot Overview', 'Separate what the Spring Framework provides from what Spring Boot adds, and know the Spring 6 baseline.', 'Junior', 24, true, 1),
    ('spring-ioc-container', 'The Spring IoC Container', 'Learn how the ApplicationContext creates and wires beans so composition stays testable.', 'Junior', 20, true, 1),
    ('spring-dependency-injection-patterns', 'Spring Dependency Injection Wiring Patterns', 'Choose constructor, setter, and qualifier wiring deliberately for the dependencies a class needs.', 'Junior', 26, true, 1),
    ('spring-bean-lifecycle-and-scopes', 'Spring Bean Lifecycle and Scopes', 'Understand when Spring creates, initializes, and destroys beans and which scope fits the job.', 'Junior', 24, true, 1),
    ('spring-stereotypes-and-component-scanning', 'Stereotypes and Component Scanning', 'Use stereotype annotations and scanning rules so the container registers exactly what you intend.', 'Mid', 26, true, 1),
    ('spring-configuration-properties-and-profiles', 'Configuration Properties and Profiles', 'Bind external configuration into typed objects and vary it safely across environments.', 'Mid', 28, true, 1),
    ('spring-autoconfiguration-and-conditional-beans', 'Auto-configuration and Conditional Beans', 'See how conditional annotations drive auto-configuration and how to debug and extend it.', 'Mid', 30, true, 1),
    ('spring-application-events', 'Application Events in Spring', 'Publish and observe events to decouple modules without hiding control flow.', 'Mid', 28, true, 1),
    ('spring-aop-fundamentals', 'Spring AOP Fundamentals', 'Understand proxy-based aspects, maintainable pointcuts, and where cross-cutting advice pays off.', 'Mid', 30, true, 1),
    ('spring-validation-and-binding', 'Validation and Request Binding', 'Validate at the boundary with Bean Validation and fail fast with actionable errors.', 'Mid', 28, true, 1),
    ('spring-mvc-request-handling', 'Spring MVC Request Handling', 'Follow the DispatcherServlet flow and design REST controllers that stay thin.', 'Mid', 30, true, 1),
    ('spring-rest-controllers-and-content-negotiation', 'REST Controllers and Content Negotiation', 'Shape responses with ResponseEntity, media types, and headers that clients can rely on.', 'Mid', 30, true, 1),
    ('spring-error-handling-and-problem-details', 'Error Handling and Problem Details', 'Map exceptions to RFC 9457 problem responses in one consistent place.', 'Mid', 30, true, 1),
    ('spring-http-clients', 'HTTP Clients in Spring', 'Compare RestClient, WebClient, and RestTemplate and configure timeouts that apply.', 'Mid', 32, true, 1),
    ('spring-testing-slices', 'Testing Slices and Context Caching', 'Use targeted test slices and context caching to keep integration suites fast and trustworthy.', 'Senior', 34, true, 1),
    ('spring-actuator-basics', 'Spring Boot Actuator Basics', 'Expose health, info, and metrics endpoints and secure the actuator for production.', 'Senior', 32, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('spring-ecosystem-and-boot-overview', 1, 'From framework to Boot', $body$The Spring Framework supplies the core container, dependency injection, web MVC, and integration abstractions. Spring Boot sits on top: it adds auto-configuration, curated starters, an embedded server, and externalized configuration so an application starts from a single main method. Spring Data, Security, and Cloud are independent projects that build on both and are versioned to work together. Adding a library should be a deliberate choice about which project you need: reach for the framework when a capability is core, and a project when it owns a domain such as data access or authorization.$body$, $code$@SpringBootApplication
public class OrdersApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrdersApplication.class, args);
    }
}$code$),
    ('spring-ecosystem-and-boot-overview', 2, 'What Boot adds on top', $body$Boot inspects the classpath and your existing beans, then registers sensible defaults. If Spring Data JPA and an in-memory driver are present and no DataSource bean exists, Boot creates one; define your own bean of that type and the auto-configuration backs off. Treat generated configuration as a replaceable starting point rather than a contract. Keep defaults visible during review so nobody assumes that a connection pool size, a datasource URL, or a JSON mapper was chosen deliberately, and remember that a different classpath silently changes what Boot contributes.$body$, $code$try (ConfigurableApplicationContext context =
        SpringApplication.run(OrdersApplication.class, args)) {
    System.out.println(context.getBeanDefinitionCount());
    OrderRepository repository = context.getBean(OrderRepository.class);
}$code$),
    ('spring-ecosystem-and-boot-overview', 3, 'The Spring 6 and Boot 3 baseline', $body$The Spring 6 generation raises the Java baseline to 17 and moves to the Jakarta EE 9 namespace, so imports use jakarta.* rather than javax.*. It is the generation behind Spring Boot 3.x, and it also introduced first-class AOT processing for native images. Dependencies must be aligned: Hibernate, Tomcat, and the validation API all need versions from the same generation, and a single library importing javax.servlet is a reliable signal that it has not been migrated. Verify the baseline before adopting a starter, because one stale transitive dependency blocks an otherwise straightforward upgrade.$body$, $code$import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class Order {
    @Id
    private Long id;
}$code$),
    ('spring-ioc-container', 1, 'The container creates objects', $body$Inversion of control means the container, not your code, decides when an object is constructed, configured, and replaced. You describe bean definitions; the ApplicationContext instantiates them, resolves their dependencies, and manages lifecycle callbacks. This enables composition at application scale: swap a payment client for a test double, or select a repository implementation by profile, without editing business logic. The pitfall is losing that boundary. When classes reach into the context to fetch collaborators at call time, the dependency graph becomes invisible, tests grow brittle, and startup no longer verifies that everything a class needs is available.$body$, $code$@Configuration
public class ClockConfig {
    @Bean
    Clock clock() {
        return Clock.systemUTC();
    }
}$code$),
    ('spring-ioc-container', 2, 'Bean definitions and configuration', $body$Annotated classes and @Bean methods are read into bean definitions that record type, name, scope, and dependencies. The default scope is singleton, so one shared instance serves the entire context; that makes configuration state global, which is fine for stateless collaborators and risky for mutable state. Keep bean methods small and free of branching where possible, because conditional creation inside configuration is difficult to test and easy to misread. Prefer constructor parameters to context lookups, and let configuration stay declarative. When a bean method does need a dependency, accept it as a parameter rather than calling getBean.$body$, $code$try (AnnotationConfigApplicationContext context =
        new AnnotationConfigApplicationContext(ClockConfig.class)) {
    Clock clock = context.getBean(Clock.class);
    System.out.println(clock.instant());
}$code$),
    ('spring-ioc-container', 3, 'Composition that stays testable', $body$Because dependencies are constructor parameters, a unit test can construct the class directly with fakes and never start a container. The container earns its place in integration tests and production wiring, while domain code stays plain Java. When a class needs more than a handful of collaborators, that is a design signal rather than a wiring problem, so consider splitting responsibilities before adding another injection point. Rule of thumb: if exercising business logic requires an ApplicationContext, the object probably knows too much about its environment; constructor access to collaborators should always be enough.$body$, $code$class PricingService {
    private final Clock clock;

    PricingService(Clock clock) { this.clock = clock; }

    Instant quoteTime() { return clock.instant(); }
}$code$),
    ('spring-dependency-injection-patterns', 1, 'Constructor injection for required edges', $body$Mark required dependencies as final and pass them through the constructor. Spring resolves them at startup and fails fast when a bean is missing, which converts a wiring mistake into a startup error rather than a null pointer at first use. Constructor injection also keeps the class instantiable without a container, which matters for tests and for reasoning about the dependency list. With a single constructor the @Autowired annotation is optional. The common pitfall is a constructor that grows with every new requirement; that usually means the class is accumulating responsibilities rather than needing more wiring support.$body$, $code$@Service
public class InvoiceService {
    private final TaxClient taxClient;

    public InvoiceService(TaxClient taxClient) {
        this.taxClient = taxClient;
    }
}$code$),
    ('spring-dependency-injection-patterns', 2, 'Setter injection for optional edges', $body$Setter or field injection suits genuinely optional collaborators and framework-managed edges, but it hides required dependencies and allows partially built objects to reach callers. Field injection also prevents final fields and complicates plain unit tests, since the object cannot be assembled without reflection. Use @Autowired(required = false) or ObjectProvider when a collaborator may legitimately be absent, and keep that optionality rare; every optional dependency is a branch that production has to exercise. If a class cannot function without a collaborator, state that in the constructor instead.$body$, $code$@Service
public class ReportService {
    private Clock clock = Clock.systemUTC();

    @Autowired(required = false)
    void setClock(Clock clock) {
        this.clock = clock;
    }
}$code$),
    ('spring-dependency-injection-patterns', 3, 'Ambiguity, primary beans, and cycles', $body$When several beans match a requested type, resolve the choice where it is made: @Primary marks a default candidate, and @Qualifier at the injection point selects by name or custom qualifier. Rely on neither bean name luck nor discovery order. Circular dependencies between singletons are a design signal; the container can sometimes inject a proxy, but the resulting call graph is hard to reason about and breaks under lazy initialization. Break the cycle by extracting the shared collaborator or publishing an event. Treat qualifier and cycle failures at startup as feedback about the object model.$body$, $code$@Service
public class PaymentRouter {
    private final PaymentGateway gateway;

    PaymentRouter(@Qualifier("stripe") PaymentGateway gateway) {
        this.gateway = gateway;
    }
}$code$),
    ('spring-bean-lifecycle-and-scopes', 1, 'Initialization and destruction callbacks', $body$After dependency injection completes, Spring invokes initialization hooks: @PostConstruct, the InitializingBean callback, or an initMethod reference on a @Bean method. When the context closes, it calls @PreDestroy or the matching disposable callback. Use these hooks to validate configuration and warm expensive but predictable resources, not to run business logic with side effects, because construction order is not a business contract. Short-lived applications rarely notice missing shutdown hooks, yet production deployments that ignore @PreDestroy drop open connections and leak thread pools during rolling restarts. Keep callbacks short and free of remote calls that can hang startup.$body$, $code$@Component
public class CacheWarmer {
    @PostConstruct
    void load() {
        referenceData.refresh();
    }

    @PreDestroy
    void release() {
        referenceData.close();
    }
}$code$),
    ('spring-bean-lifecycle-and-scopes', 2, 'Post-processors and proxy semantics', $body$BeanPostProcessor instances run around every bean initialization and are how Spring implements annotation injection, @Transactional, scheduling, and validation. Two consequences matter in production. First, a post-processor affects only the beans created after it is registered, so ordering can change behavior in ways that are hard to see. Second, annotation-driven features create proxies, which means a @Transactional annotation on a private method or a self-invoked call does nothing. When an annotation appears ignored, check that the call actually passes through the proxy before debugging the annotation itself.$body$, $code$@Transactional
public void placeOrder(Order order) { }

void retry(Order order) {
    placeOrder(order); // self-invocation bypasses the proxy
}$code$),
    ('spring-bean-lifecycle-and-scopes', 3, 'Singleton, prototype, and request scope', $body$Singleton is the default and the right choice for stateless services and shared infrastructure. Prototype creates a new instance on every lookup, and Spring does not manage destruction for prototypes; the container keeps no reference, so cleanup is your responsibility. Request and session scopes carry web state and only behave sensibly inside an active request. When a singleton needs a shorter-lived collaborator, inject ObjectProvider or a scoped proxy instead of storing the shorter-lived object in a field. Choosing a wider scope than necessary is how mutable state and memory leaks enter a service.$body$, $code$@Service
public class RequestHandler {
    private final ObjectProvider<Draft> drafts;

    RequestHandler(ObjectProvider<Draft> drafts) {
        this.drafts = drafts;
    }
}$code$),
    ('spring-stereotypes-and-component-scanning', 1, 'Choosing the right stereotype', $body$@Component, @Service, @Repository, and @Controller all mark a class for scanning, but they carry different intent. @Controller also marks web handlers for MVC machinery, and @Repository adds persistence exception translation. Choose the annotation that describes the role, and keep business logic out of both controllers and repositories. A component that could honestly be any of the four is usually a design smell: decide whether it orchestrates a use case, represents a domain concept, or talks to an infrastructure boundary, then label it accordingly. Consistent labels make reviews and static analysis more useful.$body$, $code$@Repository
public class JdbcOrderRepository implements OrderRepository { }

@Service
public class OrderService {
    private final OrderRepository orders;

    OrderService(OrderRepository orders) { this.orders = orders; }
}$code$),
    ('spring-stereotypes-and-component-scanning', 2, 'Scanning rules and boundaries', $body$@SpringBootApplication scans its own package and everything below it, so placing the main class at the root package of your code keeps every component discoverable. Classes outside that tree are invisible unless you widen scanBasePackages, which can accidentally pick up third-party or test code. Filters such as excludeFilters and ComponentScan.Filter refine results but are one short step away from surprising behavior. Prefer a narrow, explicit scan with a deliberate package layout over increasingly clever filters, and verify that a new module is reachable from the existing configuration rather than forcing a scan change.$body$, $code$@SpringBootApplication(scanBasePackages = "com.acme")
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}$code$),
    ('spring-stereotypes-and-component-scanning', 3, 'Explicit configuration versus scanning', $body$For application services, scanning is convenient and reviewable. For library-style infrastructure, test fixtures, and configuration with conditional branches, prefer explicit @Configuration classes or an @Import so all wiring is readable in one place. Mixing the two styles is normal in real applications, but the rule should be predictable: a bean a reviewer can find by reading a named configuration class does not need to be discovered by scanning. When startup surprises you, listing the registered bean names is faster and more reliable than guessing about scan behavior.$body$, $code$@Configuration(proxyBeanMethods = false)
public class BillingConfig {
    @Bean
    BillingPolicy billingPolicy() {
        return BillingPolicy.standard();
    }
}$code$),
    ('spring-configuration-properties-and-profiles', 1, 'Typed binding beats scattered lookups', $body$@ConfigurationProperties binds a prefix to a record or bean with type conversion and relaxed name matching, so orders.timeout and ORDERS_TIMEOUT map to the same field. @Value works for one-off settings but scales poorly: no grouping, no validation, and conversion errors surface at first use rather than startup. Register property classes with @EnableConfigurationProperties or @ConfigurationPropertiesScan, then validate them so a malformed value fails during boot. Typed configuration documents intent, lets refactoring tools follow renames, and gives tests a small object to construct. Prefer a properties class whenever a group of settings belongs together.$body$, $code$@ConfigurationProperties(prefix = "orders")
@Validated
public record OrdersProperties(
        @Positive Duration timeout,
        @NotEmpty String topic) { }$code$),
    ('spring-configuration-properties-and-profiles', 2, 'Profile-specific configuration files', $body$Profiles activate groups of configuration such as application-prod.yaml, and @Profile restricts beans to an environment. Use profiles for genuine environment differences, not as a feature flag system: combinatorial profiles multiply quickly and few teams test every combination. Keep the default configuration runnable without any profile so a new developer or a continuous integration job needs no special flags, and make profile-specific files contain only the differences from the default. Prefer a small number of deployment profiles over inheritance chains, and document which settings each profile is expected to override.$body$, $code$spring:
  config:
    activate:
      on-profile: prod
orders:
  timeout: 2s$code$),
    ('spring-configuration-properties-and-profiles', 3, 'Externalized configuration precedence', $body$Spring Boot resolves properties from many sources, and later sources override earlier ones. Command line arguments and environment variables take precedence over packaged application.yaml files, which is what makes deployment overrides possible without rebuilding an artifact. Two rules keep this predictable: do not assume a packaged default applies in production when an environment variable exists, and log the active profile and relevant property values at startup when diagnosing behavior. Tests can inject dynamic or test-specific property sources, which changes precedence again and can hide a mismatch that only appears in production.$body$, $code$Environment env;

String profile = env.getProperty("spring.profiles.active");
Duration timeout =
    env.getProperty("orders.timeout", Duration.class);
logger.info("profile={} timeout={}", profile, timeout);$code$),
    ('spring-autoconfiguration-and-conditional-beans', 1, 'Conditions that drive auto-configuration', $body$Boot auto-configuration classes are guarded by conditions: @ConditionalOnClass, @ConditionalOnMissingBean, @ConditionalOnProperty, and others decide whether a definition is registered. Classes are evaluated in a defined order, and defaults usually back off when your own bean exists, which is why declaring a bean is the supported way to override behavior. The practical consequence is that every contribution is inspectable: read the condition on the class you expected, and you usually learn why it did or did not apply. Treat auto-configuration as a default, not as a contract you cannot change.$body$, $code$@AutoConfiguration
@ConditionalOnClass(DataSource.class)
@ConditionalOnProperty(name = "orders.audit.enabled",
        havingValue = "true")
public class AuditAutoConfiguration { }$code$),
    ('spring-autoconfiguration-and-conditional-beans', 2, 'Reading the condition report', $body$Running with the debug flag prints a condition evaluation report that lists positive and negative matches with the reason for each. That report is faster than guessing why a bean is missing, and the actuator conditions endpoint exposes the same information for a running application. Start from the specific auto-configuration class you expected: a negative match names the missing class, property, or bean. Remember that the report describes the context that was actually created, not the one you intended, so keep it with bug reports about startup behavior.$body$, $code$java -jar orders.jar --debug

// Positive matches:
//   DataSourceAutoConfiguration matched
// Negative matches:
//   MongoAutoConfiguration did not match$code$),
    ('spring-autoconfiguration-and-conditional-beans', 3, 'Writing a custom condition', $body$Implement the Condition interface and decide in matches by inspecting the ConditionContext, which exposes the class loader, environment, bean factory, and resources. Conditions must not touch bean instances: they run while definitions are registered, before instances exist, and interacting with beans is explicitly outside their contract. Keep the logic small and deterministic, and prefer a Boot condition annotation when one already expresses the rule. A condition is a build-time decision for the context, so it must not be used for runtime feature checks that are supposed to react to configuration changes without a restart.$body$, $code$public class OnFeatureFlag implements Condition {
    @Override
    public boolean matches(ConditionContext context,
                           AnnotatedTypeMetadata metadata) {
        return context.getEnvironment()
            .matchesProfiles("feature-flag");
    }
}$code$),
    ('spring-application-events', 1, 'Publishing events without coupling', $body$ApplicationEventPublisher delivers events to @EventListener methods. By default listeners run synchronously on the publishing thread, so a listener failure propagates to the publisher and a slow listener slows the request. That default is simple and predictable, but it also blurs the boundary between in-process notification and messaging. Many application events are a decoupling technique rather than a delivery guarantee: treat them as in-process notifications, and reach for a broker when durability, retries, or delivery across service instances are required. Do not imply guarantees the publisher does not provide.$body$, $code$@Service
public class OrderService {
    private final ApplicationEventPublisher events;

    void place(Order order) {
        events.publishEvent(new OrderPlaced(order.id()));
    }
}$code$),
    ('spring-application-events', 2, 'Listener phases and transactions', $body$@TransactionalEventListener binds a listener to a transaction phase. AFTER_COMMIT runs only when the transaction committed, which is the safe default for side effects such as sending mail or publishing to another system. AFTER_ROLLBACK and AFTER_COMPLETION cover the other outcomes, and when no transaction is active the listener does not run unless fallbackExecution is enabled. Order across ordinary listeners follows @Order, but that order should not carry business meaning. Commit does not imply exactly-once delivery, so design listeners to tolerate duplicates and replays wherever possible.$body$, $code$@Component
class OrderNotifications {
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    void onOrderPlaced(OrderPlaced event) {
        notifications.send(event.orderId());
    }
}$code$),
    ('spring-application-events', 3, 'Events that break module cycles', $body$Events remove a direct dependency: the publisher does not know who listens. That is valuable when a module would otherwise depend on a downstream module, but it also hides control flow, since reading the publisher no longer reveals what happens next. Use events at module boundaries where reactions are optional and failure can be absorbed, and keep mandatory steps in a direct call that a reader can follow. Document the events a module publishes, keep payloads immutable and explicit instead of reusing persistence entities, and avoid events as a substitute for a missing abstraction.$body$, $code$record OrderPlaced(String orderId) { }

@Component
class LoyaltyListener {
    @EventListener
    void award(OrderPlaced event) {
        points.credit(event.orderId());
    }
}$code$),
    ('spring-aop-fundamentals', 1, 'Proxies are the mechanism', $body$Spring AOP creates a proxy around a bean and invokes advice before, after, or around method calls. For interface-based beans it normally uses a JDK dynamic proxy; otherwise a CGLIB subclass, which is why final classes and final methods cannot be advised. Advice wraps the entire method invocation, so a retry, timing, or transaction boundary applies to the whole call including any framework machinery inside it. The most common surprise is self-invocation: a call from one method of a bean to another does not pass through the proxy and therefore receives no advice.$body$, $code$@Around("@annotation(com.acme.Timed)")
public Object time(ProceedingJoinPoint joinPoint) throws Throwable {
    long start = System.nanoTime();
    try {
        return joinPoint.proceed();
    } finally {
        metrics.record(System.nanoTime() - start);
    }
}$code$),
    ('spring-aop-fundamentals', 2, 'Pointcuts worth maintaining', $body$A pointcut selects the join points where advice applies, and maintainable pointcuts usually anchor to an annotation or a named package rather than to method name patterns. A pointcut such as @annotation(com.acme.Timed) is explicit: a reader can see the marker on the method and understand why advice runs. Broad expressions that match everything in a package apply silently to new code, and tests rarely notice the extra behavior. Match narrowly, document the reason each aspect exists, and resist applying cross-cutting concerns everywhere simply because the expression is easy to write.$body$, $code$@Aspect
@Component
public class TimingAspect {
    @Around("@annotation(com.acme.Timed)")
    public Object measure(ProceedingJoinPoint call) throws Throwable {
        return call.proceed();
    }
}$code$),
    ('spring-aop-fundamentals', 3, 'Where aspects help and hurt', $body$Aspects fit uniform, policy-like concerns: transactions, security checks, metrics, retries, and caching. They hurt when they encode business rules, because the behavior disappears from the call site, stack traces show proxies rather than domain code, and debugging requires knowing the advice. Two rules keep aspects honest. First, make advice visible in logs or metrics when it changes behavior. Second, never let one aspect both decide and act on business state. If removing an aspect would change what the application means, the logic belongs in the method, not in the advice.$body$, $code$@Service
public class TransferService {
    @Transactional
    @Timed
    public void transfer(Money amount) {
        accounts.debit(amount);
    }
}$code$),
    ('spring-validation-and-binding', 1, 'Constraints at the boundary', $body$Constraints on boundary models are checked by the framework when an object is bound, so invalid input produces a 400 response before business code runs. @Valid triggers validation of a method argument in Spring MVC, and nested objects need @Valid on the field for validation to cascade. Put constraints on the input model and on domain values that can be constructed directly, and write messages a caller can act on. A boundary that accepts anything and fails later is more expensive to operate, because compensating logic and unclear errors spread through the codebase.$body$, $code$public record CreateOrderRequest(
        @NotBlank String customerId,
        @Positive @Max(1000) int quantity,
        @Valid Address address) { }$code$),
    ('spring-validation-and-binding', 2, 'Custom validators for domain rules', $body$When a rule cannot be expressed with built-in constraints, implement ConstraintValidator and annotate fields with your own annotation. Keep validators free of input and output: they must be fast, deterministic, and side-effect free, so uniqueness checks and remote lookups belong in a service method that can return a proper error. Validation groups help when create and update rules differ, and they are cleaner than relaxing constraints until both cases pass. Message interpolation can reuse the constraint parameters, so a single validator can produce a precise message for several limits.$body$, $code$@Constraint(validatedBy = IbanValidator.class)
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidIban {
    String message() default "invalid IBAN";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}$code$),
    ('spring-validation-and-binding', 3, 'Failing fast with useful errors', $body$Validation failures should be reported before any state changes and in one consistent response shape. Bind the binding result or handle the framework exception in a single advice method instead of catching it in individual handlers, and map failures into the API error contract such as a problem-details response. Do not delete constraints to make a test pass; fix the contract or the caller. Validate configuration properties at startup as well, because a missing or implausible value is far cheaper to correct before traffic than after the first request fails.$body$, $code$@PostMapping("/orders")
ResponseEntity<OrderId> create(
        @Valid @RequestBody CreateOrderRequest request) {
    OrderId id = orders.create(request);
    return ResponseEntity.ok(id);
}$code$),
    ('spring-mvc-request-handling', 1, 'The DispatcherServlet pipeline', $body$DispatcherServlet is the front controller. It asks handler mappings which method matches the request, resolves and binds arguments, invokes the handler method, and converts the return value through message converters. Exceptions travel back through resolvers that build the response. Each stage is an extension point, but you rarely need to replace one. Understanding the order explains most surprises: filters run before the servlet, interceptors sit between handler mapping and invocation, and an argument resolver can reject a request before your method body executes.$body$, $code$@RestController
public class OrderController {
    @GetMapping("/orders/{id}")
    OrderView get(@PathVariable String id) {
        return orders.findById(id);
    }
}$code$),
    ('spring-mvc-request-handling', 2, 'Argument resolution and binding', $body$Argument resolution turns the request into method parameters: path variables, query parameters, request bodies, headers, and validated command objects. A missing required parameter or a malformed body produces a binding failure before the handler runs. A request body can be consumed only once, so code that needs to read it again must wrap the request first. Keep parameter lists explicit; a handler method with many resolved arguments often means the request should be modeled as a dedicated record or command object instead of loose parameters.$body$, $code$@GetMapping("/orders")
Page<OrderView> search(@RequestParam String status,
        @RequestParam(defaultValue = "0") int page) {
    return orders.search(status, page);
}$code$),
    ('spring-mvc-request-handling', 3, 'Keeping handlers thin', $body$A controller should translate HTTP into a use case and translate the result back: map the request, call one application service, and shape the response. Business rules, transactions, and persistence belong behind that call, which keeps handlers testable with a mocked service and keeps status codes deliberate. Avoid returning persistence entities directly, because lazy loading and mapping details leak into the API contract. When a handler needs more than a few lines of orchestration, move the orchestration into a service rather than letting the controller grow a workflow.$body$, $code$@PostMapping("/orders")
ResponseEntity<OrderView> create(@Valid @RequestBody CreateOrder body) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(orders.place(body));
}$code$),
    ('spring-rest-controllers-and-content-negotiation', 1, 'RestController and message conversion', $body$@RestController combines @Controller and @ResponseBody: handler return values are written by message converters instead of resolving a view. The converter is chosen from the response media type, the declared return type, and the requested media type, so content negotiation is part of the contract. If a client sends an Accept header the server cannot satisfy, the result is a 406 response, and a missing producer for the negotiated type yields a 500 response. Design the media type your API produces deliberately, and test the negotiation behavior that clients depend on.$body$, $code$@RestController
@RequestMapping(path = "/orders",
        produces = MediaType.APPLICATION_JSON_VALUE)
public class OrderController {
    @GetMapping("/{id}")
    OrderView byId(@PathVariable String id) {
        return orders.find(id);
    }
}$code$),
    ('spring-rest-controllers-and-content-negotiation', 2, 'Status codes, headers, and ResponseEntity', $body$Return the DTO type when the status is fixed and mostly 200, and ResponseEntity when the status or headers vary: created resources need 201 with a Location header, deletions often need 204 with no body. Set headers such as ETag or Cache-Control explicitly when clients may rely on them. Keep status decisions near the handler so the API contract is readable rather than scattered through advice. Consistency matters more than cleverness, because clients encode these details and versioning becomes harder once behavior is inconsistent across endpoints.$body$, $code$@PostMapping
ResponseEntity<OrderView> create(@Valid @RequestBody CreateOrder body) {
    OrderView created = orders.place(body);
    URI location = URI.create("/orders/" + created.id());
    return ResponseEntity.created(location).body(created);
}$code$),
    ('spring-rest-controllers-and-content-negotiation', 3, 'Designing for compatible evolution', $body$Additive changes are usually compatible: a new optional request field or a new response field that clients ignore. Removing a field, tightening validation, or changing meaning breaks consumers, so stage such changes with a version and a deprecation window. Use explicit request and response DTOs rather than entities, because persistence structure changes for storage reasons and should not dictate the wire format. Publish a media type or path version when a break is unavoidable, and support both versions for a documented overlap period instead of switching callers overnight.$body$, $code$public record OrderView(String id, String status,
        List<LineView> lines, Instant createdAt) { }

public record LineView(String sku, int quantity) { }$code$),
    ('spring-error-handling-and-problem-details', 1, 'One place for error mapping', $body$@ControllerAdvice applies to every controller by default, and @ExceptionHandler methods inside it map exceptions to responses. Centralizing the mapping means the API error shape is defined once instead of repeated per handler, but keep handlers specific about the exemption boundary. A broad catch-all that converts every exception into 500 hides programming errors and makes the API less truthful, while an overly broad 400 conversion hides integration failures. Order matters: more specific exception types win over generic ones, and the framework already maps many MVC exceptions for you.$body$, $code$@RestControllerAdvice
public class ApiErrors {
    @ExceptionHandler(OrderNotFoundException.class)
    ProblemDetail notFound(OrderNotFoundException ex) {
        ProblemDetail problem = ProblemDetail
            .forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        problem.setTitle("Order not found");
        return problem;
    }
}$code$),
    ('spring-error-handling-and-problem-details', 2, 'RFC 9457 ProblemDetail responses', $body$ProblemDetail is Spring support for the problem details format standardized in RFC 9457, which supersedes RFC 7807. It carries a type, title, status, detail, and instance, plus extension properties for machine-readable fields such as a correlation id or a list of invalid fields. Enable it for framework exceptions by setting spring.mvc.problemdetails.enabled, or build it yourself in advice. Use the type URI as the stable, documented identifier that clients can switch on, keep title and detail human readable, and do not expose stack traces or internal identifiers. A consistent error contract reduces guesswork for every caller.$body$, $code$@ExceptionHandler(MethodArgumentNotValidException.class)
ProblemDetail invalid(MethodArgumentNotValidException ex) {
    ProblemDetail problem = ProblemDetail
        .forStatusAndDetail(HttpStatus.BAD_REQUEST, "Validation failed");
    problem.setProperty("fields", fieldErrors(ex));
    return problem;
}$code$),
    ('spring-error-handling-and-problem-details', 3, 'Choosing status codes deliberately', $body$The status code is part of the contract, and framework defaults may not match your semantics. A malformed body is 400, an unknown resource is 404, a state conflict is 409, and an unexpected server failure is 500. Map business failures in the service layer to a small set of exception types so advice stays simple and mechanical instead of accumulating conditions. Log the unexpected 500 responses with context, but never log expected validation failures at error level, because noise trains people to ignore alerts. When in doubt, document the mapping in the API contract and test it.$body$, $code$@ExceptionHandler(OrderStateConflictException.class)
ResponseEntity<ProblemDetail> conflict(OrderStateConflictException ex) {
    ProblemDetail problem = ProblemDetail.forStatusAndDetail(
        HttpStatus.CONFLICT, "Order is not in a payable state");
    return ResponseEntity.status(HttpStatus.CONFLICT).body(problem);
}$code$),
    ('spring-http-clients', 1, 'Choosing a client for the job', $body$RestTemplate is the original synchronous client and is in maintenance; new code should prefer alternatives. RestClient arrived in Spring Framework 6.1 as a synchronous client with a fluent API and roughly the same blocking model as RestTemplate. WebClient is the asynchronous, reactive option and fits streaming or fully reactive applications. The main trade-off is the concurrency model: blocking clients tie up a request thread, which is usually fine for internal calls but poor for many high-latency downstreams. Pick one client per application boundary, wrap it behind a small interface, and keep call sites testable.$body$, $code$@Bean
RestClient ordersClient(RestClient.Builder builder) {
    return builder
        .baseUrl("https://orders.internal")
        .build();
}$code$),
    ('spring-http-clients', 2, 'Timeouts that actually apply', $body$Client timeouts are not enabled by default, and a call without them can block a worker thread indefinitely. Configure connect and read timeouts on the request factory rather than relying on defaults; SimpleClientHttpRequestFactory exposes setConnectTimeout and setReadTimeout for exactly that purpose. A request-level or per-call timeout layers on top of the factory settings. Pair timeouts with bounded retries for idempotent operations only, and add backoff so retries do not amplify an outage. A timeout does not prove the remote operation failed, so make non-idempotent operations safe to repeat with keys or reconciliation.$body$, $code$SimpleClientHttpRequestFactory factory =
    new SimpleClientHttpRequestFactory();
factory.setConnectTimeout(2000);
factory.setReadTimeout(5000);

RestClient client = RestClient.builder()
    .baseUrl("https://orders.internal")
    .requestFactory(factory)
    .build();$code$),
    ('spring-http-clients', 3, 'Error handling and testing', $body$A 4xx response is a caller or contract problem, while a 5xx response or a timeout is an availability problem, and they deserve different handling. Convert transport exceptions into domain errors at the boundary instead of leaking client exception types through the application, and keep response bodies out of logs when they may contain personal data. Test the client against a stub or a mock server so both success and failure paths are exercised. Assert that timeouts and retries behave as configured, because untested resilience settings tend to be wrong.$body$, $code$OrderView view = client.get()
    .uri("/orders/{id}", id)
    .retrieve()
    .body(OrderView.class);

// 404 maps to null here; other errors surface as exceptions.$code$),
    ('spring-testing-slices', 1, 'Full context versus slice tests', $body$@SpringBootTest loads the complete application context and verifies real wiring, but it is slow and a failure can be hard to attribute. Slice tests load a narrow part: @WebMvcTest loads MVC infrastructure without data access, and @DataJpaTest loads JPA repositories with an embedded or configured database. Use slices for handler and repository behavior, and reserve the full context for a small number of end-to-end checks. Mock collaborators with @MockitoBean, the modern replacement for the deprecated @MockBean in Boot 3.4, so the slice stays focused on the layer under test.$body$, $code$@WebMvcTest(OrderController.class)
class OrderControllerTest {
    @Autowired MockMvc mvc;
    @MockitoBean OrderService orders;

    @Test
    void returnsOkay() throws Exception {
        mvc.perform(get("/orders/{id}", "42"))
            .andExpect(status().isOk());
    }
}$code$),
    ('spring-testing-slices', 2, 'Context caching and why suites slow down', $body$Spring caches an application context per unique context configuration, so tests with identical configuration, profile, and property sources reuse one context. Any difference such as an extra @MockitoBean, @TestPropertySource, or a new nested @Configuration class creates a new cache key and often a full restart, which is why the suite gets slower as tests accumulate. Keep customizations in shared test configuration classes and avoid trivial differences in annotations. Inspect the context cache statistics when a suite suddenly slows down, and review new test annotations for cache keys they accidentally introduce.$body$, $code$@SpringBootTest
@TestPropertySource(properties = "orders.audit.enabled=false")
class OrderFlowTest {
    @Autowired OrderService orders;
}$code$),
    ('spring-testing-slices', 3, 'Tests that stay fast and honest', $body$A fast suite is not automatically a trustworthy one, so pair speed with realistic data. Use Testcontainers for repositories when behavior depends on actual database semantics, and keep transaction-scoped tests aware that they do not commit by default. Prefer deterministic clocks, explicit fixtures, and assertions on observable behavior rather than internal calls. When a test needs many collaborators mocked, that is usually a design signal about the class under test. Keep integration tests few and meaningful, and let unit tests cover the branches.$body$, $code$@DataJpaTest
class OrderRepositoryTest {
    @Autowired OrderRepository orders;

    @Test
    void findsByStatus() {
        orders.save(new OrderEntity("PAID"));
        assertThat(orders.findByStatus("PAID")).hasSize(1);
    }
}$code$),
    ('spring-actuator-basics', 1, 'Health, info, and metrics endpoints', $body$The actuator exposes operational endpoints over HTTP and JMX: health reports component status, info exposes build and version metadata, and metrics exposes Micrometer measurements. Endpoint exposure is opt-in and can be narrowed by include and exclude lists, so a production surface contains only what operators need. Health details are aggregated by default and depend on registered indicators, which is useful for load balancer probes but not for deep diagnosis. Treat the actuator as an operational interface with its own contract, and document which endpoint your platform actually consumes.$body$, $code$management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized$code$),
    ('spring-actuator-basics', 2, 'Custom health indicators', $body$Implement HealthIndicator to report whether a dependency your service requires is usable, using Health.up() or Health.down() with a small number of useful details such as latency or a reason. An indicator should be fast and must not perform an unbounded operation; a health check that calls a slow downstream turns a dependency blip into a killed pod. Avoid exposing credentials or topology in details, and remember that readiness and liveness mean different things: liveness should not fail because a downstream is unavailable, or the orchestrator will restart a healthy process.$body$, $code$@Component
class CatalogHealthIndicator implements HealthIndicator {
    private final CatalogClient catalog;

    @Override
    public Health health() {
        boolean reachable = catalog.ping();
        return reachable ? Health.up().build()
                         : Health.down().withDetail("reason", "unreachable").build();
    }
}$code$),
    ('spring-actuator-basics', 3, 'Securing the actuator in production', $body$Actuator endpoints can reveal configuration, environment values, and internals, so never expose everything on a public port. Restrict exposure to health and info, require authentication for the rest, and keep management endpoints on a separate network or port where the platform supports it. With Spring Security, EndpointRequest.toAnyEndpoint() matches actuator requests so authorization rules can target them precisely. Verify the effective surface after every configuration change, because a broad include list added for debugging tends to survive into production, and that is how microservice internals leak.$body$, $code$@Bean
SecurityFilterChain actuatorSecurity(HttpSecurity http) throws Exception {
    http.securityMatcher(EndpointRequest.toAnyEndpoint())
        .authorizeHttpRequests(requests -> requests
            .requestMatchers(EndpointRequest.to("health", "info")).permitAll()
            .anyRequest().hasRole("OPS"));
    return http.build();
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
    'spring-ecosystem-and-boot-overview', 'spring-ioc-container',
    'spring-dependency-injection-patterns', 'spring-bean-lifecycle-and-scopes',
    'spring-stereotypes-and-component-scanning',
    'spring-configuration-properties-and-profiles',
    'spring-autoconfiguration-and-conditional-beans',
    'spring-application-events', 'spring-aop-fundamentals',
    'spring-validation-and-binding', 'spring-mvc-request-handling',
    'spring-rest-controllers-and-content-negotiation',
    'spring-error-handling-and-problem-details', 'spring-http-clients',
    'spring-testing-slices', 'spring-actuator-basics'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
