-- V26 — Refactoring and legacy modernization.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('refactoring-safely', 'Refactoring in Safe Steps', 'Improve structure in small verified steps while the build stays green and every change remains reversible.', 'Junior', 22, true, 1),
    ('naming-and-readability', 'Naming for Readability', 'Choose intention-revealing names, drop encoded prefixes, and treat consistency as a codebase asset.', 'Junior', 24, true, 1),
    ('extracting-methods-and-classes', 'Extracting Methods and Classes', 'Use decomposition signals and cohesion heuristics to break code apart without creating shallow abstractions.', 'Junior', 26, true, 1),
    ('replacing-conditional-logic', 'Replacing Conditional Logic', 'Choose polymorphism, lookup tables, or guard clauses deliberately when branching logic grows.', 'Mid', 32, true, 1),
    ('removing-duplication-carefully', 'Removing Duplication Carefully', 'Separate true duplication from incidental similarity and apply the rule of three with judgment.', 'Mid', 30, true, 1),
    ('working-with-legacy-code', 'Working with Legacy Code', 'Use characterization tests, seams, and sprout and wrap techniques to change unfamiliar code safely.', 'Mid', 34, true, 1),
    ('approval-testing-legacy-behavior', 'Approval Testing Legacy Behavior', 'Capture current behavior as a reviewed baseline before touching code you do not fully understand.', 'Mid', 30, true, 1),
    ('breaking-dependencies-in-legacy', 'Breaking Dependencies in Legacy Code', 'Introduce dependency injection as a testing seam and retire statics and singletons incrementally.', 'Mid', 28, true, 1),
    ('incremental-framework-upgrades', 'Incremental Framework Upgrades', 'Move Spring Boot and Java versions in staged, verifiable steps aligned with deprecation deadlines.', 'Senior', 42, true, 1),
    ('modularizing-a-monolith', 'Modularizing a Monolith', 'Create module boundaries inside one deployable and enforce them with package rules and ArchUnit.', 'Senior', 44, true, 1),
    ('code-review-for-maintainability', 'Code Review for Maintainability', 'Review for the cost of future change, keep review scope disciplined, and give actionable feedback.', 'Mid', 30, true, 1),
    ('eliminating-technical-debt-systematically', 'Eliminating Technical Debt Systematically', 'Track debt as ranked, evidenced items and prioritize by the interest paid every month.', 'Mid', 32, true, 1),
    ('dead-code-and-orphan-removal', 'Dead Code and Orphan Removal', 'Detect unused code, retire feature flags, and delete safely using telemetry first.', 'Senior', 36, true, 1),
    ('documentation-that-survives', 'Documentation That Survives', 'Keep living docs, record decisions as ADRs, and make README-first onboarding an executable path.', 'Mid', 26, true, 1),
    ('refactoring-data-and-schemas', 'Refactoring Data and Schemas', 'Ship data changes through dual writes, backfills, and contract phases with tested rollback plans.', 'Mid', 28, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('refactoring-safely', 1, 'Small steps keep the build green', $body$Production code changes constantly, so refactoring has to be safe rather than heroic. Small steps that keep the build green let the compiler, tests, and version control catch mistakes while the change is cheap to undo. Make one structural change at a time, run the fastest relevant tests after each step, and commit often so a failure can be bisected. IDE-assisted moves such as rename, extract method, and inline symbol update every caller and beat manual edits. The pitfall is performing several edits at once and then debugging them together. Rule of thumb: if a step cannot be described in one sentence, it is too large.$body$, $code$// before: two edits at once, unverifiable
// rename + extract + move in a single commit

// after: one verified step at a time
class InvoiceService {
    private final TaxCalculator tax;

    Money total(Invoice invoice) {
        return invoice.net().plus(tax.calculate(invoice)); // rename, test, commit
    }
}$code$),
    ('refactoring-safely', 2, 'Let tooling carry the mechanics', $body$Mechanical edits are exactly where automation beats attention. Rename symbols through the IDE so references, tests, and configuration follow in one refactoring; extract method to create named units; move classes to correct their home; inline to retire indirection that no longer pays. Keep the mechanical change and the behavioral change in separate commits, because a mixed diff makes review and rollback ambiguous. The pitfall is hand-editing a rename with search and replace and silently missing a string reference in a configuration file. Rule of thumb: if a tool can prove the edit, let the tool make it.$body$, $code$// before: manual, error-prone
// person.setHomeCity(city) // rename by hand across 40 files

// after: IDE rename with preview, tests still green
// Refactor > Rename Symbol > "city" -> "homeCity"
// then: git commit -m "rename city to homeCity"$code$),
    ('refactoring-safely', 3, 'Refactor now or rewrite later', $body$Refactoring and rewriting solve opposite problems. Refactoring preserves observable behavior while improving structure in steps that stay releasable. A rewrite discards working knowledge embedded in edge cases and takes a long time to reach parity; the classic failure is two systems to maintain and a migration that never finishes. Legacy code with scheduled changes rarely needs a rewrite; it needs a series of safe refactorings so the behavior you keep is the behavior you trust. Rewrite only when the current implementation cannot meet a hard requirement at all. Rule of thumb: default to refactor, and make any rewrite a funded decision with a parallel-run plan.$body$, $code$// before: rewrite under deadline pressure
// ParserV2 written from scratch, old one still serving traffic

// after: refactor behind the same contract
interface InvoiceParser {
    Invoice parse(String raw);
}

class CsvInvoiceParser implements InvoiceParser {
    public Invoice parse(String raw) {
        return parseRows(raw); // improve incrementally; callers never notice
    }
}$code$),
    ('naming-and-readability', 1, 'Names that reveal intention', $body$A method should be callable without reading its body, and that starts with the signature. Intention-revealing names describe the outcome rather than the mechanism: `retryable` reads better than `checkFlags`, and `overdueInvoices` reads better than `filterList2`. Parameter names matter too, because call sites and diagnostics show them. Boundaries should be legible at the call site, so avoid long boolean parameter lists where every argument is a positional guess; introduce a small type when meaning is unclear. The pitfall is a name that is accurate but useless, such as `processData`. Rule of thumb: the cheapest documentation you will ever write is a good name.$body$, $code$// before: mechanism and encoding in the name
List<Invoice> doFilter(List<Invoice> l, int s) { ... }

// after: outcome and domain meaning
List<Invoice> overdueInvoices(List<Invoice> invoices, Instant now) {
    return invoices.stream()
        .filter(invoice -> invoice.dueAt().isBefore(now))
        .toList();
}$code$),
    ('naming-and-readability', 2, 'Stop encoding types in names', $body$Encoding schemes in names, such as Hungarian prefixes, `m_` fields, and `I` interface markers, were workarounds for tooling that no longer exists. Modern IDEs show types on hover, so `accountList` can be `accounts` and `strEmail` can be `email`. Prefixes also invite dangerous edits: when `intSize` becomes a `long` but the name stays, the name lies about the type. Keep spelling consistent across modules as well, because mixed synonyms force readers to verify whether `customer`, `client`, and `buyer` are the same concept. The pitfall is a team-wide rename without an agreed glossary. Rule of thumb: names carry meaning and types carry type.$body$, $code$// before: type encoded in the name
String strEmail; int intSize; List<Order> orderList;

// after: meaning only, type stays in the type
String email; int orderCount; List<Order> orders;

// rename through the IDE so references follow$code$),
    ('naming-and-readability', 3, 'Consistency as a codebase asset', $body$Consistency is a codebase asset built deliberately, not a personal style preference. When one concept keeps one name, one exception policy, and one return convention across modules, readers predict code they have never seen and reviewers focus on logic instead of archaeology. Inconsistency costs more than ugliness: two logging facades, two money types, or two `NotFoundException` classes each force a choice at every call site. The pitfall is imposing a large convention without tooling, so it drifts within weeks. Encode the essentials in linters or formatters, and record the rest where newcomers read it. Rule of thumb: every convention needs an owner and an enforcement mechanism, or it is only a suggestion.$body$, $code$// before: same concept, three names
service.load(); // vs gateway.fetch() vs repository.get()

// after: one glossary term everywhere
service.findCustomer(id);

// enforce the boring parts with tooling:
// Checkstyle, Spotless, or an ArchUnit naming rule$code$),
    ('extracting-methods-and-classes', 1, 'Extraction signals worth acting on', $body$Long methods are not wrong by themselves; the problem is that they hide concepts and make changes risky. Strong signals for extraction: a block of code that needs a comment to explain it, a loop doing two jobs, a method name that needs "and" to be accurate, or mixed levels of abstraction in one body. Extracting a method creates a testable, nameable unit and makes the surrounding code read like a summary. The pitfall is extracting single-use fragments that add indirection without meaning. Rule of thumb: extract when the new name explains something a reader would otherwise have to reconstruct.$body$, $code$// before: two jobs and an explanatory comment
void render(Report r) {
    print(r.title().toUpperCase() + " (" + r.rows().size() + ")");
    r.rows().forEach(row -> print(row.format()));
}

// after: named steps replace the comment
void render(Report r) {
    print(headerLine(r));
    r.rows().forEach(row -> print(row.format()));
}
String headerLine(Report r) {
    return r.title().toUpperCase() + " (" + r.rows().size() + ")";
}$code$),
    ('extracting-methods-and-classes', 2, 'Cohesion decides class boundaries', $body$A class should have one reason to change, and cohesion tells you when that stops being true. If two groups of methods touch disjoint sets of fields, the class is probably two classes sharing a name. Watch for methods that never call each other, fields used by only a subset of methods, or field prefixes such as accountName and shipmentId inside one class. Splitting along those seams usually pays. The pitfall is splitting by technical layer instead of concept, which spreads one change across many files. Rule of thumb: place together what changes together; separate what changes for different reasons and at different times.$body$, $code$// before: one class, two disjoint jobs
class Report {
    private List<Row> rows;
    private PrintWriter sink;

    String toCsv() { return format(rows); }
    void writeTo(PrintWriter out) { out.print(format(rows)); }
}

// after: rendering and transport are separate reasons to change
class Report { List<Row> rows; }
class CsvRenderer { String render(Report r) { return format(r.rows); } }$code$),
    ('extracting-methods-and-classes', 3, 'Avoid premature abstraction', $body$Abstraction guessed from a single example is usually wrong. If you generalize from one caller you must predict the differences that later callers will bring, and predictions are often incorrect; the result is a framework of parameters no one understands. Wait until you have two or three real, existing cases before inventing a shared interface. When the cases do arrive, shape the abstraction from their actual similarities, not from an imagined future requirement. The pitfall is a base class with boolean flags that every subclass must decode. Rule of thumb: duplication is cheaper to fix than the wrong abstraction, so copy twice and abstract on the third case.$body$, $code$// before: abstraction invented from one caller
abstract class BaseHandler<T, C> {
    protected abstract T handle(C ctx, Map<String, Object> options);
}

// after: direct code first
class RefundHandler {
    Receipt refund(Order order) { return gateway.refund(order); }
}
// extract a shared interface only when a second handler exists$code$),
    ('replacing-conditional-logic', 1, 'Guard clauses before polymorphism', $body$Many if-else chains are validation, not variation, and validation is best written as guard clauses. Checking preconditions first and returning or throwing early leaves one clear path through the method instead of nesting the real work inside conditions. Guard clauses also make failure behavior visible: a caller can see exactly which invariant was violated. The pitfall is a guard clause with a side effect, which turns control flow into hidden work. Rule of thumb: handle error and edge cases first, keep the happy path unindented at the bottom, and reach for polymorphism only when branches represent genuinely different behaviors that keep growing.$body$, $code$// before: nested happy path
BigDecimal fee(Order order) {
    if (order != null) {
        if (order.isInternational()) return order.total().multiply(RATE);
    }
    return BigDecimal.ZERO;
}

// after: guards first
BigDecimal fee(Order order) {
    if (order == null) throw new IllegalArgumentException("order");
    if (!order.isInternational()) return BigDecimal.ZERO;
    return order.total().multiply(RATE);
}$code$),
    ('replacing-conditional-logic', 2, 'Tables and strategy dispatch', $body$When a switch or if chain maps a type code to handling logic, a better home often exists: a lookup table, an enum with a method, or a small strategy interface. These forms are open for extension by adding one entry instead of editing every branch, and they keep each behavior in its own unit. Avoid ceremony: with modern Java a strategy can be a map of lambdas or an enum constant with a function, so there is no need for a class hierarchy per case. The pitfall is scattering dispatch across the codebase. Rule of thumb: one dispatch point per decision, chosen by what actually varies.$body$, $code$    // before: an if chain that grows with every case
    BigDecimal discount(String type, BigDecimal price) {
        if ("SEASONAL".equals(type)) return price.multiply(new BigDecimal("0.9"));
        if ("COUPON".equals(type)) return price.subtract(new BigDecimal("5"));
        return price;
    }

    // after: a table of behaviors, extended by one entry
    Map<String, UnaryOperator<BigDecimal>> discounts = Map.of(
        "SEASONAL", p -> p.multiply(new BigDecimal("0.9")),
        "COUPON", p -> p.subtract(new BigDecimal("5")));
    BigDecimal apply(String type, BigDecimal price) {
        return discounts.getOrDefault(type, UnaryOperator.identity()).apply(price);
    }$code$),
    ('replacing-conditional-logic', 3, 'When polymorphism costs more', $body$Replacing conditionals with classes is not free. Each strategy adds indirection: stack traces get deeper, navigation takes more steps, and readers must follow a wiring layer before finding behavior. When branches are stable, few, and local, a simple conditional is cheaper to read and maintain than a hierarchy. Choose based on volatility and growth: business rules that arrive quarterly deserve their own types; a two-branch check unchanged for years does not. The pitfall is pattern-driven refactoring that trades clarity for ceremony. Rule of thumb: refactor conditionals that change often, keep the ones that do not, and never introduce a factory only to obey a pattern.$body$, $code$// stable, two-branch check: keep it simple
if (user.isAdmin()) return fullView();
return limitedView();

// volatile decision table: give each rule its own home
interface ShippingRule { Money cost(Shipment s); }
class OversizeRule implements ShippingRule { ... }
class IntlRule implements ShippingRule { ... }
// selected once by a registry, extended without editing a switch$code$),
    ('removing-duplication-carefully', 1, 'True duplication vs incidental similarity', $body$Duplication is not about identical text; it is about duplicated knowledge. Two fragments can look alike while representing decisions that will evolve separately, and merging them couples teams that should stay independent. Before extracting shared code, ask what would happen if one caller needed a change: if the answer is a new boolean parameter, the similarity was incidental. Real duplication is when one rule is written twice, so a change to the business meaning must be made in two places or it silently diverges. The pitfall is enforcing a text-matching metric. Rule of thumb: deduplicate repeated decisions, tolerate repeated shapes.$body$, $code$// before: merged because the lines look alike
double tax = scale(price, 0.2);      // VAT, owned by finance
double fee = scale(principal, 0.2);  // commission, owned by brokerage

// after: keep separate knowledge separate
double tax = price * VAT_RATE;
double fee = principal * COMMISSION_RATE;
// extract only if both ever change for the same reason$code$),
    ('removing-duplication-carefully', 2, 'The rule of three revisited', $body$The rule of three is a heuristic, not a law: wait until the third real occurrence before building a shared abstraction, because two examples contain too little information about what actually varies. On the third occurrence the invariant pattern is usually clear, and parameterization can be shaped by evidence rather than guesswork. The rule is equally misapplied to code that must not drift, such as money rounding or authorization checks, where duplication is dangerous from the first copy. Rule of thumb: apply the rule to code that copies a shape, not to code that copies a rule that must stay in sync.$body$, $code$// first two callers: duplication is acceptable
BigDecimal priceWithTax(Order o) { return o.net().multiply(TAX); }
BigDecimal priceWithFee(Order o) { return o.net().multiply(FEE); }

// third caller arrives: the varied parameter is now visible
BigDecimal priceScaled(Order o, BigDecimal factor) {
    return o.net().multiply(factor);
}$code$),
    ('removing-duplication-carefully', 3, 'Refactor duplicates together', $body$When you do remove duplication, do it as a refactoring rather than a rewrite. Extract the shared logic in a place both callers can reach, switch one caller, run its tests, then switch the next; each step is small and reversible. Resist flag parameters that switch behavior inside the shared method, because a parameter that changes what the code does is a conditional in disguise and will multiply. If the callers need genuinely different behavior, the shared part is smaller than it appeared: extract only the common core and leave the variation at the call sites. Rule of thumb: shared code should serve its callers, not interrogate them.$body$, $code$// before: flag parameter serving two callers
String render(Report r, boolean html) {
    return html ? toHtml(r) : toText(r);
}

// after: keep variation at the call site
String render(Report r, Renderer renderer) {
    return renderer.apply(r);
}
render(report, Renderer::toHtml);
render(report, Renderer::toText);$code$),
    ('working-with-legacy-code', 1, 'Characterization tests first', $body$Legacy code is code you depend on but do not dare to change, often without tests and with behavior nobody fully remembers. Before modifying it, write characterization tests that capture what the code actually does, including behavior that looks like a bug. Run the code, record the real output, and assert on it; the tests describe current behavior, not desired behavior, so you can tell whether a later refactoring changed anything. The first version may pass for the wrong reason, so verify that each assertion can fail. The pitfall is asserting on guessed behavior. Rule of thumb: the code is the specification until a deliberate change makes it otherwise.$body$, $code$@Test
void legacyRoundingKeepsTwoDecimals() {
    // observed behavior, including the odd rounding direction
    assertEquals(new BigDecimal("10.55"),
        LegacyBilling.roundHalfDown(new BigDecimal("10.554")));
}

@Test
void blankCustomerIdFallsBackToUnknown() {
    assertEquals("UNKNOWN", LegacyBilling.customerId("  "));
}$code$),
    ('working-with-legacy-code', 2, 'Find a seam to substitute', $body$Changing behavior safely requires a seam: a place where you can substitute a different implementation without editing the code around it. Common seams are constructor parameters, overridable methods, and build-time replaceable collaborators. In legacy code the first move is often a method extraction whose only purpose is to create a seam: pull the hard-coded call into a protected method, then override it in a test subclass. For static or third-party calls, a thin wrapper class is usually enough. The pitfall is a seam with production side effects, such as connecting to a database during test setup. Rule of thumb: before writing a test, ask where the substitution point is; if there is none, create the smallest one.$body$, $code$class PaymentGateway {
    // seam: tests override this to substitute the clock
    protected Instant now() {
        return Instant.now();
    }

    Receipt charge(Money amount) {
        return client.submit(amount, now());
    }
}

class TestGateway extends PaymentGateway {
    @Override protected Instant now() { return Instant.parse("2026-01-01T00:00:00Z"); }
}$code$),
    ('working-with-legacy-code', 3, 'Sprout and wrap techniques', $body$Two techniques let you add behavior to legacy code without rewriting it. Sprout: write the new logic in a fresh, well-tested method or class, then call it from the old code with a single line, keeping the risky area untouched. Wrap: rename the old method and create a method with the original name that calls it, so you can add behavior before or after the call without modifying the body. Wrapping a whole class works the same way when new behavior must intercept all callers. The pitfall is letting sprouted code grow into a new monolith inside the old one. Rule of thumb: keep new tested code separate, and connect it to legacy with the thinnest possible wire.$body$, $code$// sprout: one tested call inside the legacy loop
for (Invoice inv : loadAll()) {
    InvoiceTaxes.applyIfMissing(inv); // sprout
    post(inv);
}

// wrap: intercept the old method in a subclass
class WrappedJob extends LegacyInvoiceJob {
    @Override void post(Invoice inv) {
        audit(inv);
        super.post(inv);
    }
}$code$),
    ('approval-testing-legacy-behavior', 1, 'Freeze behavior before changing it', $body$Approval testing, also called golden master testing, freezes the exact output of a piece of code so any change shows up as a diff. It fits legacy code whose full behavior is unknown: instead of asserting individual rules you capture the complete output for a set of inputs, review it once, and commit it as the approved baseline. After that, any edit that alters behavior fails the test with a readable difference. The pitfall is approving machine output without reading it, which enshrines accidents as expectations. Rule of thumb: an approved file is a reviewed specification, so read it line by line before it becomes the baseline.$body$, $code$// capture current output, then review and approve it as a spec
@Test
void legacyFormatterMatchesApprovedBaseline() {
    String actual = LegacyReportFormatter.format(sampleInput());
    Approvals.verify(actual); // writes a received file to review
}
// first run: inspect the received file, approve it,
// then commit the approved file next to the test$code$),
    ('approval-testing-legacy-behavior', 2, 'Record real inputs, not guesses', $body$A golden master is only as representative as its input set. Collect inputs from production evidence: logged requests, stored rows, support tickets, or test data that already exercises tricky branches. Include the awkward cases that make legacy code valuable, such as empty collections, unusual locales, and records with missing fields. If input volume is large, keep a curated, deterministic sample in the repository and note why each cluster is present. The pitfall is a tiny input set that makes the baseline look stable while real traffic still breaks it. Rule of thumb: build the baseline from data that exists, not from data that is convenient.$body$, $code$// deterministic sample built from real shape variety
static List<String> legacySamples() {
    return List.of(
        "",                          // blank input
        "acct-1;2026-01-01;10.50",   // typical row
        "acct-2;;0",                 // missing date
        ";;");                       // all fields empty
}$code$),
    ('approval-testing-legacy-behavior', 3, 'Keep large baselines manageable', $body$Full output baselines can be huge, which makes review the bottleneck. Reduce what is captured: select stable fields, normalize timestamps, identifiers, ordering, and formatting before approval so the diff shows behavior rather than noise. For very large outputs, verify a summary such as counts, checksums, or sorted aggregates, and keep a smaller detailed snapshot for the interesting paths. Tools such as ApprovalTests write a received file, leaving approval as an explicit human step, which keeps review honest. The pitfall is a baseline nobody rereads, which turns review into ritual. Rule of thumb: approve the smallest output that would notice a real behavior change.$body$, $code$// normalize volatile fields before approving
String normalized = actual
    .replaceAll("Id=[0-9a-f-]+", "Id=<id>")
    .replaceAll("\\d{4}-\\d{2}-\\d{2}T[\\d:.]+Z", "<timestamp>");
Approvals.verify(normalized);

// or approve a stable summary for very large outputs
Approvals.verify(summarizeIndex(result));$code$),
    ('breaking-dependencies-in-legacy', 1, 'Dependency injection as a testing seam', $body$Hard dependencies, created with `new` inside a method or reached through a static call, make code impossible to isolate: every test drags in the network, clock, or filesystem. Dependency injection is first a testing seam and only later a design principle. Start by passing the collaborator in through the constructor, or extract a factory method and override it in a test subclass, so tests supply a fake while production wiring stays where it is. Constructor parameters also make dependency lists visible during review. The pitfall is injecting everything without reason, which turns cohesion into a configurable soup. Rule of thumb: inject what varies, lies outside your process, or must be controlled in tests; construct the rest.$body$, $code$// before: hidden dependency, untestable
class ReportJob {
    void run() {
        new SmtpClient("mail.internal").send(build());
    }
}

// after: constructor seam
class ReportJob {
    private final Mailer mailer;

    ReportJob(Mailer mailer) { this.mailer = mailer; }
    void run() { mailer.send(build()); }
}$code$),
    ('breaking-dependencies-in-legacy', 2, 'Static and singleton extraction', $body$Statics and singletons hide dependencies in a form no test can replace: a static call has no substitution point, and a singleton carries mutable state across tests in unpredictable order. The extraction pattern is mechanical. Wrap the static call in an instance method, keep the static implementation behind it for now, and pass the wrapper in where needed. Then migrate callers one at a time to injected use, and only when none remain delete the static entry point. For singletons, move state behind an interface and construct one instance in production wiring. The pitfall is keeping both paths permanently, so behavior forks. Rule of thumb: wrap, inject, migrate, delete, in that order.$body$, $code$// before: static call with hidden state
static Instant now() { return Clock.systemUTC().instant(); }
record Entry(String id, Instant at) {}
static Entry create(String id) { return new Entry(id, now()); }

// after: injectable time source
interface TimeSource { Instant now(); }   // production: Clock.systemUTC()::instant
class EntryFactory {
    private final TimeSource time;
    EntryFactory(TimeSource time) { this.time = time; }
    Entry create(String id) { return new Entry(id, time.now()); }
}$code$),
    ('breaking-dependencies-in-legacy', 3, 'Break dependencies in safe order', $body$Large dependency knots are untangled by improving testability first, not by deleting code. Add characterization tests around the current behavior, then introduce the seam that unlocks substitution, then move one collaborator at a time, running tests after each move. Keep refactoring commits separate from behavior commits so a failure points to one cause. Watch for hidden coupling such as shared mutable caches, thread-local state, and static initializers; these often need their own extraction before the class can be tested at all. The pitfall is a big-bang rewrite of the dependency graph. Rule of thumb: every change should make the next test easier to write.$body$, $code$// safe order: characterize, add seam, migrate one dependency, test
class PricingService {
    private final FxRates rates;      // new seam, faked in tests
    private final AuditLog audit;     // still static for now

    PricingService(FxRates rates) { this.rates = rates; }

    Money price(Order order) {
        Money base = order.net();
        AuditLog.record(order.id());  // migrate this next
        return base.convert(rates::rateFor);
    }
}$code$),
    ('incremental-framework-upgrades', 1, 'Upgrade in verifiable stages', $body$Framework upgrades fail when they are attempted as one leap. Split the work into stages that each end on a green build: move patch versions first, upgrade Spring Boot and Java separately rather than together, and keep the application running on the old surface while the new one is prepared. Between stages, read the release notes and configuration changelogs, because upgrades often change defaults such as connection-pool sizing or serialization behavior. A rollback plan is part of the stage definition, not an afterthought. The pitfall is bundling a major Java jump with a framework jump so failures cannot be attributed. Rule of thumb: one axis of change per stage, each independently releasable and revertible.$body$, $code$// staged plan, each stage merged and released on its own
// stage 1: 3.2.x -> 3.2.latest   (patch only)
// stage 2: 3.2.x -> 3.3.x        (minor, same Java)
// stage 3: Java 17 -> 21         (toolchain only)
// stage 4: 3.3.x -> 3.4.x        (minor on the new Java)
// record the result of each stage before starting the next$code$),
    ('incremental-framework-upgrades', 2, 'Deprecations as a work queue', $body$Compiler deprecation warnings are a migration queue with evidence. Turn warnings on and stop ignoring them: each one marks an API with a published removal timeline, and fixing them while the old API still works is far cheaper than fixing them during a crisis upgrade. Group the work by owner and release train rather than by warning count, and treat third-party deprecations as dependency-alignment work, not as accepted noise. The pitfall is a build that hides warnings behind a suppression file, which postpones the cost without reducing it. Rule of thumb: no new deprecation warnings on main, and burn down the existing list on a schedule tied to removal releases.$body$, $code$// turn warnings into visible migration work
tasks.withType(JavaCompile).configureEach {
    options.compilerArgs << "-Xlint:deprecation" << "-Werror"
}

// fix at the call site while the old API still exists
// before: new WebSecurityConfigurerAdapter(); // deprecated
// after:  SecurityFilterChain chain(HttpSecurity http) { ... }$code$),
    ('incremental-framework-upgrades', 3, 'Align dependencies after the move', $body$Upgrades break on mismatched transitive versions more often than on the framework itself. After a stage, inspect the resolved dependency tree for duplicate artifacts, conflicting major versions, and libraries still compiled against the previous runtime. Align BOM-managed versions and let the platform manage shared libraries where it can. Remove pinning overrides once they are no longer needed, because an old pin silently wins over a managed version and reintroduces compatibility bugs. The pitfall is upgrading one library because its version changed in the release notes while ignoring its companions. Rule of thumb: every upgrade stage ends with a fresh dependency report and an empty list of unexpected duplicates.$body$, $code$// inspect instead of guessing
// ./mvnw dependency:tree -Dincludes=com.fasterxml.jackson
// ./gradlew dependencies --configuration runtimeClasspath

// before: stale pin wins over the managed version
// implementation("com.fasterxml.jackson.core:jackson-databind:2.13.0")

// after: let the BOM choose, remove the override
// implementation("com.fasterxml.jackson.core:jackson-databind")$code$),
    ('modularizing-a-monolith', 1, 'Real module boundaries in one deployable', $body$A modular monolith keeps one deployable but enforces internal boundaries as strictly as service interfaces. Draw modules around business capabilities, give each a public package for its API and keep implementation packages private to it, and organize code so dependencies run one direction: modules depend on the contracts of other modules, never on their internals. This buys the comprehension and ownership benefits often cited for microservices without distributed transactions, network failure modes, or a service per team. The pitfall is drawing modules along technical layers instead of capabilities, which spreads every feature across all modules. Rule of thumb: if a module cannot be described by the capability it owns, the boundary is wrong.$body$, $code$// package layout: public API vs internal implementation
// com.acme.billing.api.InvoiceService      <- allowed for other modules
// com.acme.billing.internal.InvoiceJpa     <- module private
// com.acme.inventory.api.StockService

// dependency direction: billing -> inventory.api, never inventory.internal$code$),
    ('modularizing-a-monolith', 2, 'Enforce boundaries with ArchUnit rules', $body$Boundaries that exist only in documentation disappear under deadline pressure, so encode them as tests. ArchUnit runs as a unit test and checks package dependencies, naming, and layering in seconds: for example, no code outside a module may reference its internal package, and modules may not form cycles. Because the rules are executable, they break the build at the moment of violation while the violation is still small. Write rules incrementally, starting with the boundaries you most need. The pitfall is writing a huge rule set in one commit, producing a freeze file nobody understands. Rule of thumb: every boundary you agree to should have one corresponding ArchUnit rule.$body$, $code$@AnalyzeClasses(packages = "com.acme")
class ModuleBoundariesTest {

    @ArchTest
    static final ArchRule internalsArePrivate = noClasses()
        .that().resideOutsideOfPackage("..billing..")
        .should().dependOnClassesThat().resideInAPackage("..billing.internal..");

    @ArchTest
    static final ArchRule noCycles = slices()
        .matching("com.acme.(*)..").should().beFreeOfCycles();
}$code$),
    ('modularizing-a-monolith', 3, 'Decouple data before extraction', $body$Module boundaries are cheap to arrange in code and expensive to arrange in databases. Two modules sharing one table are not really independent: a schema change made for one breaks the other, and ownership is ambiguous. Before claiming a boundary, make write access single-owner and expose the other module reads through an API or a purpose-built view, then remove cross-module joins from hot paths. Physical extraction to a service is a later, optional step; a module with a respected data contract can move when scaling or team topology actually demands it. The pitfall is dividing packages while leaving shared tables untouched. Rule of thumb: one writer per table group, and every cross-module read goes through a contract.$body$, $code$// before: two modules, one table, hidden coupling
// billing writes invoice_total; reporting reads and updates it

// after: single writer, explicit read contract
class InvoiceQueryView {                   // reporting adapter
    BigDecimal totalFor(long invoiceId) {  // reads a view, never writes
        return jdbc.queryForObject(
            "SELECT total FROM invoice_read_model WHERE id=?",
            BigDecimal.class, invoiceId);
    }
}$code$),
    ('code-review-for-maintainability', 1, 'Look beyond correctness', $body$Reviewers easily fixate on whether code works today and miss whether the next person can change it safely. Beyond correctness, look for tests that would catch a regression, names that reveal intent, error handling that leaves useful evidence, and operational hooks such as metrics and log context. Check that the change keeps the codebase simpler rather than adding a special case that future readers must decode. Ask about the failure mode under concurrency, retries, or partial failure when the code touches shared state. The pitfall is reviewing only the diff lines while the interesting behavior lives in their interaction with existing code. Rule of thumb: approve only changes you could debug at three in the morning.$body$, $code$// review question applied to a change
BigDecimal total = items.stream()
    .map(Item::price)
    .reduce(BigDecimal.ZERO, BigDecimal::add);   // looks fine

// missing in review: empty list path, currency mixing,
// rounding policy, and who consumes the result$code$),
    ('code-review-for-maintainability', 2, 'Discipline the review scope', $body$A good review process separates blocking findings from preferences and keeps the diff small enough to inspect honestly. Ask for a PR that does one thing; a refactoring mixed with a behavior change makes comments ambiguous because a behavior difference may be intentional in one commit and a bug in another. Automate the mechanical: formatting, import order, and static analysis belong in tooling, not in human comments, so reviewers spend attention on design and risk. When you must review a monster change, request a split rather than skimming. The pitfall is marking style as blocking, which trains authors to argue instead of improve. Rule of thumb: humans review meaning, tools review mechanics.$body$, $code$// PR hygiene made explicit
// commit 1: refactor only   -> "rename + extract, no behavior change"
// commit 2: feature         -> "add overdue reminder, tests included"

// tooling handles the rest
// Spotless (formatting), Checkstyle (style), SpotBugs (defects)$code$),
    ('code-review-for-maintainability', 3, 'Feedback that is actionable', $body$Actionable feedback names the problem, its consequence, and at least one possible direction, ideally with a concrete example. A comment like "this is confusing" gives the author nowhere to go; "this condition also accepts refunds; I would split it into two checks" can be applied immediately. Distinguish questions from requests, phrase blocking concerns explicitly, and praise specific good decisions so they get repeated. When you are the author, respond to the intent of the comment rather than defending the line, and move disagreements that are actually about priorities to a decision forum. The pitfall is a review thread that debates style for a week. Rule of thumb: every blocking comment should be resolvable with a concrete edit.$body$, $code$// vague: "not clean, please rework"
// actionable:
// "orders can also be cancelled here, so refunds would be
//  retried as new orders. Split into two explicit branches."
if (status == PAID || status == CANCELLED) { retry(); }

// addressed:
if (status == PAID) { retryPayment(); }
if (status == CANCELLED) { retryRefund(); }$code$),
    ('eliminating-technical-debt-systematically', 1, 'A debt register that earns its keep', $body$Technical debt is a metaphor, not a category: it only describes work that slows future change. Keep a register of concrete items, each with the affected area, the evidence of impact, and a rough cost to fix. "Refactor the billing module" is not an item; "invoice search joins across three unindexed tables, average query 4s in production" is. Link every entry to something observable so it can be revalidated or closed, and review the register on a fixed cadence instead of only during planning emergencies. The pitfall is a register that grows without ever removing items, which soon becomes background noise nobody trusts. Rule of thumb: no entry without evidence, and no entry that cannot be deleted.$body$, $code$// debt item template
// id:       DEBT-142
// area:     invoice search API
// evidence: p95 4.1s over last 14 days, 3 support escalations
// interest: every search change risks missing the index hint
// fix:      add covering index, split query, estimate 2 days
// owner:    payments team, target: Q4

class InvoiceSearchRepository {
    List<Invoice> search(SearchCriteria criteria) { ... } // entry point cited above
}$code$),
    ('eliminating-technical-debt-systematically', 2, 'Prioritize by interest paid', $body$The interest rate on debt, not the size of the mess, should drive priority. Interest is what the debt costs every month: incidents caused, hours lost to workarounds, onboarding slowdown, or the price of every change in that area. Compute it from evidence you already have, such as incident reports, change-failure data, cycle time in the area, and support tickets, then order the register by cost avoided per unit of work. Some debt is cheap at any age because nothing changes it; leaving it alone is a deliberate, defensible choice. The pitfall is ranking by aesthetic offense. Rule of thumb: fix what taxes a team weekly, ignore what nobody touches.$body$, $code$// ranking inputs, not opinions
record DebtItem(String id, int incidents90d, double changeLeadTimeDays,
                int workaroundHours, int estimateDays) {
    double interestPerMonth() {
        return incidents90d * 100.0 + workaroundHours * 0.20;
    }
    double priority() {
        return interestPerMonth() / Math.max(1, estimateDays);
    }
}$code$),
    ('eliminating-technical-debt-systematically', 3, 'Boy-scout rules at team scale', $body$Leave it better than you found it does not scale as personal heroics; it scales as a budgeted rule. Teams get the best results by attaching a small, bounded cleanup to work they are already doing, such as improving tests near code they are changing, and by reserving a fixed slice of each iteration for debt items with evidence. Written rules make this predictable for planners: for example, every touch of a hotspot area must add or update one test, and every completed feature may include at most one bounded refactoring in the same area. The pitfall is an unbounded rule that becomes an excuse to wander through the codebase. Rule of thumb: improvement rides with change, but the scope is bounded by the change.$body$, $code$// team rules, small and checkable
// 1. touching an area with no tests: add one test first
// 2. cleaning up beyond the changed files: open a separate PR
// 3. iteration budget: one debt item from the register per sprint

// before: opportunistic cleanup inside a feature diff
// after:  cleanup PR linked to DEBT-142, feature PR stays focused$code$),
    ('dead-code-and-orphan-removal', 1, 'Detection before deletion', $body$Dead code accumulates in predictable shapes: unreachable branches, methods no caller references, classes from retried designs, and dependencies nothing compiles against. Tools find most of it: IDE inspections list unused members, `jdeps` reports unreachable JDK modules, and static analysis flags private methods and parameters with no use. None of them can see reflection, service loaders, serialization, or framework wiring by name, so every candidate needs a runtime check before removal. Version control preserves history, which removes the excuse to keep code as documentation. The pitfall is deleting a method that a framework calls reflectively. Rule of thumb: automated detection proposes, evidence decides.$body$, $code$// candidates from tooling, verified before deletion
// IDE: unused private methods list
// jdeps --multi-release 21 -summary app.jar
// runtime evidence: search logs, metrics, and traces

List<Order> orders = legacyOrderService.list(); // zero callers in code search
// confirm no reflective or config-driven usage, then delete with the tests$code$),
    ('dead-code-and-orphan-removal', 2, 'Retire feature flags completely', $body$A feature flag becomes permanent debt the moment its rollout finishes. Flags couple code paths through untested combinations: a boolean alive for two years doubles the paths someone must understand and test. Treat removal as part of the feature: after a flag has been at 100 percent for a stable period, delete the losing branch, remove the flag from configuration and dashboards, and delete the framework entry. When traffic telemetry shows zero invocations, deletion is mechanical. The pitfall is a flag left in a conditional that later reads stale configuration and silently changes behavior. Rule of thumb: every flag has an owner and an expiry date at creation time.$body$, $code$// before: flag alive long after its rollout
if (flags.enabled("new-pricing-engine")) {
    return newEngine.quote(cart);
} else {
    return oldEngine.quote(cart);
}

// after: delete the branch, the flag, and its config entry
return newEngine.quote(cart);$code$),
    ('dead-code-and-orphan-removal', 3, 'Delete in slices with telemetry', $body$Deletion is safest as a sequence of small, observable steps. First remove call sites; next make the candidate private or package-private and let the compiler prove nothing else uses it; then watch logs, metrics, and error tracking for references coming from scripts, admin calls, or another system; finally delete the code with its tests and configuration in one reviewable change. If the code might be called externally, add an explicit deprecation period with warnings, or make the call path a no-op that emits a counter so you can observe the last usage. The pitfall is a single enormous deletion commit that cannot be reviewed. Rule of thumb: shrink the surface, observe silence, then remove.$body$, $code$// staged deletion with observation between steps
// step 1: remove internal callers, grep the whole repo
ordersService.markLegacy(); // last caller deleted in this PR

// step 2: make it package-private so the compiler checks
// step 3: emit a signal for any remaining caller
logger.warn("legacy order path invoked");

// step 4: no traffic for 30 days -> delete method, tests, config$code$),
    ('documentation-that-survives', 1, 'Living docs next to the code', $body$Documentation rots when it lives away from the thing it describes, so the most durable docs are the ones the build keeps honest. Keep the run and build instructions in the repository, generate API references from source, and verify examples with doctest-style checks or executable snippets. Anything a test depends on cannot silently drift, while prose duplicated in a wiki can. Write for the reader who arrives at three in the morning: how to build, run, test, and check health, with current commands. The pitfall is a test plan or architecture page last edited two releases ago that nobody dares trust. Rule of thumb: if a document cannot fail a build, treat it as an obligation to revisit, not as truth.$body$, $code$// docs that cannot drift silently
// src/test/java/.../GettingStartedExample.java
@Test
void readmeExampleCompilesAndRuns() {
    var client = new AppClient("http://localhost:8080");
    assertEquals("ok", client.health().status());
}
// README links to this test; CI runs it on every change

# docker compose up -d && ./mvnw verify  # commands actually executed in CI$code$),
    ('documentation-that-survives', 2, 'ADRs as decision archaeology', $body$Architecture decision records preserve the why that code cannot express: the constraints of the moment, the options considered, and the consequences accepted. Write one per significant, hard-to-reverse decision, keep each record to a page, and store them with the code so they are reviewed and versioned like everything else. Supersede instead of editing: when a decision changes, write a new record that links back, leaving the original as an honest trace of past reasoning. The pitfall is recording only successes, which hides why obvious-looking alternatives were rejected. Rule of thumb: if a future engineer would ask why is it like this, the answer belongs in an ADR.$body$, $code$// docs/adr/0007-session-store.md
// # 7. Store sessions in Redis, not in-process
// Status: accepted (2026-03-04), supersedes ADR-0003
// Context:  2 instances behind a load balancer, sticky sessions
//           broke rolling deploys
// Decision: external session store with 30m TTL
// Consequences: one more dependency on the critical path;
//           in-process sessions removed entirely$code$),
    ('documentation-that-survives', 3, 'README-first onboarding that works', $body$The README is the front door and the document readers hit in their first hour, so it should be an executable path rather than a description of the system. Cover: what this service is responsible for, how to run it locally, how to run the tests, how to reach the team, and where deeper docs live. Keep the first screen small; a new joiner should reach a running system with three commands and no tribal knowledge. Treat the first-week questions asked by every new engineer as bugs in the README and fix them at the source. The pitfall is a README that describes an architecture diagram from two years ago. Rule of thumb: a new engineer should be productive on day one without asking where to start.$body$, $code$// README skeleton that answers first-hour questions
// # billing-service
// What: owns invoices, tax, and dunning for EU tenants
// Run: docker compose up -d && ./mvnw spring-boot:run
// Test: ./mvnw verify
// Team: #team-payments, on-call via PagerDuty policy payments
// Deeper docs: docs/adr/, docs/runbooks/

// verify the README on a clean checkout each release$code$),
    ('refactoring-data-and-schemas', 1, 'Code first or data first', $body$Schema refactorings have a sequencing question that code refactorings do not: which side moves first? The safe default is expand-then-contract. Add the new column or table without removing anything, deploy code that writes both representations and reads the new one with a fallback, then remove the old path only after the migration is complete and verified. Reading old and new in parallel lets you compare and correct discrepancies while rollback is still possible. The pitfall is renaming a column in one deployment: the old application version cannot write to a column that no longer exists. Rule of thumb: make the database model a superset of what either code version needs until no old version runs.$body$, $code$// expand: add new column, keep the old one
ALTER TABLE invoice ADD COLUMN due_date DATE;

// application writes both, reads new with fallback
void save(Invoice invoice) {
    jdbc.update("UPDATE invoice SET due_date=?, due=? WHERE id=?",
        invoice.dueDate(), invoice.due(), invoice.id());
}

// contract only after old code is gone and backfill verified$code$),
    ('refactoring-data-and-schemas', 2, 'Backfills that can be verified', $body$A backfill is a deployment with state, so it needs the same discipline: idempotent, restartable, observable, and rate-limited. Process in keyset-ordered batches rather than one unbounded update, log progress, and be able to resume without recomputing finished work. Decide whether the backfill runs as a migration, a startup task, or a standalone job; for large tables the standalone, throttled job is usually correct because it does not block deploys. Verification belongs in the plan: row counts, checksums, or sampling compared against the source of truth. The pitfall is a backfill that locks a large table or silently stalls halfway. Rule of thumb: every backfill must be safe to run twice and safe to stop.$body$, $code$// idempotent, ordered, batched backfill
UPDATE invoice
SET due_date = due::date
WHERE id > :lastId AND due_date IS NULL
ORDER BY id
LIMIT 5000;

// repeat until zero rows updated; log lastId each round,
// then verify: counts match and no NULL due_date remains$code$),
    ('refactoring-data-and-schemas', 3, 'Plan the rollback before the change', $body$Every data refactoring ships with a rollback plan written before the first statement runs, because reverse scripts are the hardest part to improvise during an incident. Keep the old path intact until verification proves the new one correct, and store the evidence required to decide: backfill completion, dual-read comparison results, error rates. For destructive steps, decide in advance whether old writes are kept for a defined window, and name the person who can approve the irreversible step. The pitfall is discovering days later that the old code path cannot be restored because its columns were dropped. Rule of thumb: if you cannot describe the rollback in one paragraph, the change is not ready to deploy.$body$, $code$// rollback plan kept with the migration
// phase 1: column added, both paths live   -> rollback: drop new column
// phase 2: backfill running               -> rollback: stop job, old path serves
// phase 3: switch reads to new column     -> rollback: flip read flag back
// phase 4: drop old column                -> irreversible: requires approval
//                                         by data owner after 30-day soak

// before starting phase 4, confirm: zero errors for 30 days,
// backfill audit clean, no old version deployed$code$)
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
    'refactoring-safely', 'naming-and-readability', 'extracting-methods-and-classes',
    'replacing-conditional-logic', 'removing-duplication-carefully', 'working-with-legacy-code',
    'approval-testing-legacy-behavior', 'breaking-dependencies-in-legacy',
    'incremental-framework-upgrades', 'modularizing-a-monolith',
    'code-review-for-maintainability', 'eliminating-technical-debt-systematically',
    'dead-code-and-orphan-removal', 'documentation-that-survives',
    'refactoring-data-and-schemas'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
