-- V20 — Security engineering for Java services.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('owasp-top-ten-for-java', 'OWASP Top Ten for Java Services', 'Map the OWASP Top Ten categories to concrete Java and Spring failure modes and the first control to apply for each.', 'Mid', 30, true, 1),
    ('sql-injection-prevention-java', 'SQL Injection Prevention in Java', 'Stop injections at the query layer with parameter binding, safe JPA usage, and least-privilege database accounts.', 'Mid', 28, true, 1),
    ('xss-prevention-java', 'Cross-Site Scripting Prevention in Java', 'Prevent script injection with output encoding, template auto-escaping, and a Content Security Policy that limits damage.', 'Mid', 28, true, 1),
    ('csrf-protection-java', 'CSRF Protection in Spring Applications', 'Protect state-changing requests with token patterns, cookie attributes, and deliberate choices for stateless APIs.', 'Mid', 26, true, 1),
    ('input-validation-strategies', 'Input Validation Strategies at Boundaries', 'Validate untrusted input with allowlists, boundary annotations, and canonicalization before checks run.', 'Junior', 22, true, 1),
    ('secure-password-storage', 'Secure Password Storage Fundamentals', 'Hash passwords with adaptive algorithms, correct salting, and upgrade paths that keep old hashes working.', 'Junior', 24, true, 1),
    ('secrets-in-source-avoidance', 'Avoiding Secrets in Source Code', 'Keep credentials out of repositories with history scanning, pre-commit checks, secret managers, and rotation after exposure.', 'Junior', 20, true, 1),
    ('dependency-vulnerability-scanning', 'Dependency Vulnerability Scanning in Practice', 'Find and triage vulnerable dependencies with software composition analysis, transitive awareness, and a regular update cadence.', 'Senior', 35, true, 1),
    ('jwt-best-practices', 'JSON Web Token Best Practices', 'Use JWT claims carefully, pick algorithms deliberately, and design expiry, refresh, and revocation behavior that matches reality.', 'Senior', 34, true, 1),
    ('oauth2-and-oidc-flows', 'OAuth 2.0 and OpenID Connect Flows', 'Implement authorization code with PKCE, client credentials, and audience checks while avoiding common redirect and token mistakes.', 'Senior', 36, true, 1),
    ('securing-rest-apis', 'Securing REST APIs in Spring', 'Layer authentication and authorization, add rate limits and idempotency keys, and keep error responses free of internal detail.', 'Mid', 30, true, 1),
    ('security-headers-and-csp', 'Security Headers and Content Security Policy', 'Deploy HSTS, frame protection, and Content Security Policy in stages without breaking existing pages.', 'Mid', 26, true, 1),
    ('cryptography-basics-for-java-devs', 'Cryptography Basics for Java Developers', 'Choose between symmetric and asymmetric primitives, rely on TLS and vetted libraries, and manage keys as production assets.', 'Mid', 30, true, 1),
    ('security-logging-and-auditing', 'Security Logging and Auditing', 'Log the events that matter, exclude secrets and personal data, and build audit trails that resist tampering.', 'Senior', 32, true, 1),
    ('threat-modeling-basics', 'Threat Modeling Basics for Services', 'Use STRIDE-style prompts and data-flow diagrams to find threats early and rank mitigations by risk.', 'Mid', 28, true, 1),
    ('supply-chain-security-slsa', 'Supply Chain Security and SLSA Levels', 'Protect builds with provenance, signed artifacts, dependency verification, and hardened build platforms.', 'Senior', 38, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('owasp-top-ten-for-java', 1, 'Map categories to failure modes', $body$The OWASP Top Ten is an awareness document, not a compliance checklist, but it gives review questions that map well onto Java services. Broken access control becomes a missing ownership check on a Spring endpoint. Injection becomes a string-built query or command. Cryptographic failures become plaintext secrets and fast password hashes. Authentication failures become weak session handling and credential stuffing exposure. Security misconfiguration becomes an exposed actuator or debug flag. Supply chain failures become unchecked dependencies. Logging failures become incidents nobody sees. Use each category to ask what could fail here, then confirm the fix with a test rather than a promise.$body$, $code$// Ask the OWASP question in code review: does this endpoint
// verify ownership, or only authentication?
Optional<Invoice> invoice = invoices.findById(id)
    .filter(candidate -> candidate.tenantId().equals(caller.tenantId()));
if (invoice.isEmpty()) {
    throw new NotFoundException();
}$code$),
    ('owasp-top-ten-for-java', 2, 'Start with the first control', $body$Every category has a first control that removes most of the risk, so apply it before polishing secondary defenses. Access control needs server-side checks on every request, including object ownership, because hiding a button is not authorization. Injection needs parameter binding at the query or command boundary. Cryptography needs vetted algorithms and properly hashed passwords. Authentication needs correct session handling plus multi-factor authentication for sensitive paths. Misconfiguration needs hardened defaults and no debug surface in production. Supply chain needs an inventory and scanning. Logging needs alertable security events. Treat the list as a starting priority order, then refine it with a threat model of your own system.$body$, $code$// Deny by default; open only the paths that must be public.
http.authorizeHttpRequests(auth -> auth
    .requestMatchers("/actuator/health").permitAll()
    .requestMatchers("/admin/**").hasRole("ADMIN")
    .anyRequest().authenticated());$code$),
    ('owasp-top-ten-for-java', 3, 'Review questions for every service', $body$Turn the categories into a review routine you can repeat before major launches and at a regular cadence. For each service, walk through authentication, authorization, input handling, output encoding, data protection in transit and at rest, dependency health, configuration, and logging. Ask what changed since the last review, because new endpoints and new third parties create new exposure. The Top Ten is revised periodically and category names shift, so cite the controls you actually implement rather than a year-numbered list. Record findings with owners and dates. Rule of thumb: a category only matters in your service if it maps to a concrete failure mode and a scheduled control.$body$, $code$record ReviewItem(String area, String question, String owner) {}
// Reuse the same checklist for every service review.
List<ReviewItem> checklist = List.of(
    new ReviewItem("auth", "Are ownership checks enforced server-side?", "team-a"),
    new ReviewItem("logging", "Do security events reach an alert?", "team-b"));$code$),
    ('sql-injection-prevention-java', 1, 'Bind parameters instead of concatenating', $body$SQL injection happens when untrusted data changes the structure of a query. Parameter binding keeps code and data separate: the statement is parsed first with placeholders, and values are transmitted separately, so a value can never introduce new SQL. In JDBC use `PreparedStatement` and its setters. In JPA use derived query methods, named parameters in `@Query`, or the criteria API. Avoid concatenating any user-controlled text into a statement, including small dynamic fragments. Input validation helps but is not the primary defense, because encodings and edge cases vary. Rule of thumb: if a query string contains user text, it should contain a placeholder instead.$body$, $code$String sql = "SELECT id, email FROM app_user WHERE email = ?";
try (PreparedStatement ps = connection.prepareStatement(sql)) {
    ps.setString(1, email);
    try (ResultSet rs = ps.executeQuery()) {
        return rs.next() ? mapUser(rs) : null;
    }
}$code$),
    ('sql-injection-prevention-java', 2, 'Avoid dynamic JPQL string building', $body$JPA and JPQL are not automatically safe. Building JPQL by concatenation, for example appending a filter value into a WHERE clause, reintroduces injection even though the code works with entity classes. Parameterize all values with named parameters, and express optional predicates with the criteria API or specifications. Dynamic sorting is a classic trap: ORDER BY cannot take a bound parameter for a column name, so map client-supplied sort keys through an allowlist to fixed column names. The same rules apply to native SQL and `EntityManager` calls. Rule of thumb: structure comes from code, values come from parameters.$body$, $code$@Query("select c from Customer c where c.region = :region")
List<Customer> findByRegion(@Param("region") String region);

// Sort keys are mapped from an allowlist, never pasted into the query.
String column = SORT_KEYS.getOrDefault(requested, "createdAt");
return repository.findAll(Sort.by(column));$code$),
    ('sql-injection-prevention-java', 3, 'Limit database account privileges', $body$Even with parameter binding, a compromised application account should not be able to reshape the database. Give the runtime account only the privileges the application exercises, typically SELECT, INSERT, UPDATE, and DELETE on its own schema, and keep DDL with a separate migration account. Deny file, network, and administrative extensions unless a documented need exists. Return generic database errors to clients and keep driver detail in server logs, because error text leaks schema and version information. Combine least privilege with connection pool limits so one workload cannot exhaust the database. Rule of thumb: if an attacker owns the runtime account, the damage should still be bounded.$body$, $code$-- The runtime account gets DML only; migrations use a separate account.
REVOKE CREATE ON SCHEMA app FROM jc_runtime;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA app TO jc_runtime;
ALTER DEFAULT PRIVILEGES IN SCHEMA app
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO jc_runtime;$code$),
    ('xss-prevention-java', 1, 'Encode output for its context', $body$XSS occurs when untrusted data is rendered as markup or script instead of text. The primary control is context-aware output encoding at the point of rendering, because the same value may be safe in HTML text and dangerous inside a script or URL attribute. Java template engines such as Thymeleaf, Freemarker, and JSP EL escape output by default; the risk sits in escape hatches such as `th:utext` or manually assembled markup. Encode at output rather than trying to strip characters on input, and treat any API named raw or unsafe as a review target. Rule of thumb: if a value reaches a browser without passing an encoder or a documented sanitizer, it is a finding.$body$, $code$<!-- Thymeleaf escapes HTML text by default; keep it that way. -->
<p th:text="${comment.text}">comment</p>

<!-- th:utext renders raw markup and must only receive sanitized values. -->
<!-- Prefer plain text rendering unless formatting is required. -->$code$),
    ('xss-prevention-java', 2, 'Sanitize rich text with allowlists', $body$Rich text is the difficult case: users need formatting, but the application must not execute what they send. Do not write a custom tag filter; use a maintained sanitizer such as the OWASP Java HTML Sanitizer with an explicit allowlist of elements and attributes, and sanitize before storing content that will later be rendered unescaped. Prefer plain text rendering unless formatting is a genuine product requirement. Watch URL and style attributes, where dangerous schemes can hide. Also be careful with Markdown processors that allow embedded HTML. Rule of thumb: sanitize for storage when rendering unescaped later, and encode output everywhere else.$body$, $code$PolicyFactory policy = new HtmlPolicyBuilder()
    .allowElements("p", "strong", "em", "ul", "li")
    .allowUrlProtocols("https")
    .toFactory();
String safe = policy.sanitize(untrustedHtml);$code$),
    ('xss-prevention-java', 3, 'Add Content Security Policy depth', $body$Content Security Policy is defense in depth, not a replacement for encoding. A policy that disallows inline scripts and restricts script sources makes many injected scripts fail even when an encoding bug slips through. Roll it out in report-only mode first, collect violations from real traffic, fix the largest offenders, then enforce. Prefer nonces for scripts the application generates, and avoid broad directives such as `unsafe-inline` and wildcard sources. Add `X-Content-Type-Options: nosniff` so browsers do not reinterpret content types. Rule of thumb: encoding prevents the vulnerability, CSP constrains the exploitation, and each layer is verified separately.$body$, $code$// Collect reports from real traffic before switching to enforcement.
http.headers(headers -> headers
    .contentSecurityPolicy(csp -> csp
        .policyDirectives("default-src 'self'; script-src 'self'; object-src 'none'")
        .reportOnly()));$code$),
    ('csrf-protection-java', 1, 'Recognize forged state-changing requests', $body$CSRF abuse works because browsers attach cookies to requests regardless of which site caused them. If a state-changing operation is authorized by a cookie and can be triggered from another origin, an attacker can act as the victim without reading any response. Safe methods must not change state, so a mutation behind GET is already a bug. Spring Security protects unsafe methods with a token when session authentication is used. Token-authenticated APIs where the browser does not attach credentials automatically have a different threat model, which is why they are usually exempt. Rule of thumb: cookie-authorized writes need an unguessable value the attacker cannot produce.$body$, $code$// Mutations use unsafe methods; GET must stay side-effect free.
@PostMapping("/orders/{id}/cancel")
void cancel(@PathVariable UUID id) {
    orders.cancel(id, currentUser());
}$code$),
    ('csrf-protection-java', 2, 'Use synchronizer tokens properly', $body$The synchronizer token pattern stores a random token server-side and requires it in each unsafe request, typically as a form field or header. An attacker who can trigger a cross-site request still cannot read the token, so the forged request fails. `CookieCsrfTokenRepository.withHttpOnlyFalse()` sends the token in a cookie that frontend code can read and echo in a header, which fits single-page applications but depends on preventing XSS, since scripting could read the cookie. Do not place tokens in URLs, where they leak through logs and referrers. Rule of thumb: keep protection on, and fix the client rather than disabling the check.$body$, $code$CookieCsrfTokenRepository repo = CookieCsrfTokenRepository.withHttpOnlyFalse();
http.csrf(csrf -> csrf.csrfTokenRepository(repo));

// On first request the server sets the XSRF-TOKEN cookie.
// The frontend echoes that value in the X-XSRF-TOKEN header
// on every POST, PUT, PATCH, and DELETE request.$code$),
    ('csrf-protection-java', 3, 'Set cookie attributes deliberately', $body$Cookie attributes limit how credentials travel. Mark session cookies `Secure` and `SameSite=Lax` or `Strict`, and `HttpOnly` except where frontend code must read the CSRF token by design. `SameSite` is useful but not sufficient by itself: behavior varies across clients, and some flows need cross-site redirects. For stateless APIs, bearer tokens in the authorization header are not attached automatically by browsers, so CSRF does not apply, but storing tokens in cookies brings the problem back. Choose the credential transport per surface and match defenses to it. Rule of thumb: one surface, one credential style, one documented set of protections.$body$, $code$ResponseCookie session = ResponseCookie.from("JSESSIONID", value)
    .httpOnly(true)
    .secure(true)
    .sameSite("Lax")
    .path("/")
    .build();
response.addHeader(HttpHeaders.SET_COOKIE, session.toString());$code$),
    ('input-validation-strategies', 1, 'Prefer allowlists over denylists', $body$Validation defines what the application accepts, which is a much smaller and more stable problem than enumerating everything malicious. An allowlist specifies expected type, length, range, and character set, and rejects everything else. Denylists built from known bad patterns fall behind encodings, new payloads, and international text. Validate at the boundary for cheap early rejection, and re-check critical invariants in the domain where a wrong value could corrupt state. Return clear errors without echoing raw input into the response. Rule of thumb: it is easier to describe valid input precisely than to predict every invalid one.$body$, $code$@PostMapping("/transfers")
void create(@Valid @RequestBody TransferRequest request) {
    // Constraints reject malformed input before this method runs.
    transfers.execute(request);
}$code$),
    ('input-validation-strategies', 2, 'Apply Bean Validation at boundaries', $body$Bean Validation annotations put field rules next to the data model they describe. Annotate request records with constraints such as `@NotBlank`, `@Size`, `@Email`, and `@Positive`, then add `@Valid` on the controller parameter so Spring triggers checking before the handler runs. Centralize failure handling so every endpoint returns a consistent problem response. Remember that annotations check syntax and simple ranges; rules requiring other state, such as uniqueness or ownership, belong in the service layer. Nested objects and collection elements need their own `@Valid` to cascade. Rule of thumb: annotations for shape, code for meaning.$body$, $code$record TransferRequest(
    @NotBlank @Size(min = 15, max = 34) String iban,
    @NotNull @DecimalMin("0.01") BigDecimal amount) {}

// @Valid on the controller parameter triggers these constraint checks.$code$),
    ('input-validation-strategies', 3, 'Canonicalize input before validating', $body$Canonicalize before validating so that what you check is what you use. Decode per the protocol exactly once, then normalize and trim, then validate the final representation. If downstream code decodes again or interprets a different form, a value can pass a check and still be misinterpreted. Unicode normalization and case folding change identifiers, so apply them deliberately and consistently; use `Locale.ROOT` for machine-facing text. Reject ambiguous input rather than guessing intent. Rule of thumb: one decode, one canonical form, then validate, and never validate a representation that differs from the stored one.$body$, $code$// Decode once, normalize, then validate the canonical form.
String raw = request.getParameter("account");
String canonical = Normalizer.normalize(raw, Normalizer.Form.NFC).trim();
if (!canonical.matches("[A-Z0-9-]{6,20}")) {
    throw new IllegalArgumentException("invalid account");
}$code$),
    ('secure-password-storage', 1, 'Hash with adaptive algorithms', $body$Passwords need slow, memory-hard hashing designed for the purpose: Argon2id first, then scrypt, bcrypt, or PBKDF2 where FIPS compliance applies. General purpose digests such as SHA-256 are fast enough for attackers to test billions of guesses, so they are unsuitable no matter how they are combined. Adaptive algorithms expose a cost parameter that can be raised as hardware gets cheaper, which is why the stored representation must record the parameters used. Current OWASP guidance suggests Argon2id with at least 19 MiB of memory, 2 iterations, and 1 degree of parallelism, or bcrypt with work factor 10 or higher. Rule of thumb: if the hash computes in microseconds, it is wrong.$body$, $code$// Argon2id with parameters at or above current OWASP guidance:
// 19 MiB of memory, 2 iterations, 1 degree of parallelism.
PasswordEncoder encoder = new Argon2PasswordEncoder(16, 32, 1, 19_456, 2);
String stored = encoder.encode(rawPassword);
boolean ok = encoder.matches(rawPassword, stored);
// matches() uses a constant-time comparison; never compare hashes by hand.$code$),
    ('secure-password-storage', 2, 'Let libraries handle salts', $body$Each password needs a unique, randomly generated salt so equal passwords produce different hashes and precomputed tables become useless. Modern libraries generate the salt and store it inside the encoded hash, which is why the whole string must be persisted exactly as produced. Never share one application-wide salt, and never encrypt passwords: encryption is reversible, so a stolen key reveals every password. bcrypt limits input to 72 bytes, so handle longer inputs deliberately. Rule of thumb: treat the encoded hash as an opaque value and let mature libraries decide its structure.$body$, $code$// The library generates a unique salt and embeds it in the encoded value.
String encoded = encoder.encode(rawPassword);
boolean ok = encoder.matches(rawPassword, encoded);
// Store the whole encoded string; never generate or store salts separately.
// bcrypt inputs beyond 72 bytes need an explicit decision.$code$),
    ('secure-password-storage', 3, 'Plan upgrades and password policy', $body$Plan upgrades from the start. `DelegatingPasswordEncoder` writes an algorithm prefix into each hash so old passwords keep verifying while new writes use the current default, and `upgradeEncoding` tells you when to rehash after a successful login. Policy should encourage length, screen against breached password lists, and limit attempts through rate limiting and lockout. Composition rules push users toward predictable patterns, so prefer other signals such as multi-factor authentication for sensitive operations. Never require rotation on a fixed schedule without evidence of compromise. Rule of thumb: make the better algorithm deployable without forcing a mass reset.$body$, $code$PasswordEncoder encoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();
if (encoder.matches(submitted, stored)) {
    if (encoder.upgradeEncoding(stored)) {
        user.updatePasswordHash(encoder.encode(submitted));
    }
    return authenticated(user);
}$code$),
    ('secrets-in-source-avoidance', 1, 'Assume repositories keep secrets forever', $body$A credential that reached a shared remote is exposed even if the commit was later reverted, because history, forks, and caches preserve it. Rewriting history helps reduce accidental discovery, but rotation is the real fix, and it must come first. Keep secrets out of files the repository tracks: read them from environment-specific sources such as a secret manager, and inject them at deploy time. Provide sample configuration with placeholder names and documentation instead of real values. Rule of thumb: assume everything in a repository will become public eventually and design configuration accordingly.$body$, $code$# Fail fast when a required secret is missing from the environment.
if [ -z "${JC_DB_PASSWORD:-}" ]; then
  echo "JC_DB_PASSWORD is required" >&2
  exit 1
fi$code$),
    ('secrets-in-source-avoidance', 2, 'Scan commits and full history', $body$Use two layers of scanning. A pre-commit hook such as gitleaks with staged scanning stops obvious leaks before they leave a workstation, but hooks can be skipped or misconfigured, so continuous integration should scan the full history on every push. Scan container images and build logs too, since credentials appear in layers and console output. Maintain a baseline for known historical findings and require an expiry and justification for every suppression. Alert a human when scanning itself fails, because a silent scanner is worse than none. Rule of thumb: prevent at commit time, detect continuously, and review exceptions monthly.$body$, $code$# 1. Local guard: scan staged content before the commit is created.
gitleaks git --pre-commit --redact --staged --verbose

# 2. CI guard: scan the full history on every push.
gitleaks git --redact --report-path gitleaks-report.json$code$),
    ('secrets-in-source-avoidance', 3, 'Centralize, separate, and rotate', $body$Store production secrets in a manager that offers access control, audit logging, and rotation, and give each environment and service its own credentials so a leak has a small blast radius. Separate human access from application access; people should not fetch runtime credentials by hand. Prefer short-lived credentials, such as those issued to workloads, over long-lived keys. After exposure, rotate the value, verify no unexpected use remains, then remove the artifact. Invalidate dependent sessions and tokens, not just the key. Rule of thumb: least privilege and short lifetimes bound the damage of any single leak.$body$, $code$String password = secretManager.currentValue("prod/orders/db");
DataSource dataSource = DataSourceBuilder.create()
    .url(url)
    .username("orders_runtime")
    .password(password)
    .build();
// Rotate in the manager, then reload configuration without code changes.$code$),
    ('dependency-vulnerability-scanning', 1, 'Inventory transitive dependencies with an SBOM', $body$Most of what an application actually ships arrives transitively, so start by knowing the full set of components and versions in each artifact. Generate a software bill of materials per build with a tool such as the CycloneDX Maven plugin or syft, and store it with the release rather than producing it later from source that may have moved. An inventory answers the first incident question fast: are we affected, and where. Keep the SBOM tied to the artifact digest so it stays trustworthy. Rule of thumb: you cannot patch, prioritize, or answer questions about components you cannot enumerate.$body$, $code$# Generate an SBOM from the same build that produced the artifact.
mvn -q org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom
# Or inventory an existing directory or image.
syft dir:. -o cyclonedx-json > sbom.json
# Store sbom.json next to the release so it matches the shipped digest.$code$),
    ('dependency-vulnerability-scanning', 2, 'Triage advisories with a policy', $body$Scanners generate noise, and noise destroys trust in the process. Define severity thresholds and then add context: is the vulnerable code reachable, does it process untrusted input, is the component exposed at runtime or only used in tests, and is a fixed version available. Suppress with documented justification and an expiry date so the decision is reviewed rather than forgotten. Prefer upgrading or removing a component over compensating controls that are easy to bypass. Track remediation as ordinary work with owners. Rule of thumb: triage by reachable risk, not by raw finding counts.$body$, $code$<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
  <suppress until="2026-12-31">
    <notes>Vulnerable class is not reachable from HTTP handlers.</notes>
    <packageUrl regex="true">pkg:maven/org\.example/legacy-lib@.*</packageUrl>
  </suppress>
</suppressions>$code$),
    ('dependency-vulnerability-scanning', 3, 'Make dependency updates a habit', $body$Frequent small updates are safer than rare large ones because each change is easier to test, review, and revert. Automate pull requests for dependency and base image updates with tools such as Dependabot or Renovate, and let a solid test suite and staged rollout make merging routine. Track direct dependencies for age and keep frameworks near current releases so emergency patching stays possible. Lock files reduce surprise but do not replace upgrades. Assign an owner per service for dependency health. Rule of thumb: make the normal path the secure path, then handle the rare critical advisory with the same small, tested steps.$body$, $code${
  "extends": ["config:recommended"],
  "packageRules": [
    { "matchUpdateTypes": ["patch"], "automerge": true }
  ],
  "schedule": ["before 6am on monday"]
}$code$),
    ('jwt-best-practices', 1, 'Keep claims minimal and typed', $body$A JWT is a signed container for claims, not a database or a session store. Carry only what the resource server needs for authorization decisions: subject, issuer, audience, expiry, and small role or scope values. Avoid personal data, internal identifiers that could aid enumeration, and mutable state that goes stale before the token expires. Anyone holding the token can read the payload, because signing protects integrity, not confidentiality. Use registered claim names from the JOSE specifications and document custom claims with a short namespace. Rule of thumb: if a claim would be uncomfortable on a postcard, it does not belong in a JWT.$body$, $code$JwtClaimsSet claims = JwtClaimsSet.builder()
    .issuer("https://auth.example.com")
    .subject(userId)
    .audience(List.of("orders-api"))
    .expiresAt(clock.instant().plus(Duration.ofMinutes(10)))
    .build();$code$),
    ('jwt-best-practices', 2, 'Pin algorithms and verify keys', $body$Verification is where the security lives. Configure the decoder with the exact algorithms you accept instead of trusting the algorithm named in the token header, and reject unsigned tokens. Validate issuer, audience, expiry, and not-before with library validators, and resolve keys from a JWKS endpoint with caching and a bounded refresh so key rotation works. Spring Security JOSE provides these pieces, but its default validators do not check audience, so add that check for every API. Keep signing keys out of application configuration where possible. Rule of thumb: verify against your policy, never against what the token claims about itself.$body$, $code$NimbusJwtDecoder decoder = NimbusJwtDecoder
    .withJwkSetUri(issuerUri + "/.well-known/jwks.json")
    .jwsAlgorithm(SignatureAlgorithm.RS256)
    .build();
decoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(
    JwtValidators.createDefaultWithIssuer(issuerUri),
    new JwtClaimValidator<List<String>>("aud",
        aud -> aud != null && aud.contains("orders-api"))));$code$),
    ('jwt-best-practices', 3, 'Design expiry, refresh, and revocation', $body$Access tokens should be short-lived, typically minutes, while refresh tokens carry the longer session. Plan revocation before it is needed: self-contained tokens cannot be withdrawn instantly, so keep lifetimes short and use a denylist only for cases that demand immediate effect, such as account suspension. Rotate refresh tokens on every use and treat reuse as a signal of theft. Validate clocks and allow a small skew, because expiry checks fail on drifted hosts. Rule of thumb: design the refresh flow so compromise has a short window and a visible signal.$body$, $code$// Access tokens are short-lived; refresh tokens rotate and are reusable once.
TokenPair issue(String userId) {
    Instant now = clock.instant();
    String access = jwt.issue(userId, now, Duration.ofMinutes(10));
    String refresh = refreshStore.rotate(userId, Duration.ofDays(14));
    return new TokenPair(access, refresh);
}$code$),
    ('oauth2-and-oidc-flows', 1, 'Use authorization code with PKCE', $body$Authorization Code with PKCE is the default flow for user-facing applications, including single-page and mobile clients that cannot keep a client secret. PKCE binds the authorization request to the token exchange with a per-flow verifier, so a stolen code is useless alone. Always validate the `state` parameter to prevent request forgery, and register exact redirect URIs, because prefix matching and open redirectors let attackers capture codes. The implicit grant and resource owner password grant are discouraged in current security guidance for new work. Rule of thumb: if there is no client secret, there must be PKCE and strict redirect handling.$body$, $code$ClientRegistration registration = ClientRegistrations
    .fromIssuerLocation("https://auth.example.com")
    .clientId("orders-ui")
    .redirectUri("{baseUrl}/login/oauth2/code/{registrationId}")
    .build();$code$),
    ('oauth2-and-oidc-flows', 2, 'Know client credentials and audiences', $body$Machine-to-machine calls use the client credentials grant, where the client authenticates itself and receives a token representing its own identity, not a user. The resource server must then check that the token was issued for it: validate the audience claim and required scopes for the specific operation, not merely the signature. A token minted for another service should fail even though it verifies cryptographically. Where supported, resource indicators scope tokens to a specific resource server. Rule of thumb: inspect what the token is for, not just who signed it.$body$, $code$// Signature alone is not enough: validate the intended audience too.
OAuth2TokenValidator<Jwt> audience = new JwtClaimValidator<List<String>>(
    JwtClaimNames.AUD, aud -> aud != null && aud.contains("orders-api"));
decoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(
    JwtValidators.createDefaultWithIssuer(issuer), audience));$code$),
    ('oauth2-and-oidc-flows', 3, 'Avoid OAuth configuration mistakes', $body$Misconfigurations, not protocol flaws, cause most OAuth incidents. Common examples include loose redirect URI matching, missing `state` or `nonce` validation, accepting tokens without checking issuer, audience, or expiry, and storing tokens in browser storage that any script can read. Prefer the authorization code flow with a backend-for-frontend pattern so refresh tokens stay on the server. Cache discovery and JWKS documents with sane lifetimes, but tolerate key rotation. Log token identifiers and outcomes, never token values. Rule of thumb: strict allowlists on redirect targets and full validation on every token, with no exceptions for convenience.$body$, $code$// PKCE is required for public clients that cannot keep a secret.
DefaultOAuth2AuthorizationRequestResolver resolver =
    new DefaultOAuth2AuthorizationRequestResolver(repository, "/oauth2/authorization");
resolver.setAuthorizationRequestCustomizer(
    OAuth2AuthorizationRequestCustomizers.withPkce());$code$),
    ('securing-rest-apis', 1, 'Layer authentication and authorization', $body$Authentication establishes who the caller is; authorization decides what that caller may do to a specific resource. Treating a valid token as blanket permission is a classic flaw: each endpoint needs an explicit decision, including object-level ownership so one customer cannot read another customer record by changing an identifier. Express rules with method security annotations or a policy layer enforced centrally, so newly added handlers do not silently skip checks. Deny by default and allow specific paths deliberately. Rule of thumb: never infer authorization from the fact that a request reached the handler code.$body$, $code$@EnableMethodSecurity
@Configuration
class MethodSecurityConfig {}

@PreAuthorize("hasAuthority('orders:read') and #customerId == authentication.name")
OrderView find(String customerId, String orderId) {
    return orders.findForCustomer(customerId, orderId);
}$code$),
    ('securing-rest-apis', 2, 'Limit abuse with rate and idempotency', $body$Public endpoints invite abuse: credential stuffing, scraping, and accidental retry storms. Apply rate limits per identity and per network where feasible, return `429` with a `Retry-After` header, and keep thresholds configurable without a redeploy. For operations that clients may retry, accept an idempotency key and store the key with the outcome for a bounded window so a timeout does not create duplicate orders or payments. Distinguish safe retries from duplicate submissions in your API contract. Rule of thumb: assume every request may arrive twice, and make repeats harmless.$body$, $code$@PostMapping("/payments")
ResponseEntity<Void> pay(@RequestHeader("Idempotency-Key") String key,
                         @Valid @RequestBody PaymentRequest request) {
    PaymentResult result = payments.executeOnce(key, request);
    return ResponseEntity.status(result.replayed() ? 200 : 201).build();
}$code$),
    ('securing-rest-apis', 3, 'Control error and data leakage', $body$Error responses and request binding are quiet data leak channels. Return a stable problem document with a correlation identifier, and keep stack traces, SQL, hostnames, and account existence checks out of responses. Bind explicit request records so clients cannot set fields the endpoint does not own, which prevents mass assignment of privileged attributes. Log diagnostic detail server-side where operators can find it. Document which fields are accepted and ignore or reject everything else deliberately. Rule of thumb: clients should learn how to correct the request, and nothing more.$body$, $code$@ExceptionHandler(OrderNotFoundException.class)
ProblemDetail handle(OrderNotFoundException ex) {
    ProblemDetail problem = ProblemDetail.forStatusAndDetail(
        HttpStatus.NOT_FOUND, "Order not found");
    problem.setProperty("correlationId", ex.correlationId());
    return problem;
}$code$),
    ('security-headers-and-csp', 1, 'Add transport and type headers', $body$Start with headers that carry little risk. `Strict-Transport-Security` tells browsers to refuse plain HTTP for the host for a given period; begin with a short max age while validating HTTPS coverage, then raise it, because a mistake is hard to undo until the policy expires. `X-Content-Type-Options: nosniff` stops browsers from reinterpreting uploaded or reflected content as script, and `Referrer-Policy` limits how much URL detail leaks to other sites. Configure these once in the framework and assert them in tests. Rule of thumb: cheap headers remove whole classes of browser behavior you would otherwise defend against.$body$, $code$http.headers(headers -> headers
    .httpStrictTransportSecurity(hsts -> hsts
        .maxAgeInSeconds(31_536_000)
        .includeSubDomains(true))
    .contentTypeOptions(Customizer.withDefaults()));$code$),
    ('security-headers-and-csp', 2, 'Control framing and referrer policy', $body$Clickjacking tricks users by framing a page and overlaying deceptive controls. The `frame-ancestors` directive in CSP supersedes `X-Frame-Options`, but keeping both helps older clients, and defaulting to deny is safest unless embedding is a product requirement. When it is, list only the origins that must frame the page. `Permissions-Policy` disables browser capabilities such as camera, microphone, and geolocation that the application does not use, shrinking what injected script can reach. Review these settings when new third-party integrations are added. Rule of thumb: deny by default, allow narrowly, and re-review on every integration.$body$, $code$// Deny framing unless an embedding product requirement exists.
http.headers(headers -> headers
    .frameOptions(frame -> frame.deny())
    .addHeaderWriter(new StaticHeadersWriter("Permissions-Policy",
        "camera=(), microphone=(), geolocation=()")));$code$),
    ('security-headers-and-csp', 3, 'Roll out CSP in stages', $body$Content Security Policy frequently breaks applications that rely on inline scripts, third-party tags, or eval, which is why enforcement should follow observation. Deploy `Content-Security-Policy-Report-Only` with a collector, watch what real traffic violates, fix the largest sources, then switch to enforcing and tighten from there. Use nonces or hashes for scripts the application generates, keep `object-src` at `none`, restrict `base-uri`, and allowlist only the third parties you have reviewed. Keep the policy in source control alongside application code so changes are reviewed. Rule of thumb: report, fix, enforce, then narrow, and never paste a strict policy into production untested.$body$, $code$// Start in report-only mode, fix violations, then enforce.
http.headers(headers -> headers
    .contentSecurityPolicy(csp -> csp
        .policyDirectives("default-src 'self'; script-src 'self'; object-src 'none'")
        .reportOnly()));$code$),
    ('cryptography-basics-for-java-devs', 1, 'Match primitives to their purpose', $body$Choose primitives by purpose. Symmetric encryption such as AES uses one key, is fast, and suits bulk data. Asymmetric cryptography separates public and private material, which suits signatures, identity, and key exchange. Hashing is one-way and fits integrity checks and password storage, using a password-specific algorithm there. Authenticated encryption, for example AES-GCM, protects confidentiality and detects modification, so prefer it over unauthenticated modes such as ECB. Nonce reuse under GCM is catastrophic, so nonces must be unique per key. Rule of thumb: define the goal first, then use a vetted library for a standard construction.$body$, $code$Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
byte[] nonce = new byte[12];
new SecureRandom().nextBytes(nonce);
cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(128, nonce));
byte[] ciphertext = cipher.doFinal(plaintext);$code$),
    ('cryptography-basics-for-java-devs', 2, 'Let TLS carry transport security', $body$TLS handles transport confidentiality and server authentication, and it is better than anything an application assembles. Its value depends on certificate validation: disabling it to silence an error removes the protection entirely, so fix the trust configuration instead. Use the platform trust store, or an explicit trust policy for internal services, and keep hostname verification on. Apply TLS between internal services too, because internal networks are not implicitly trusted. Treat plaintext protocols as temporary exceptions with a documented end date. Rule of thumb: when you find yourself writing certificate checks, you are probably weakening a solved problem.$body$, $code$// The platform trust store validates the server certificate by default.
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder(uri).build();
client.send(request, HttpResponse.BodyHandlers.ofString());
// Never replace this with a trust-all context, even for internal calls.$code$),
    ('cryptography-basics-for-java-devs', 3, 'Manage keys as production assets', $body$Keys are production assets with a lifecycle: generation from a secure random source, storage with restricted access, rotation on a schedule, and a documented response to compromise. Keep keys out of source code, container images, and configuration repositories; use a key management service or secret manager that records access. Separate keys by environment and purpose so one exposure does not cascade across systems. Rotate by introducing a new key while old data still references the previous key identifier, then retire the old key after consumers migrate. Rule of thumb: the strongest algorithm fails when key handling is careless.$body$, $code$// Keys live in a manager with access control and audit, not in the repo.
String keyId = keyManager.currentKeyId("payments");
byte[] key = keyManager.load(keyId);
EncryptedValue value = new EncryptedValue(keyId, encrypt(key, plaintext));
// Ciphertext records its key id so rotation does not require re-encryption.$code$),
    ('security-logging-and-auditing', 1, 'Log decisions with useful context', $body$Security logs should record decisions: authentication results, authorization denials, administrative actions, configuration changes, and rejected input, each with a timestamp, actor, source, and correlation identifier. Log the decision, not the payload: a rejected login is useful, the submitted password is not. Structured events in JSON are easier to query and alert on than prose, and a common schema lets several services be searched together. Include enough context to reconstruct a sequence without storing whole request bodies. Rule of thumb: if an investigation cannot answer who did what, when, and to which resource, the logging is incomplete.$body$, $code$String correlationId = MDC.get("correlationId");
String actorId = currentActor().id();
// Log the decision and identifiers, never the credential or payload.
log.info("authz.denied actor={} resource={} correlationId={}",
    actorId, resourceId, correlationId);$code$),
    ('security-logging-and-auditing', 2, 'Never log secrets or personal data', $body$Log stores leak because they are copied, aggregated, shared in tickets, and retained long after the incident. Exclude passwords, tokens, authorization headers, session identifiers, keys, and unnecessary personal data, and prefer structured allowlists over dumping entire objects. Apply redaction in the logging framework or a shared encoder so call sites cannot forget it, and review stack traces that may embed request detail. Protect access to log storage with the same discipline as the production database, including retention limits. Rule of thumb: a value that is sensitive in a database is equally sensitive in a log line.$body$, $code$record LoginEvent(String actorId, String outcome) {}

@PostMapping("/login")
void login(@Valid @RequestBody LoginRequest request) {
    // Build log events from allowlisted fields; the submitted password,
    // tokens, and authorization headers never reach this point.
    eventPublisher.publish(new LoginEvent(request.username(), "attempt"));
}$code$),
    ('security-logging-and-auditing', 3, 'Build tamper-evident audit trails', $body$Regulated actions need audit trails that outlive the application that wrote them: append-only storage, restricted write access, separate retention, and integrity protection such as hash chaining or a write-once medium. Record actor, action, target, outcome, and time, and make the trail queryable by auditors without granting production database access. Separate audit logging from operational logging so a flood of debug output cannot drown evidence, and alert when the audit pipeline stalls, because silent gaps undermine the whole control. Rule of thumb: if application credentials can edit the record, it is not audit evidence.$body$, $code$// Each entry chains to the previous one, so edits break verification.
String previous = auditStore.lastHash();
byte[] payload = (previous + event.canonicalForm()).getBytes(StandardCharsets.UTF_8);
String hash = HexFormat.of().formatHex(digest.digest(payload));
auditStore.append(event, hash);$code$),
    ('threat-modeling-basics', 1, 'Draw the data-flow diagram', $body$Start with a data-flow diagram: users, services, data stores, queues, and the trust boundaries where data crosses between zones with different levels of trust. Mark each place where input is parsed, stored, transformed, or forwarded, because that is where mistakes cluster. Keep the diagram close to the architecture and update it when components change, since a stale model produces confident but wrong conclusions. A whiteboard sketch is enough to begin; the value comes from the conversation it triggers. Rule of thumb: most missed threats hide in a data flow the team never wrote down.$body$, $code$record DataFlow(String source, String target, boolean crossesBoundary) {}
// Sketch the hops first; the boundary list drives the rest of the review.
List<DataFlow> flows = List.of(
    new DataFlow("browser", "api-gateway", true),
    new DataFlow("api", "orders-db", false));$code$),
    ('threat-modeling-basics', 2, 'Ask STRIDE questions per element', $body$STRIDE offers six prompting questions: spoofing identity, tampering with data, repudiation, information disclosure, denial of service, and elevation of privilege. Apply all six to each element that crosses a trust boundary. For a service, ask how callers authenticate, whether messages can be forged or replayed, whether actions are attributable, whether one tenant can read another tenant data, how capacity is exhausted, and whether a low-privilege caller can reach higher privilege. The framework is valuable because it covers categories reviewers naturally skip, especially repudiation and availability. Rule of thumb: every boundary crossing deserves the full question set.$body$, $code$enum Stride { SPOOFING, TAMPERING, REPUDIATION,
              DISCLOSURE, DENIAL_OF_SERVICE, ELEVATION }

// Ask all six questions for every element that crosses a boundary.
for (Stride question : Stride.values()) {
    review.logAnswer(element, question, answerFor(element, question));
}$code$),
    ('threat-modeling-basics', 3, 'Rank mitigations by risk', $body$Rank threats by impact and likelihood with existing controls taken into account, and consider attacker effort and reachability. Address high-risk items with structural controls such as design changes, default-deny rules, and missing checks; use monitoring and limits where prevention is impractical. Record accepted risks explicitly with an owner and a review date so they are decisions rather than oversights. Turn mitigations into backlog items with estimates, because a model that produces documents instead of work changes nothing. Revisit the model when architecture or data sensitivity changes. Rule of thumb: a threat model without owners and dates is theater.$body$, $code$record Threat(String description, int impact, int likelihood,
              String mitigation, String owner, LocalDate reviewBy) {}
// Rank by impact and likelihood; give every accepted risk an owner.
List<Threat> ranked = threats.stream()
    .sorted(Comparator.comparingInt(t -> t.impact() * t.likelihood()))
    .toList();$code$),
    ('supply-chain-security-slsa', 1, 'Produce and verify build provenance', $body$SLSA describes increasing guarantees about how an artifact was built. The build track starts with provenance that records the source, build platform, and inputs, then requires signed provenance from a hosted platform, then a hardened build environment that resists tampering during the build itself. Start by generating attestations for every release in a standard format and publishing them with the artifact, so consumers can verify before deploying. Provenance answers questions vulnerability scanning cannot: which commit, which pipeline, and which dependencies produced this binary. Rule of thumb: treat an artifact without provenance as an anonymous download.$body$, $code$# Attach verifiable provenance to the release artifact in CI.
- uses: actions/attest-build-provenance@v2
  with:
    subject-path: target/orders.jar
# Consumers verify provenance before deploying the artifact.$code$),
    ('supply-chain-security-slsa', 2, 'Sign and verify artifacts', $body$Signing links an artifact to an identity, but verification is where protection happens: a signature nobody checks blocks nothing. Sign container images and archives with tools such as Sigstore cosign, then enforce verification in admission control and deployment pipelines so unsigned or altered artifacts never run. Pin dependency versions by digest and verify checksums so a swapped package fails before execution. Keep signing keys in a managed service, and prefer short-lived workload identities over exported long-lived keys. Rule of thumb: sign for accountability, verify for enforcement, and automate both.$body$, $code$# Verification, not signing, is what blocks a tampered artifact.
cosign verify ghcr.io/example/orders:1.4.2 \
  --certificate-identity=https://github.com/example/orders/.github/workflows/release.yml@refs/tags/v1.4.2 \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
# Enforce this check in the deployment pipeline, not only at release time.$code$),
    ('supply-chain-security-slsa', 3, 'Harden the build platform', $body$Assume the build platform is a production system, because it holds credentials and can alter every artifact. Use short-lived tokens, keep workflow definitions under review with protected branches, and restrict which identities can change build configuration. Run builds on hosted, ephemeral runners so a pull request cannot modify the environment that compiles the release, and grant CI jobs the minimum permissions they need. Plan for publisher compromise: know how to revoke keys, rebuild from a clean environment, and notify consumers. Rule of thumb: compromise the build and every downstream artifact becomes suspect.$body$, $code$# Least privilege for the workflow token, with no write access by default.
permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest$code$)
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
    'owasp-top-ten-for-java', 'sql-injection-prevention-java', 'xss-prevention-java',
    'csrf-protection-java', 'input-validation-strategies', 'secure-password-storage',
    'secrets-in-source-avoidance', 'dependency-vulnerability-scanning', 'jwt-best-practices',
    'oauth2-and-oidc-flows', 'securing-rest-apis', 'security-headers-and-csp',
    'cryptography-basics-for-java-devs', 'security-logging-and-auditing',
    'threat-modeling-basics', 'supply-chain-security-slsa'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
