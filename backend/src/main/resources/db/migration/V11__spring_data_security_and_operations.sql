-- V11 — Spring Data, Security, and operations tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('spring-data-jpa-repositories', 'Spring Data JPA Repositories', 'Map entities to tables through repository interfaces and keep persistence details inside the data layer.', 'Mid', 26, true, 1),
    ('spring-data-jpa-queries', 'Querying with Spring Data JPA', 'Write derived queries, explicit JPQL, projections, and pagination that stay predictable as the schema grows.', 'Mid', 30, true, 1),
    ('spring-jdbc-and-jdbctemplate', 'JDBC and JdbcTemplate', 'Use JdbcTemplate and JdbcClient for SQL that is clearer than an object-relational mapping layer.', 'Mid', 28, true, 1),
    ('spring-transaction-management', 'Spring Transaction Management', 'Control transaction boundaries with @Transactional and avoid the proxy and rollback traps.', 'Mid', 32, true, 1),
    ('spring-flyway-migrations', 'Database Migrations with Flyway', 'Version schema changes with Flyway and verify them in continuous integration.', 'Mid', 24, true, 1),
    ('spring-security-filter-chain', 'The Spring Security Filter Chain', 'Understand the servlet filter chain and configure SecurityFilterChain beans safely.', 'Senior', 32, true, 1),
    ('spring-security-authentication', 'Authentication in Spring Security', 'Authenticate users with form login, HTTP basic, password encoders, and session controls.', 'Senior', 34, true, 1),
    ('spring-security-method-authorization', 'Method Authorization in Spring Security', 'Protect service methods with @PreAuthorize and test authorization rules directly.', 'Senior', 30, true, 1),
    ('spring-oauth2-resource-server', 'OAuth2 Resource Server with JWT', 'Validate JWTs, configure issuers and keys, and map claims to Spring Security authorities.', 'Senior', 36, true, 1),
    ('spring-cache-abstraction', 'The Spring Cache Abstraction', 'Cache method results through annotations while keeping key design and eviction honest.', 'Mid', 30, true, 1),
    ('spring-scheduling-and-async', 'Scheduling and Async Execution', 'Run scheduled and asynchronous work with executors you actually control.', 'Mid', 32, true, 1),
    ('spring-retry-and-backoff', 'Retry and Backoff Strategies', 'Retry transient failures with backoff while keeping operations idempotent and transactional boundaries clean.', 'Senior', 34, true, 1),
    ('spring-batch-basics', 'Spring Batch Fundamentals', 'Structure chunk-oriented jobs, restart failed runs, and decide when batch processing fits.', 'Senior', 38, true, 1),
    ('spring-kafka-essentials', 'Spring Kafka Essentials', 'Consume Kafka topics with listeners, handle failures, and make consumers idempotent.', 'Senior', 36, true, 1),
    ('spring-http-interface-clients', 'HTTP Interface Clients', 'Call remote HTTP services through declarative interfaces and keep failures visible.', 'Senior', 30, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('spring-data-jpa-repositories', 1, 'Repositories Instead of Boilerplate DAOs', $body$Spring Data JPA generates repository implementations from interfaces at startup, so most data access starts with an interface that extends JpaRepository and declares query methods. The generated proxy is a full Spring bean and participates in dependency injection and transactions. In production, repository interfaces should express the persistence operations a service needs, not the entire table surface: expose intent-revealing methods and keep entity mapping concerns in the domain model. A common mistake is letting every service inject JpaRepository directly, which spreads persistence details across the codebase and makes later schema or store changes expensive. Rule of thumb: one repository per aggregate root, declared in the data layer, consumed by services through narrowly defined methods.$body$, $code$interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByCustomerIdOrderByPlacedAtDesc(Long customerId);
}

Order order = new Order(customerId, total);
orderRepository.save(order);$code$),
    ('spring-data-jpa-repositories', 2, 'What Save and Find Guarantee', $body$save is not an upsert in general: with a generated identifier and a null id it calls persist, while an existing id makes it call merge, which copies state onto a managed instance and returns the managed copy. Always use the returned instance. findById issues a select and returns Optional; it never throws for a missing row, so callers decide the not-found policy. getReferenceById returns a lazy proxy that fails only when a property is accessed. These semantics matter in production because misuse turns a clean lookup into a lazy-loading exception inside rendering code, or silently detaches an update. Rule of thumb: treat the entity returned by save as authoritative and never ignore it.$body$, $code$Optional<Order> found = orders.findById(42L);
Order existing = found.orElseThrow(OrderNotFoundException::new);

existing.markPaid();
orders.save(existing);

Order reference = orders.getReferenceById(42L);
reference.getCustomerId();$code$),
    ('spring-data-jpa-repositories', 3, 'Avoid Leaky Repository Abstractions', $body$Repository interfaces are boundaries, and boundaries leak when callers depend on JPA behavior such as flush timing, lazy loading, and entity identity. Returning fully loaded entities to web layers invites LazyInitializationException and accidental N plus one queries. A service that needs a few columns should ask for a projection or a DTO instead of an entity graph it does not own. Keep transactions in the service layer, keep repositories free of business decisions, and avoid exposing Page objects from Spring Data directly when the API contract should not mention the framework. Rule of thumb: if a controller imports anything from org.springframework.data, the abstraction has already leaked past the service boundary.$body$, $code$@Service
class OrderService {
    private final OrderRepository orders;

    OrderService(OrderRepository orders) { this.orders = orders; }

    Order require(long id) {
        return orders.findById(id)
            .orElseThrow(() -> new OrderNotFoundException(id));
    }
}$code$),
    ('spring-data-jpa-queries', 1, 'Derived Queries from Method Names', $body$Spring Data parses method names such as findByStatusAndCreatedAtAfter into queries by matching each keyword to a property on the entity. The feature removes boilerplate but couples method names to property names, so a rename refactors both. Long names signal queries that deserve an explicit @Query instead. Keep derived methods to simple equality and range predicates; keyword combinations like Or, In, and IgnoreCase stay readable only while the name remains short. A frequent mistake is returning entities for read-only screens, which loads more state than the caller needs. Rule of thumb: if the method name needs a line break, write JPQL and give the query a descriptive name.$body$, $code$interface TicketRepository extends JpaRepository<Ticket, Long> {

    List<Ticket> findByStatusAndCreatedAtAfter(
        TicketStatus status, Instant cutoff);

    long deleteByStatus(TicketStatus status);
}$code$),
    ('spring-data-jpa-queries', 2, 'Explicit JPQL and Native Queries', $body$@Query holds a JPQL statement when the method name approach does not fit. JPQL addresses entities and fields, so the database schema can change without touching the query; native queries use real table and column names and give access to database-specific features such as partial indexes, window functions, or locking clauses. Both accept named parameters bound with @Param. In production the choice is portability versus control: JPQL keeps the model portable, while native SQL must be verified against each supported database. A common pitfall is a native query whose result no longer matches the mapping after a schema migration. Rule of thumb: default to JPQL, and reach for native SQL only when the database feature is the point.$body$, $code$interface TicketRepository extends JpaRepository<Ticket, Long> {

    @Query("select t from Ticket t where t.status = :status")
    List<Ticket> findOpen(@Param("status") TicketStatus status);

    @Query(value = "select * from ticket where status = :status",
           nativeQuery = true)
    List<Ticket> findOpenNative(@Param("status") String status);
}$code$),
    ('spring-data-jpa-queries', 3, 'Projections, Paging, and Sorting', $body$Projections shape a query result without loading a full entity. Interface projections map getters to selected columns, and class-based DTO projections construct immutable results; both reduce data transfer and avoid lazy-loading surprises. Paging wraps a query in a Pageable and returns a Page that carries total counts, or a Slice that only knows whether more rows exist. Counting is a second query, so use Slice for infinite scrolling and Page where a total is genuinely displayed. Sorting through Sort is convenient but must be validated against an allowlist before user input reaches it. Rule of thumb: select only the columns the caller needs, and never let unvalidated sort properties reach the query layer.$body$, $code$interface TicketSummary {
    Long getId();
    String getTitle();
}

Page<TicketSummary> findByStatus(TicketStatus status, Pageable pageable);

Pageable page = PageRequest.of(0, 20, Sort.by("createdAt").descending());$code$),
    ('spring-jdbc-and-jdbctemplate', 1, 'When Plain SQL Beats JPA', $body$Spring Data JPA shines at loading and persisting aggregates, but reporting queries, bulk updates, and database-specific features are often clearer as SQL. An update that modifies ten thousand rows should not load entities to change two columns; a direct statement executes in the database with one network round trip. Set-based statements bypass the persistence context, so keep them out of code that also holds managed entities, and consider flushing or clearing first. Read-only projections over joins are another case where a hand-written query stays readable longer than an entity graph. Rule of thumb: use the ORM for aggregate lifecycle work, and use SQL for set operations, bulk changes, and reports.$body$, $code$int updated = jdbc.update("""
    update invoice
       set paid_at = now()
     where id = ? and paid_at is null
    """, invoiceId);
if (updated != 1) {
    throw new IllegalStateException("invoice not updated");
}$code$),
    ('spring-jdbc-and-jdbctemplate', 2, 'JdbcTemplate and JdbcClient Basics', $body$JdbcTemplate centralizes connection handling, statement creation, and exception translation. query runs a select and maps rows, queryForObject expects exactly one row and throws when none or several match, and update returns the affected row count. JdbcClient, available since Spring Framework 6.1, wraps the classic template with a fluent API supporting named and positional parameters, which reads better for simple statements. Unlike JPA, nothing is cached or tracked: what you execute is what runs. That makes behavior predictable but leaves resource management and batching decisions to you. Rule of thumb: call update for every write and check the row count so a statement that changed nothing cannot be mistaken for success.$body$, $code$record Customer(long id, String email) {}

List<Customer> found = jdbc.sql("""
        select id, email from customer where region = :region
        """)
    .param("region", region)
    .query((rs, rowNum) -> new Customer(rs.getLong("id"), rs.getString("email")))
    .list();$code$),
    ('spring-jdbc-and-jdbctemplate', 3, 'Row Mapping and Exception Translation', $body$JdbcTemplate translates SQLException into the runtime DataAccessException hierarchy, so callers deal with meaningful types such as DuplicateKeyException or QueryTimeoutException instead of vendor error codes. That translation is only as useful as the row mapper you supply: map columns explicitly, handle null columns deliberately, and never let a mapper perform extra queries per row, which recreates the N plus one problem by hand. queryForObject signals missing rows with EmptyResultDataAccessException and multiple rows with IncorrectResultSizeDataAccessException, so decide whether a missing row is an error before calling it. Rule of thumb: catch the narrowest data access exception at the layer that can act on it, and log vendor details once at the boundary.$body$, $code$try {
    return jdbc.queryForObject(
        "select email from customer where id = ?", String.class, id);
}
catch (EmptyResultDataAccessException ex) {
    throw new CustomerNotFoundException(id);
}
catch (DataAccessException ex) {
    log.warn("lookup failed for customer {}", id, ex);
    throw ex;
}$code$),
    ('spring-transaction-management', 1, 'Transactional Boundaries Through Proxies', $body$Spring implements @Transactional with a proxy around the bean. The proxy opens a transaction before the method body runs, commits after a normal return, and rolls back according to the configured rules. Because the transaction starts at the proxy boundary, the annotated method must be public, and calls that bypass the proxy do not start a transaction at all. This is why a service method calling another method on the same instance stays non-transactional even when the callee is annotated: the call never leaves the object. Inject the collaborator as a separate bean, or restructure the entry point. Rule of thumb: put @Transactional on the outermost service method that must be atomic, and keep the number of annotated methods small.$body$, $code$@Service
class TransferService {

    @Transactional
    public void transfer(long from, long to, long cents) {
        accounts.debit(from, cents);
        accounts.credit(to, cents);
    }
}$code$),
    ('spring-transaction-management', 2, 'Propagation and Rollback Rules', $body$Propagation controls what happens when a transaction already exists. The default, REQUIRED, joins the current transaction; REQUIRES_NEW suspends it and starts an independent one, which is useful for audit records that must survive a caller rollback but costly because it holds a second connection. Rollback behavior surprises newcomers: Spring rolls back on runtime exceptions and errors, not on checked exceptions, unless you write rollbackFor. A caught exception also prevents rollback, which is why catch blocks inside transactional methods are risky. Rule of thumb: be explicit with rollbackFor when checked exceptions must abort the transaction, and never swallow an exception that leaves the database partially changed.$body$, $code$@Transactional(propagation = Propagation.REQUIRES_NEW)
public void writeAudit(AuditEvent event) {
    auditRepository.save(event);
}

@Transactional(rollbackFor = IOException.class)
public void importFile(Path path) throws IOException {
    parser.read(path);
}$code$),
    ('spring-transaction-management', 3, 'Keeping Transactions Short', $body$An open transaction holds database connections and locks, so its duration is a production concern, not a style preference. Remote calls, message publishing, file uploads, and email sending inside a transaction extend lock hold time and couple the database to the availability of another system. Move them outside the boundary, or record intent in the database and process it afterward. Read-only transactions can skip dirty checking and let some databases route work to replicas. Timeouts turn an unknown lock wait into a predictable failure. Rule of thumb: a transactional method should contain database work and little else; if it needs a network call, that call probably belongs in a different layer.$body$, $code$@Transactional(readOnly = true, timeout = 2)
public Report load(ReportRequest request) {
    return Report.from(rows.find(request));
}
// Remote calls and message publishing belong outside the transaction.$code$),
    ('spring-flyway-migrations', 1, 'Versioned Migrations with Spring Boot', $body$Flyway applies ordered SQL scripts from the migration location before the application serves traffic. Scripts follow a strict naming convention: V1__create_customer.sql, V2__add_status.sql, and so on, with a description after the double underscore. Flyway records each applied script and its checksum in a schema history table, so an applied migration is never edited again; corrections become a new versioned script. Boot wires Flyway into startup and exposes spring.flyway properties for locations, schemas, and placeholders. Keeping migrations in the same repository as the code makes the schema reviewable in the same pull request. Rule of thumb: treat an applied migration as immutable; if it is wrong in production, fix it forward.$body$, $code$// V1__create_customer.sql runs before the application starts.
@ConfigurationProperties("app.migration")
record MigrationProperties(boolean enabled) {}

@Bean
FlywayMigrationStrategy migrateThenValidate() {
    return flyway -> {
        flyway.migrate();
        flyway.validate();
    };
}$code$),
    ('spring-flyway-migrations', 2, 'Baselines and Repeatable Migrations', $body$When a database already contains schema, Flyway refuses to start unless you baseline it. Setting baselineOnMigrate with a baseline version records that starting point and skips older scripts, which is the standard way to adopt Flyway in an existing system. Repeatable migrations, named with an R__ prefix and no version, run after versioned ones and re-execute whenever their checksum changes; they suit views, functions, and stored procedures that have no natural version. A pitfall is putting destructive statements in a repeatable migration, because it may run again on a later deploy. Rule of thumb: version things that change incrementally and repeat things that can be recreated from scratch.$body$, $code$@Bean
FlywayConfigurationCustomizer baselineFluent() {
    return configuration -> configuration
        .baselineOnMigrate(true)
        .baselineVersion("0");
}

// R__refresh_report_views.sql reruns whenever its checksum changes.$code$),
    ('spring-flyway-migrations', 3, 'Migration Checks in CI', $body$Migration mistakes surface late if scripts are only tested against a long-lived development database. Run all migrations against an empty database in continuous integration so ordering, dependencies, and dialect differences fail the build before deployment. Add a validation step that compares checksums of applied migrations and fails when a script was edited after being applied. Test that the previous release schema can be upgraded by applying only the new scripts, which catches assumptions about a fresh database. A staged rollout should apply migrations before the new application version starts, so old and new code never disagree about the schema. Rule of thumb: an untested migration is an outage waiting for a release window.$body$, $code$@Testcontainers
class MigrationTest {

    @Container
    static PostgreSQLContainer<?> db = new PostgreSQLContainer<>("postgres:16");

    @Test
    void migrationsApplyToEmptyDatabase() {
        Flyway.configure()
            .dataSource(db.getJdbcUrl(), db.getUsername(), db.getPassword())
            .load()
            .migrate();
    }
}$code$),
    ('spring-security-filter-chain', 1, 'How the Security Filter Chain Works', $body$Spring Security runs as a servlet filter: a single DelegatingFilterProxy registered by Boot delegates to a FilterChainProxy, which selects one SecurityFilterChain per request. A chain holds ordered filters for authentication, authorization, CSRF, session management, and more, and only the first matching chain is used. If no chain matches, the request continues unsecured, which is why an unmatched path is a configuration bug, not a safe default. Understanding the model explains ordering symptoms: an authorization rule placed before authentication cannot see a principal. Rule of thumb: define chains for the URL groups you own, always end with a chain that matches every request, and keep the fallback rule explicit.$body$, $code$@Bean
SecurityFilterChain apiChain(HttpSecurity http) throws Exception {
    http.securityMatcher("/api/**")
        .authorizeHttpRequests(auth -> auth
            .anyRequest().authenticated());
    return http.build();
}$code$),
    ('spring-security-filter-chain', 2, 'Defining and Ordering Filter Chains', $body$A SecurityFilterChain bean receives an HttpSecurity and returns the built chain. Use securityMatcher to limit a chain to a URL pattern, and give each bean an @Order so evaluation is deterministic: the most specific chain must be tested first, and a chain without a matcher must be last because it accepts everything. All chain beans are collected, and Boot no longer needs a WebSecurityConfigurerAdapter. A frequent mistake is defining several full chains that all match, so rules silently move to an unused bean. Rule of thumb: one chain per access regime, ordered from narrowest matcher to the broad catch-all, and verify the effective order in a test.$body$, $code$@Bean
@Order(1)
SecurityFilterChain api(HttpSecurity http) throws Exception {
    http.securityMatcher("/api/**")
        .authorizeHttpRequests(auth -> auth.anyRequest().authenticated());
    return http.build();
}
// Chains without a securityMatcher match every request and must come last.$code$),
    ('spring-security-filter-chain', 3, 'Common Chain Misconfigurations', $body$Most security incidents in Spring applications come from chain configuration, not from broken filters. Putting anyRequest().permitAll() before protected rules opens everything, because rules are evaluated in order and the first match wins. Disabling CSRF globally to quiet a test failure removes protection for browser clients; disable it per chain only for stateless APIs authenticated without cookies. Leaving management endpoints authenticated by accident blocks health checks, while exposing them without review leaks operational detail. A chain that matches nothing and relies on defaults behaves differently from the one you meant to write. Rule of thumb: write authorization from the most specific path outward, and keep a test that proves an unauthenticated request is rejected.$body$, $code$http
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/actuator/health").permitAll()
        .requestMatchers("/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated());

// Never place anyRequest().permitAll() before protected rules.$code$),
    ('spring-security-authentication', 1, 'Form Login Versus HTTP Basic', $body$Form login suits browser applications: an unauthenticated request is redirected to a login page, the submitted credentials are checked, and the authenticated user is stored in an HTTP session. HTTP basic suits machine clients and quick diagnostics: every request carries credentials in a header, and there is no login page or logout form. Both are just filters that populate the security context; the rest of the chain does not care which one ran. In production, browser flows need CSRF protection and logout handling, while API clients should prefer token-based authentication over repeatedly sending a password. Rule of thumb: choose the authentication mechanism that matches the client, and enable only the ones the application actually serves.$body$, $code$@Bean
SecurityFilterChain browserChain(HttpSecurity http) throws Exception {
    http.authorizeHttpRequests(auth -> auth.anyRequest().authenticated())
        .formLogin(form -> form.loginPage("/login").permitAll());
    return http.build();
}$code$),
    ('spring-security-authentication', 2, 'Password Encoders and User Details', $body$Passwords must be stored as hashes produced by an adaptive encoder such as BCrypt or Argon2. PasswordEncoderFactories.createDelegatingPasswordEncoder prefixes each hash with its algorithm id, so new schemes can be introduced while old hashes still verify. A UserDetailsService loads the account by username and returns username, password hash, and authorities; it should never return credentials for a disabled or locked account without representing that state. Returning the stored hash unchanged to callers, or logging request parameters, exposes credential material. Rule of thumb: hash on write, match on read, and keep encoding policy in one configuration bean so every part of the application agrees.$body$, $code$@Bean
PasswordEncoder passwordEncoder() {
    return PasswordEncoderFactories.createDelegatingPasswordEncoder();
}

@Bean
UserDetailsService users(UserRepository repository) {
    return username -> repository.findByUsername(username)
        .map(user -> User.withUsername(user.username())
            .password(user.passwordHash())
            .authorities(user.authorities())
            .build())
        .orElseThrow(() -> new UsernameNotFoundException(username));
}$code$),
    ('spring-security-authentication', 3, 'Session and Logout Behavior', $body$Session-based authentication needs explicit lifecycle rules. Session fixation protection changes the session id after login, which stops an attacker who planted a known id before authentication. Idle and absolute timeouts limit how long a stolen session remains useful, and a maximum session count detects shared accounts or leaked credentials. Logout must invalidate the server-side session and clear the context, not merely delete a cookie. For token-based, stateless APIs, disable session creation entirely so the container does not allocate state that no filter reads. Rule of thumb: decide once whether the application is session-based or stateless, and configure session management to match that decision instead of leaving defaults in place.$body$, $code$http
    .sessionManagement(session -> session
        .sessionFixation(fixation -> fixation.migrateSession())
        .maximumSessions(1))
    .logout(logout -> logout
        .logoutUrl("/logout")
        .invalidateHttpSession(true));

// Stateless token APIs use SessionCreationPolicy.STATELESS instead.$code$),
    ('spring-security-method-authorization', 1, 'Enabling Method Security', $body$URL rules protect endpoints, but the same service method can be reached from a controller, a scheduled job, or another service. Method security closes that gap by evaluating annotations on the bean method itself. Adding @EnableMethodSecurity to a configuration class activates @PreAuthorize, @PostAuthorize, @PreFilter, and @PostFilter support; authorization is enforced by a proxy, so it applies wherever the bean is injected. Because it is a proxy, self-invocation bypasses it just like transactions, and final classes or private methods cannot be advised. Rule of thumb: authorize business operations at the service boundary, keep URL rules for coarse routing, and treat method security as the last line that no caller can skip.$body$, $code$@Configuration
@EnableMethodSecurity
class MethodSecurityConfig {
}

@Service
class ReportService {

    @PreAuthorize("hasRole('ANALYST')")
    Report load(long id) {
        return repository.findById(id).orElseThrow();
    }
}$code$),
    ('spring-security-method-authorization', 2, 'Roles, Authorities, and Expressions', $body$Spring Security distinguishes authorities, which are plain permission strings, from roles, which are authorities prefixed with ROLE_. hasAuthority('report:read') matches the string exactly, while hasRole('ADMIN') matches ROLE_ADMIN; mixing the two in one codebase produces confusing denials. Expressions are SpEL evaluated per invocation, so keep them short and move branching rules into a named bean that tests can cover. @PostAuthorize can inspect returnObject to allow access based on loaded data, which is useful for ownership checks but also loads data before denying. Rule of thumb: prefer permission-style authorities for service rules, use roles for coarse grouping, and never hide complicated logic inside an annotation.$body$, $code$@PreAuthorize("hasAuthority('report:read')")
Report read(long id) { return repository.load(id); }

@PostAuthorize("returnObject.owner == authentication.name")
Report readOwned(long id) { return repository.load(id); }

// hasRole('ADMIN') matches authority ROLE_ADMIN; hasAuthority is exact.
// Keep expressions short; complex rules belong in a bean you can test.$code$),
    ('spring-security-method-authorization', 3, 'Testing Secured Methods', $body$Annotated authorization must be tested, because a typo in an expression fails open or closed only at runtime. Spring Security Test provides @WithMockUser, which populates the security context with a username, roles, or authorities, so tests call the real proxied bean and assert the outcome. Test both the permitted and the denied path, including the anonymous case, and assert the specific exception rather than any failure. Mocking SecurityContextHolder manually usually produces tests that pass while production denies, because the proxy is bypassed. Rule of thumb: every secured method should have at least one allowed and one denied test, and expression names should appear in exactly those tests.$body$, $code$@Test
@WithMockUser(authorities = "report:read")
void readerCanLoadReport() {
    assertThat(service.read(7L)).isNotNull();
}

@Test
@WithMockUser
void plainUserIsDenied() {
    assertThatThrownBy(() -> service.read(7L))
        .isInstanceOf(AccessDeniedException.class);
}$code$),
    ('spring-oauth2-resource-server', 1, 'JWT Validation and Issuer Setup', $body$A resource server validates bearer tokens on every request; it never issues them. Configuring oauth2ResourceServer with jwt enables a JwtDecoder, and setting the issuer URI lets the application discover the authorization server metadata and fetch signing keys. Validation covers the signature, the expiry and not-before timestamps, and, when configured from an issuer, the iss claim. Signature check failures produce a 401 before any controller code runs. A common mistake is a public endpoint that parses the token by hand and trusts claims without verification, which moves the security decision into application code. Rule of thumb: let the decoder validate, configure the issuer explicitly, and never parse tokens ad hoc.$body$, $code$@Bean
SecurityFilterChain api(HttpSecurity http) throws Exception {
    http.authorizeHttpRequests(auth -> auth.anyRequest().authenticated())
        .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
    return http.build();
}
// spring.security.oauth2.resourceserver.jwt.issuer-uri starts
// discovery; the decoder checks iss and expiry automatically.$code$),
    ('spring-oauth2-resource-server', 2, 'Mapping Claims to Authorities', $body$A validated JWT proves who issued it; authorization still needs authorities. Spring Security maps the scope claim to SCOPE_ prefixed authorities by default through JwtGrantedAuthoritiesConverter, and JwtAuthenticationConverter lets you customize prefixes, claim names, and the principal name. Map only claims the issuer actually controls, and treat everything else in the token as untrusted input. Rules such as hasAuthority('SCOPE_messages:read') then work on the mapped values. A pitfall is granting broad authorities from a claim that clients can set themselves, or mapping roles while URL rules expect permissions. Rule of thumb: make the mapping explicit and test it once, then write authorization rules against the mapped authorities everywhere.$body$, $code$@Bean
JwtAuthenticationConverter jwtAuthenticationConverter() {
    JwtGrantedAuthoritiesConverter scopes = new JwtGrantedAuthoritiesConverter();
    scopes.setAuthorityPrefix("SCOPE_");

    JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
    converter.setJwtGrantedAuthoritiesConverter(scopes);
    return converter;
}

@PreAuthorize("hasAuthority('SCOPE_messages:read')")
List<Message> read() { return messages.findAll(); }$code$),
    ('spring-oauth2-resource-server', 3, 'Key Rotation and Token Hygiene', $body$Signing keys rotate, and clients must tolerate overlap: the decoder caches the JSON Web Key Set and refreshes it when it encounters an unknown key id, so validation keeps working across rotation without a redeploy. Clock skew between issuer and resource server can reject valid tokens near their boundaries, so a small allowance is normal practice. Audience validation is not automatic for every setup; when the issuer serves several APIs, add an audience check so a token minted for another service is refused. Tokens are credentials: never log them, never put them in URLs, and keep lifetimes short. Rule of thumb: configure validation for signature, issuer, expiry, and audience, and let caching handle rotation.$body$, $code$JwtDecoder decoder = JwtDecoders.fromIssuerLocation(issuerUri);

if (decoder instanceof NimbusJwtDecoder nimbus) {
    nimbus.setJwtValidator(JwtValidators.createDefaultWithIssuer(issuerUri));
}
// Rotate keys at the issuer; the decoder caches the JWK set and
// refreshes it when it sees an unknown key id.$code$),
    ('spring-cache-abstraction', 1, 'Cacheable Reads and Eviction', $body$@Cacheable intercepts a method call, looks up a key, and returns the cached value on a hit; on a miss it invokes the method and stores the result. @CacheEvict removes entries when data changes, either for a specific key or, with allEntries, for the whole cache. Both annotations work through a proxy, so only external calls are intercepted, and self-invocation bypasses caching the same way it bypasses transactions. Keys default to the parameters, which is rarely what you want for multi-argument identity or for methods where one argument determines the value. Rule of thumb: write the key explicitly, evict on every write path that changes the cached data, and never cache a method whose result depends on who is calling.$body$, $code$@Cacheable(cacheNames = "catalog", key = "#isbn")
Book findBook(String isbn) {
    return repository.findByIsbn(isbn).orElseThrow();
}

@CacheEvict(cacheNames = "catalog", key = "#book.isbn")
void updateBook(Book book) {
    repository.save(book);
}$code$),
    ('spring-cache-abstraction', 2, 'Choosing a Cache Manager', $body$The abstraction sits over a CacheManager, and the manager determines the real behavior: ConcurrentMapCacheManager has no eviction and grows until the heap complains, Caffeine adds size limits and expiry, and Redis shares entries across instances. Configuration such as time to live, maximum size, and capacity belongs to the manager, per cache name, not to the annotation. Choosing a distributed manager changes failure modes: a network problem becomes a cache miss or an error, and serialization requirements appear. A common production mistake is enabling caching with the in-memory default in a multi-instance service, so each instance sees different data. Rule of thumb: pick the manager by consistency and scale requirements, and configure every cache with an explicit bound.$body$, $code$@Bean
CacheManager cacheManager() {
    CaffeineCacheManager manager = new CaffeineCacheManager("catalog");
    manager.setCaffeine(Caffeine.newBuilder()
        .maximumSize(10_000)
        .expireAfterWrite(Duration.ofMinutes(5)));
    return manager;
}$code$),
    ('spring-cache-abstraction', 3, 'The Abstraction Is Not a Cache', $body$Spring caching is an interception layer, not a cache implementation: without a configured manager you get a simple map with no expiration, no statistics, and no eviction policy. The annotation cannot express time to live, so any TTL requirement must be satisfied by the manager or by wrapping values with their expiry. Null handling differs per implementation, and negative results cached by accident can mask recovered upstream data. Stampedes are possible when a popular entry expires and many threads miss at once; sync mode helps within one instance only. Rule of thumb: treat caching as an optimization on top of correct code, decide expiry before enabling it, and measure hit ratio instead of assuming a win.$body$, $code$@Cacheable(cacheNames = "rates", key = "#base + '-' + #quote")
BigDecimal rate(String base, String quote) {
    return provider.fetch(base, quote);
}

// TTL, eviction, and max size live in the cache manager, not here.
// A cached method must be your own bean method; self-invocation
// does not hit the cache proxy.$code$),
    ('spring-scheduling-and-async', 1, 'Scheduled Tasks and Timing Traps', $body$@EnableScheduling turns on processing of @Scheduled methods. fixedDelay waits a fixed time after the previous execution finishes, fixedRate tries to keep a fixed cadence and can queue work when executions run long, and cron expressions add calendar semantics with an optional zone. The default scheduler has a single thread, so one slow task delays every other task in the same application; configure a TaskScheduler with a pool appropriate to the workload. Scheduled work runs on every instance unless coordination exists, which duplicates side effects in a clustered deployment. Rule of thumb: prefer fixedDelay for jobs that talk to a shared resource, size the scheduler pool deliberately, and make multi-instance behavior a conscious decision.$body$, $code$@Scheduled(fixedDelay = 30_000)
void pollQueue() {
    worker.drainOnce();
}

@Scheduled(cron = "0 0 3 * * *", zone = "UTC")
void nightlyCleanup() {
    cleanup.run();
}$code$),
    ('spring-scheduling-and-async', 2, 'Async Execution Needs an Executor', $body$@EnableAsync makes @Async methods run on an executor selected from the context. A method returning void runs fire-and-forget; Future or CompletableFuture return types let callers observe completion, and Boot can wrap callables from controllers. The executor is the important part: Boot auto-configures a ThreadPoolTaskExecutor, but adding your own Executor bean or naming one taskExecutor changes which pool is used, and an unbounded pool or queue trades overload for memory exhaustion and latency. Queue capacity, pool size, and rejection policy are production decisions, not defaults. Rule of thumb: define one bounded executor per kind of work, name it explicitly in @Async, and monitor queue depth and active threads.$body$, $code$@Configuration
@EnableAsync
class AsyncConfig {

    @Bean
    ThreadPoolTaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(8);
        executor.setQueueCapacity(200);
        return executor;
    }
}$code$),
    ('spring-scheduling-and-async', 3, 'Self-Invocation and Lost Errors', $body$Proxies intercept @Async calls, so a method that calls another method on the same instance runs synchronously and silently loses both its asynchrony and any transaction context. Move the async method to a collaborator or call it from the controller. Because a void async method cannot return a failure, exceptions go to an AsyncUncaughtExceptionHandler; without one they are logged at most, and callers never learn that work failed. Security, locale, and transaction context do not automatically travel to the new thread, so pass the values the task needs instead of reading thread locals. Rule of thumb: treat an async boundary like a message boundary, and make every failure observable.$body$, $code$@Async
void sendReceipt(long orderId) {
    mailer.send(orderId);
}

// Self-invocation bypasses the proxy: calling this.sendReceipt()
// inside the same bean runs synchronously.
// void async methods report failures only through AsyncUncaughtExceptionHandler.$code$),
    ('spring-retry-and-backoff', 1, 'Declarative Retries with Spring Retry', $body$Spring Retry applies retry logic through a proxy: @EnableRetry activates processing, @Retryable declares which exceptions are retried and how many attempts are allowed, and @Backoff sets the delay between attempts, optionally with a multiplier for exponential growth. A matching @Recover method runs after the attempts are exhausted, receiving the exception and the original arguments. Defaults matter: three attempts and no wait between them. Declare the exceptions that are worth retrying with retryFor, so permanent failures are not delayed. Because a proxy does the work, self-invocation bypasses retry entirely, and the method must be called through the injected bean. Rule of thumb: retry only exceptions that are transient and list them explicitly.$body$, $code$@EnableRetry
@Configuration
class RetryConfig {
}

@Retryable(maxAttempts = 4,
           backoff = @Backoff(delay = 200, multiplier = 2))
String fetchQuote(String symbol) {
    return client.forSymbol(symbol);
}$code$),
    ('spring-retry-and-backoff', 2, 'Idempotency Comes Before Retry', $body$Retrying is safe only when repeating the operation produces the same outcome. Reads and idempotent writes qualify; charging a card, sending an email, or appending to a log do not, unless the target supports a deduplication key. A timeout is the dangerous case: the first attempt may have succeeded after the client gave up, so a blind retry duplicates the effect. Pass a stable idempotency key generated before the first attempt so the remote service can collapse duplicates. During an outage, every client retrying multiplies load on a struggling dependency, so backoff and jitter matter as much as the attempt count. Rule of thumb: name the idempotency key at the call site and retry only operations the receiver can deduplicate.$body$, $code$@Retryable(retryFor = SocketTimeoutException.class)
void charge(String idempotencyKey, long cents) {
    gateway.charge(idempotencyKey, cents);
}

// The gateway deduplicates by idempotency key, so a retry after a
// timeout cannot charge the customer twice.$code$),
    ('spring-retry-and-backoff', 3, 'Retries Across Transaction Boundaries', $body$Retrying a method that runs inside a database transaction is delicate. If the transaction is still active, work performed by the failed attempt may remain in the transaction and roll back later, and a retry inside the same transaction either duplicates that work or fails again for the same reason. Retry at the outermost boundary instead: let the transactional method fail, roll back, and be called again through the proxy. Some failures, such as a deadlock or an optimistic lock conflict, are exactly what retry is for, but they surface at commit time, so the retry must wrap the whole transactional unit. Rule of thumb: one transaction per attempt, never a retry nested inside the boundary it depends on.$body$, $code$@Retryable(retryFor = OptimisticLockingFailureException.class,
           maxAttempts = 3)
public void updateStock(long sku, int delta) {
    stockService.applyDelta(sku, delta);
}

// applyDelta is @Transactional, so each attempt runs in a new
// transaction and rolls back before the retry.

@Recover
void recover(OptimisticLockingFailureException ex, long sku, int delta) {
    alerting.raiseConflict(sku);
}$code$),
    ('spring-batch-basics', 1, 'Jobs, Steps, and Chunks', $body$Spring Batch models finite, heavy data processing as a job made of steps. A chunk-oriented step reads items, optionally transforms them, and writes them in batches; each chunk commits as a unit, so transaction size is the chunk size. That structure bounds memory, gives restart points, and produces an execution record for every run. The job repository persists these records in metadata tables, and both the job and step builders need it. A pipeline differs from an event consumer: it is expected to end, be scheduled, and be looked at afterwards. Rule of thumb: choose the chunk size by measuring commit overhead against the cost of reprocessing a failed chunk.$body$, $code$@Bean
Job importJob(JobRepository repository, Step importStep) {
    return new JobBuilder("importJob", repository)
        .start(importStep)
        .build();
}

@Bean
Step importStep(JobRepository repository, PlatformTransactionManager tx) {
    return new StepBuilder("importStep", repository)
        .<Row, Customer>chunk(500, tx)
        .reader(reader()).writer(writer()).build();
}$code$),
    ('spring-batch-basics', 2, 'Restartability and the Job Repository', $body$A job instance is identified by its name plus its identifying parameters, so the same parameters address the same logical run. If a run fails, restarting with the same parameters resumes from the last committed chunk because the reader stored its position in the execution context. Changing a parameter value creates a new instance instead of a restart; a parameter that varies per run, such as a timestamp, makes restart impossible in practice. The repository also keeps old executions, which supports operations but grows over time. Rule of thumb: use the business key, such as a date or tenant, as the identifying parameter, and keep volatile values out of it.$body$, $code$JobParameters parameters = new JobParametersBuilder()
    .addLocalDate("businessDate", date)
    .toJobParameters();
jobLauncher.run(importJob, parameters);

// The same businessDate restarts the failed instance and resumes
// from the last committed chunk; a different value creates a new one.$code$),
    ('spring-batch-basics', 3, 'When Spring Batch Fits', $body$Spring Batch is the right tool for large, finite, restartable data movement: imports, exports, migrations, settlements, and report generation that must be rerunnable and auditable. It is a poor fit for request-driven work, continuous streaming, or anything that must react within milliseconds; those belong in message-driven services or stream processors. It also adds metadata tables and operational surface, so a scheduled method calling a repository is enough for small jobs. Before adopting it, answer whether the work needs chunked commits, restart from failure, or run history. Rule of thumb: if a failed run must be resumed rather than repeated, batch processing is worth the structure.$body$, $code$// Start only when no run of the job is in flight.
if (jobExplorer.findRunningJobExecutions("importJob").isEmpty()) {
    JobExecution execution = jobOperator.startNextInstance("importJob");
    log.info("started execution {}", execution.getId());
}$code$),
    ('spring-kafka-essentials', 1, 'Listeners and Consumer Groups', $body$A consumer group is the unit of scaling in Kafka: partitions are distributed among the group members, one consumer per partition at a time, and a rebalance redistributes them when membership changes. @KafkaListener declares a method as a consumer; setting a group id puts the listener into a named group, and the concurrency attribute adds consumer threads up to the partition count. Ordering is guaranteed within a partition, not across a topic, so key choice determines what ordering you actually get. A common mistake is processing with more threads than partitions and wondering why some consumers idle. Rule of thumb: choose keys by the entity whose events must stay ordered, and scale consumers with partition count in mind.$body$, $code$@KafkaListener(topics = "orders", groupId = "billing")
void onOrder(ConsumerRecord<String, OrderEvent> record) {
    billing.handle(record.key(), record.value());
}

// Raising the concurrency adds consumer threads, up to the
// partition count of the topic.$code$),
    ('spring-kafka-essentials', 2, 'Handling Listener Errors', $body$By default, a listener that throws is retried by the container error handler, and after the default attempts are exhausted the record is logged and skipped, which silently drops the event. DefaultErrorHandler lets you set an explicit back off and attach a recoverer; DeadLetterPublishingRecoverer publishes the poison record to a dead letter topic together with headers that describe the failure, so operators can inspect and replay it. Deserialization errors happen before your method runs and need an ErrorHandlingDeserializer, otherwise the consumer cannot move past the bad record. Rule of thumb: every listener should state, in configuration, whether it retries forever, retries with a limit, or diverts failures to a dead letter topic.$body$, $code$@Bean
DefaultErrorHandler errorHandler(KafkaTemplate<String, Object> template) {
    DeadLetterPublishingRecoverer recoverer =
        new DeadLetterPublishingRecoverer(template);
    return new DefaultErrorHandler(recoverer,
        new FixedBackOff(1_000L, 3L));
}$code$),
    ('spring-kafka-essentials', 3, 'Building Idempotent Consumers', $body$Kafka consumers see at least once delivery in normal operation: a crash after processing but before committing causes the record to be delivered again, and retries and rebalances add more chances. Consumers must therefore be idempotent, meaning reprocessing a record does not change the outcome. Practical patterns include a deduplication table keyed by the event id where the insert and the state change share one transaction, natural keys that make writes repeatable, or upserts that overwrite with the same values. Do not rely on consumer offsets as the deduplication record, because a rebalance can reset them. Rule of thumb: assume every record arrives twice, and design the write so the second application is harmless.$body$, $code$@KafkaListener(topics = "payments", groupId = "ledger")
void onPayment(PaymentEvent event) {
    if (!processed.insertIfAbsent(event.id())) {
        return; // duplicate delivery, already applied
    }
    ledger.apply(event);
}$code$),
    ('spring-http-interface-clients', 1, 'Declarative HTTP Service Interfaces', $body$Spring Framework 6 turns an annotated interface into an HTTP client proxy. @HttpExchange on the interface declares the base URL and shared attributes, while method annotations such as @GetExchange and @PostExchange map arguments from @PathVariable, @RequestParam, and @RequestBody to a request. The proxy is created with HttpServiceProxyFactory over an adapter; RestClientAdapter, for example, adapts a RestClient. This removes hand-written request building and makes the remote contract a type that tests can implement. Two caveats matter: every call is still remote and can fail, and the annotations are request metadata, not retry or circuit breaker configuration. Rule of thumb: keep one interface per remote service and keep transport concerns out of the interface.$body$, $code$@HttpExchange(url = "/users", accept = "application/json")
interface UserClient {

    @GetExchange("/{id}")
    User byId(@PathVariable long id);

    @PostExchange
    User create(@RequestBody User newUser);
}$code$),
    ('spring-http-interface-clients', 2, 'Wiring Proxies and Errors', $body$Creating the proxy is a configuration detail: build a RestClient with the base URL, timeouts, and default headers, adapt it, create the factory, and expose the interface as a bean so services inject a type rather than transport machinery. Error behavior follows the client underneath: 4xx and 5xx responses surface as RestClientResponseException subtypes carrying status and body, while connection problems surface as resource access exceptions. Handle errors consistently, either at the call site or through a status handler that translates remote failures into domain-level exceptions. A common mistake is injecting the same client into many services with no timeout configured, so one slow dependency exhausts request threads. Rule of thumb: configure timeouts and error translation once, next to the proxy definition.$body$, $code$@Bean
UserClient userClient(RestClient.Builder builder) {
    RestClient restClient = builder
        .baseUrl("https://users.example.com")
        .build();
    // 4xx/5xx responses surface as RestClientResponseException.
    return HttpServiceProxyFactory
        .builderFor(RestClientAdapter.create(restClient))
        .build()
        .createClient(UserClient.class);
}$code$),
    ('spring-http-interface-clients', 3, 'Testing Client Integrations', $body$Client interfaces are simple to fake: a test can implement the interface and return fixtures, which keeps service tests fast and independent of the network. That does not prove the HTTP mapping is correct, so keep at least one test that exercises the adapter against a stub server and verifies paths, headers, and serialization. MockRestServiceServer can bind to the RestClient builder and assert expected requests, returning canned responses to validate both success and error handling. Avoid asserting on the client library internals; assert on the request that was sent and the outcome the caller sees. Rule of thumb: unit-test business code against a fake interface, and contract-test the proxy itself in a small number of focused tests.$body$, $code$RestClient.Builder builder = RestClient.builder();
MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
RestClient client = builder.build();

server.expect(requestTo("/users/7"))
      .andRespond(withSuccess("{\"id\":7}", MediaType.APPLICATION_JSON));

User user = client.get().uri("/users/7").retrieve().body(User.class);$code$)
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
    'spring-data-jpa-repositories', 'spring-data-jpa-queries',
    'spring-jdbc-and-jdbctemplate', 'spring-transaction-management',
    'spring-flyway-migrations', 'spring-security-filter-chain',
    'spring-security-authentication', 'spring-security-method-authorization',
    'spring-oauth2-resource-server', 'spring-cache-abstraction',
    'spring-scheduling-and-async', 'spring-retry-and-backoff',
    'spring-batch-basics', 'spring-kafka-essentials',
    'spring-http-interface-clients'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
