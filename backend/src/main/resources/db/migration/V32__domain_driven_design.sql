-- V32 — Domain-driven design.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('ubiquitous-language-in-code', 'Ubiquitous Language in Code', 'Name domain concepts the way business experts do, and keep that vocabulary consistent as the model evolves.', 'Junior', 22, true, 1),
    ('strategic-domain-analysis', 'Strategic Domain Analysis', 'Separate the core domain from supporting and generic subdomains so that modeling effort follows competitive advantage.', 'Mid', 32, true, 1),
    ('bounded-contexts-in-practice', 'Bounded Contexts in Practice', 'Draw explicit model boundaries where the language changes, and define how neighboring contexts relate to each other.', 'Senior', 38, true, 1),
    ('context-mapping-patterns', 'Context Mapping Patterns', 'Choose integration relationships such as shared kernel, conformist, or anticorruption layer based on dependency direction and team power.', 'Senior', 40, true, 1),
    ('entities-and-identity', 'Entities and Identity', 'Give domain objects an identity that survives attribute changes, and define equality rules that match business meaning.', 'Junior', 24, true, 1),
    ('value-objects-modeling', 'Modeling with Value Objects', 'Represent immutable, self-validating concepts such as money and quantities instead of passing raw primitives around.', 'Junior', 26, true, 1),
    ('aggregates-and-consistency-boundaries', 'Aggregates and Consistency Boundaries', 'Group objects that must stay consistent together behind one root, and keep each transaction inside a single aggregate.', 'Mid', 34, true, 1),
    ('domain-services', 'Domain Services in Practice', 'Place business rules that span several objects in explicit stateless services while keeping entities behaviorally rich.', 'Mid', 30, true, 1),
    ('domain-events-in-the-model', 'Domain Events in the Model', 'Record past-tense facts raised by the model and publish them only after the database transaction commits.', 'Mid', 32, true, 1),
    ('repositories-as-domain-abstractions', 'Repositories as Domain Abstractions', 'Expose collection-like interfaces that speak the domain language instead of leaking persistence and query details.', 'Mid', 30, true, 1),
    ('factories-and-builders-in-domain-code', 'Factories and Builders for Domain Creation', 'Encapsulate complex creation rules in factories and builders so no caller can assemble an invalid domain object.', 'Mid', 28, true, 1),
    ('anemic-model-anti-pattern', 'The Anemic Model Anti-Pattern', 'Recognize the anemic model, see where its logic actually lives, and know when a plain CRUD design is genuinely fine.', 'Mid', 28, true, 1),
    ('hexagonal-architecture-and-ddd', 'Hexagonal Architecture and DDD', 'Wrap the domain in ports and adapters so dependencies point inward and the model stays testable in isolation.', 'Senior', 38, true, 1),
    ('ddd-and-relational-mapping', 'DDD and Relational Mapping', 'Map aggregates to relational tables deliberately, accepting limited denormalization where the two models disagree.', 'Senior', 36, true, 1),
    ('event-storming-to-code', 'From Event Storming to Code', 'Turn workshop artifacts into bounded contexts and aggregates while letting the model keep evolving afterwards.', 'Mid', 34, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('ubiquitous-language-in-code', 1, 'Name the domain in the code', $body$Software that names things OrderProcessor, DataRecord, or Manager forces every reader to translate between the code and the business conversation. A ubiquitous language means the model uses the same terms domain experts use: not a synonym, not a technical wrapper. When a shipping clerk says consignment and the code says shipment batch, every meeting becomes a mapping exercise and defects hide in the translation. Keep a short glossary of agreed terms, use those terms in packages, classes, methods, and tests, and rename when understanding changes. Rule of thumb: if a domain expert cannot read a class diagram and recognize their business, the vocabulary has drifted.$body$, $code$public record Consignment(ConsignmentId id, Route route,
                          List<Parcel> parcels) {
    public Consignment {
        parcels = List.copyOf(parcels);
        if (parcels.isEmpty()) {
            throw new IllegalArgumentException("consignment needs parcels");
        }
    }
}$code$),
    ('ubiquitous-language-in-code', 2, 'Keep vocabulary out of translation layers', $body$A common failure is having a rich business vocabulary in conversations but generic names in code, connected by a translation layer of DTOs and mappers. That layer multiplies work: every new term is named twice and mapped twice, and the mapping code becomes the only place where meaning lives. Prefer one term per concept within a bounded context, and use the same word from database column to class to API field wherever possible. Technical layers should transform data, not rename the domain. Where a term genuinely differs between contexts, treat it as a boundary signal rather than something to smooth over with a mapper. Rule of thumb: a mapper that only renames fields is a modeling smell.$body$, $code$public record ConsignmentView(String consignmentId, String routeCode,
                              int parcelCount) {
    static ConsignmentView from(Consignment consignment) {
        return new ConsignmentView(consignment.id().value(),
            consignment.route().code(), consignment.parcels().size());
    }
}$code$),
    ('ubiquitous-language-in-code', 3, 'Let the language evolve', $body$A ubiquitous language is not frozen in a document written at project kickoff. It is tested in conversation and adjusted when experts disagree or edge cases appear, and the code should follow quickly. Keep the glossary next to the model, and treat unplanned synonyms as small defects to fix with a rename, not debts to defer. Renaming a concept across a codebase is cheapest while usage is small and tests protect behavior. When developers and experts stop correcting each other, the vocabulary has either matured or quietly stopped being used. Rule of thumb: schedule a deliberate vocabulary review whenever a feature introduces unfamiliar nouns or verbs.$body$, $code$@Test
void consignmentNeedsAtLeastOneParcel() {
    assertThatThrownBy(() -> Consignments.of(id, route, List.of()))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("parcels");
}$code$),
    ('strategic-domain-analysis', 1, 'Separate core, supporting, generic', $body$Not every part of a business deserves the same modeling effort. The core domain is where the organization competes and differentiates; supporting subdomains are necessary and specific but not a source of advantage; generic subdomains are solved problems such as authentication, notifications, or file storage, where reuse or buying beats building. Classify each area explicitly with business stakeholders, then aim your best modelers and design energy at the core. Treat the classification as a living investment map, because subdomains move as strategy changes. Rule of thumb: if outsourcing a capability would not weaken the product, do not spend your deepest design attention on it.$body$, $code$public enum SubdomainKind { CORE, SUPPORTING, GENERIC }

public record Subdomain(SubdomainKind kind, String name,
                        String differentiationReason) {
    public boolean deservesDeepModeling() {
        return kind == SubdomainKind.CORE;
    }
}$code$),
    ('strategic-domain-analysis', 2, 'Invest effort where differentiation lives', $body$Deep modeling has a cost: workshops, refactoring, tests, and slower early delivery. Spend it where the domain is complex and the business gains from precision, such as pricing, allocation, or risk rules. In generic areas, prefer simple CRUD or a purchased tool behind a thin adapter; in supporting areas, model only enough to keep the core clean and resist gold-plating. A frequent inversion of the pattern is heroic modeling in reporting screens while the differentiating rules stay buried in stored procedures. Rule of thumb: write down why each subdomain received the depth it did, and revisit that claim when priorities move.$body$, $code$public record VolumeDiscount(int minQuantity, BigDecimal rate)
        implements DiscountPolicy {
    @Override
    public Money applyTo(Money listPrice, int quantity) {
        if (quantity < minQuantity) {
            return listPrice;
        }
        return listPrice.minus(listPrice.times(rate));
    }
}$code$),
    ('strategic-domain-analysis', 3, 'Watch for accidental complexity', $body$Core domains attract accidental complexity: frameworks, abstractions, and infrastructure that look sophisticated but add nothing to the business rules. Keep the core model small and directly expressive, and push persistence, messaging, and serialization concerns to the edges. The reverse failure is just as common, where a genuinely core capability hides behind a generic label such as admin panel and never receives proper design attention. Distinguish essential complexity, which comes from the business problem, from accidental complexity, which comes from your tools and choices. Rule of thumb: if removing a technical layer would leave the business rules untouched, that layer is a candidate for simplification.$body$, $code$public record CreditLimit(Money amount) {
    public boolean allows(Money requested, Money alreadyReserved) {
        return alreadyReserved.plus(requested).isAtMost(amount);
    }
}$code$),
    ('bounded-contexts-in-practice', 1, 'Draw boundaries where language changes', $body$A bounded context is the territory in which one model and one vocabulary stay internally consistent. The practical trigger for drawing a boundary is linguistic: when the same word means different things to different groups, or one group needs incompatible models of a single concept, a boundary is justified. In a utility, meter can mean a physical device, a service point, or a billing relationship; one class serving all three produces conditionals everywhere. Boundaries are also social, because a context usually aligns with a team that owns its model. Rule of thumb: define the context first, then let the model and schema follow inside it, and never share a class across the boundary casually.$body$, $code$// Billing context: a meter is a billing relationship.
public record BillingMeter(MeterId id, TariffId tariff,
                           LocalDate activeFrom) { }

// Field operations context: a meter is a physical device.
public record MeterDevice(DeviceSerial serial, GeoLocation location) { }$code$),
    ('bounded-contexts-in-practice', 2, 'Make boundaries explicit in code', $body$A boundary that exists only in a diagram decays quickly. Make it visible in the repository: separate modules, packages, or services per context, with no direct object references crossing the line. Cross-context communication goes through explicit contracts, such as published events or dedicated facades, not through shared entity classes. Enforce the boundary with architecture tests so a convenient import cannot silently couple the contexts. Also make ownership explicit: one context owns each piece of data, and other contexts hold references or copies, not authority. Rule of thumb: if two contexts must change in lockstep for every release, the boundary is probably drawn in the wrong place.$body$, $code$// Each context exposes a narrow facade; no entities cross the line.
public interface BillingFacade {
    InvoiceId openInvoice(CustomerRef customer, BillingPeriod period);
}

public record CustomerRef(String externalId) { }$code$),
    ('bounded-contexts-in-practice', 3, 'Map relationships between contexts', $body$Contexts do not live alone; the hard design work is in their relationships. For each pair, decide who depends on whom, who dictates the language, and how changes propagate. Record this on a context map that names every context and every integration edge, including upstream and downstream direction. The map is a communication tool for teams, not only an architecture artifact; it exposes costly couplings, such as many teams conforming to one slow model. Revisit it after reorganizations, because team dynamics often reveal where a boundary should move. Rule of thumb: every integration edge should have a named pattern, an owner, and a contract, otherwise it is accidental coupling.$body$, $code$public record Integration(ContextName upstream, ContextName downstream,
                          Pattern pattern) {
    public Integration {
        if (upstream.equals(downstream)) {
            throw new IllegalArgumentException("contexts must differ");
        }
    }
    public enum Pattern { SHARED_KERNEL, CUSTOMER_SUPPLIER, CONFORMIST,
                          ANTICORRUPTION_LAYER }
}$code$),
    ('context-mapping-patterns', 1, 'Shared kernel and customer-supplier', $body$A shared kernel is a small, explicitly shared subset of the model that two teams co-own; because changes require coordination, keep it genuinely small and version it carefully. Customer-supplier is a directed relationship in which an upstream team commits to serving downstream needs and negotiates change timing; it works when the upstream team is responsive. Both patterns trade autonomy for integration. A shared kernel buys consistency but couples release cycles, while customer-supplier preserves ownership but demands real planning capacity. Choose them when the teams are aligned and the coupling is worth maintaining. Rule of thumb: shared code that nobody plans to maintain together is a shared kernel in name only.$body$, $code$// Shared kernel: a tiny co-owned vocabulary both teams compile against.
public record Money(BigDecimal amount, Currency currency) {
    public Money {
        amount = amount.setScale(2, RoundingMode.HALF_EVEN);
    }
}$code$),
    ('context-mapping-patterns', 2, 'Conformist and anticorruption layer', $body$A conformist follows the upstream model exactly, adopting its terms and structures without translation. That is cheap but imports the upstream design decisions and its rate of change. An anticorruption layer instead translates at the boundary, protecting your model from foreign concepts and letting you evolve independently. Reach for conformist when the upstream model is good enough and the integration is peripheral; pay for an anticorruption layer when the upstream model conflicts with yours or changes unpredictably. Both patterns assume the upstream is not changing for you. Rule of thumb: count how many upstream fields you actually consume before deciding how much translation you need.$body$, $code$// Anticorruption layer: the foreign shipping model stops here.
public Parcel toDomain(ShippingApi.Shipment dto) {
    return new Parcel(new ParcelId(dto.trackingCode),
        new Weight(dto.grams), Address.of(dto.destination));
}$code$),
    ('context-mapping-patterns', 3, 'Open host service and published language', $body$When many consumers integrate with one context, exposing a bespoke interface per consumer does not scale. An open host service provides one documented, stable protocol for all consumers, and a published language defines the shared interchange format behind it, such as a schema or well-known events. Together they reduce integration cost but create a product-like public contract: it needs versioning, documentation, and compatibility discipline. This differs from improvised endpoints because the protocol is designed as a long-lived, shared boundary, not an accident of the first client. Rule of thumb: if three or more contexts call you, design one decent interface instead of three private ones.$body$, $code$public interface BillingOpenHost {
    // One documented contract for every consumer context.
    InvoiceSummary findInvoice(InvoiceId id);
    List<InvoiceSummary> invoicesFor(CustomerRef customer,
                                     BillingPeriod period);
}$code$),
    ('entities-and-identity', 1, 'Identity that survives change', $body$An entity is a domain object defined by continuity rather than by its current attributes. A customer who changes address, name, or phone number is still the same customer; identity is what stays stable while everything else evolves. Model that identity explicitly, usually as a typed identifier, and pass identity between objects rather than loose strings or whole aggregates. Stability matters in production because external references, audit trails, and user mental models all depend on it. Rule of thumb: ask what must remain the same object across its whole lifecycle; if the answer is nothing, you may want a value object instead.$body$, $code$public final class Customer {
    private final CustomerId id;
    private String displayName;

    public Customer(CustomerId id, String displayName) {
        this.id = Objects.requireNonNull(id);
        this.displayName = displayName;
    }

    public boolean sameIdentityAs(Customer other) {
        return id.equals(other.id);
    }
}$code$),
    ('entities-and-identity', 2, 'Equality rules for entities', $body$Entities should compare equal only when their identities match, never because their attributes happen to coincide. Two orders with identical lines and totals are still different orders. Implement equality on the identity field and keep hashing consistent so entities behave correctly inside sets and maps. Be careful during creation, before an identifier is assigned, and with frameworks that may load the same entity twice in one session. Comparing database identity as a fallback is pragmatic, but it must be a deliberate decision, not an accident. Rule of thumb: if business code relies on entity equality for anything beyond identity, revisit the design.$body$, $code$@Override
public boolean equals(Object other) {
    return other instanceof Customer customer
        && id.equals(customer.id);
}

@Override
public int hashCode() {
    return id.hashCode();
}$code$),
    ('entities-and-identity', 3, 'Generated and natural identifiers', $body$Choose identifiers based on where they come from. Generated identifiers, such as UUIDs or sequences, are reliable and decoupled from business change, but they carry no meaning and cannot fix a bad entry. Natural identifiers, such as a tax number or an IBAN, are meaningful to users but can be corrected or reassigned, and they tie the model to an external authority. Prefer opaque generated keys inside the model, and store natural identifiers as validated attributes. For integration, publish a stable external reference rather than an internal database key. Rule of thumb: never let a natural key be the identity you cannot change.$body$, $code$public record CustomerId(UUID value) {
    public static CustomerId newId() {
        return new CustomerId(UUID.randomUUID());
    }
}

public record TaxNumber(String value) {
    public TaxNumber {
        if (!value.matches("\\d{9}")) {
            throw new IllegalArgumentException("tax number");
        }
    }
}$code$),
    ('value-objects-modeling', 1, 'Immutability and equality by value', $body$A value object has no identity: it is defined entirely by its attributes, and two instances with the same attributes are interchangeable. Money, date ranges, coordinates, and color codes are typical examples. Make value objects immutable. Provide no setters, never expose mutable collections, and let operations return new instances instead of modifying state. Equality and hashing then follow attribute values rather than references. Immutability removes a whole class of concurrency bugs and makes sharing, caching, and reuse safe, because nobody can change a shared value behind your back. Rule of thumb: if changing one attribute turns an object into a different concept, it is a value object, not an entity.$body$, $code$public record Money(BigDecimal amount, Currency currency) {
    public Money {
        Objects.requireNonNull(amount);
        Objects.requireNonNull(currency);
    }

    public Money plus(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalArgumentException("currency mismatch");
        }
        return new Money(amount.add(other.amount), currency);
    }
}$code$),
    ('value-objects-modeling', 2, 'Validate inside the constructor', $body$A value object should never exist in an invalid state, so validation belongs at construction, not in scattered call sites. A zero denominator, a negative weight, or a currency mismatch should fail immediately with a clear message, close to where the invalid value enters the system. Prefer a named factory when construction has several variants, and keep the canonical constructor public only when direct construction is genuinely safe. This concentrates rules in one place and lets every other line of code assume correctness. Rule of thumb: if you ever write a check right after calling a constructor, that check probably belongs inside the type.$body$, $code$public record Percentage(BigDecimal value) {
    public Percentage {
        Objects.requireNonNull(value);
        if (value.signum() < 0 || value.compareTo(BigDecimal.ONE) > 0) {
            throw new IllegalArgumentException("percentage out of range");
        }
    }
}$code$),
    ('value-objects-modeling', 3, 'Records and primitive obsession', $body$Java records make concise value objects: they provide final fields, accessors, equals, hashCode, and toString without boilerplate. Use the compact constructor for validation and defensive copies, because a record is only shallowly immutable and a list field can otherwise still be mutated from outside. Primitive obsession is the counter-pattern: string statuses, bare double amounts, and long identifiers passed freely, so invalid values circulate and checks are forgotten. Wrap such primitives in small domain types with their own rules, and the compiler starts doing part of the reviewing. Rule of thumb: convert a primitive to a type as soon as it carries rules, units, or a business name.$body$, $code$public record Route(List<Stop> stops) {
    public Route {
        if (stops.size() < 2) {
            throw new IllegalArgumentException("route needs two stops");
        }
        stops = List.copyOf(stops);
    }
}$code$),
    ('aggregates-and-consistency-boundaries', 1, 'One root protects the invariants', $body$An aggregate is a cluster of objects that must stay consistent together, with one entity as the root and the only entry point. Outside code holds references to the root only, and internal objects are reachable through it, so every invariant, such as a total matching its lines, is enforced in a single place. The root decides which operations are legal and turns one method call into consistent changes across the cluster. Choose boundaries by consistency requirements, not by convenient navigation between objects. Rule of thumb: if two objects must always be updated together for the data to be correct, they probably belong to the same aggregate.$body$, $code$public final class Order {
    private final OrderId id;
    private final List<OrderLine> lines = new ArrayList<>();

    public void addLine(ProductId product, int quantity, Money unitPrice) {
        if (lines.size() >= 100) {
            throw new IllegalStateException("line limit reached");
        }
        lines.add(new OrderLine(product, quantity, unitPrice));
    }

    public List<OrderLine> lines() {
        return List.copyOf(lines);
    }
}$code$),
    ('aggregates-and-consistency-boundaries', 2, 'One transaction per aggregate', $body$Classic DDD guidance is that a transaction should modify one aggregate instance. If an operation must change two aggregates atomically, that need is a signal to reconsider the boundary or to coordinate through eventual consistency, updating the second aggregate in a separate transaction after an event. The constraint keeps locking paths short and avoids distributed transactions. Load and save aggregates as a whole through repositories, and align database transactions with aggregate instances. Rule of thumb: when you find yourself wrapping two repositories in one transaction, ask whether the two sides are really one aggregate or whether compensation between them is acceptable.$body$, $code$@Transactional
public void placeOrder(PlaceOrder command) {
    Order order = orders.byId(command.orderId())
        .orElseThrow(() -> new OrderNotFound(command.orderId()));
    order.place();
    orders.save(order);
    // Inventory changes happen later, in their own transaction.
}$code$),
    ('aggregates-and-consistency-boundaries', 3, 'Why giant aggregates fail', $body$Large aggregates, such as a customer that owns every order, feel convenient at first and scale badly. Every write locks and reloads far more data than the invariant needs, concurrent operations on unrelated children conflict, and the graph grows until nobody understands it. Giant aggregates also fail on distribution, where one instance cannot be updated from two services at once. Split by invariants: when two parts do not need immediate consistency, separate aggregates can reference each other by identity, and rules spanning them move to domain services or events. Rule of thumb: if an aggregate has more than a few child entities, justify each one by the invariant it protects.$body$, $code$public record Order(OrderId id, CustomerId customerId,
                    List<OrderLine> lines) {
    // Customer is a separate aggregate; hold identity, not the object.
    public Order {
        lines = List.copyOf(lines);
    }
}$code$),
    ('domain-services', 1, 'Behavior that fits no entity', $body$Some domain rules involve several entities and do not naturally belong to any one of them: transferring funds between accounts, matching a payment to invoices, or pricing a cart against a contract. A domain service expresses such a rule as a stateless operation with a business name, using domain types and repositories. Forcing the rule into one entity creates artificial ownership, while placing it in an application service mixes orchestration with business knowledge. The classic canon describes these as significant process-level behaviors that do not sit naturally on a single object. Rule of thumb: reach for a domain service only after the rule genuinely refuses to live in an entity or value object.$body$, $code$public final class FundsTransfer {
    private final AccountRepository accounts;

    public FundsTransfer(AccountRepository accounts) {
        this.accounts = accounts;
    }

    public void transfer(AccountId fromId, AccountId toId, Money amount) {
        Account from = accounts.get(fromId);
        Account to = accounts.get(toId);
        from.withdraw(amount);
        to.deposit(amount);
    }
}$code$),
    ('domain-services', 2, 'Keep services thin and models rich', $body$A domain service should coordinate domain objects, not accumulate conditionals that belong inside them. When a service starts reading and mutating entity internals, the logic probably wants to move behind an entity method the service calls. Keep services stateless, free of persistence and transport concerns, and small enough to read in one sitting. Naming them after the business operation, such as FundsTransfer or InvoiceMatching, keeps the vocabulary honest and makes review easier. Distinguish domain services from application services, which load aggregates, check authorization, and manage transactions. Rule of thumb: if deleting a service would leave the business rules intact, it was orchestration rather than a domain service.$body$, $code$// Entity owns the rule; the service only coordinates.
public void close(AccountId id) {
    Account account = accounts.get(id);
    account.close();   // balance and status checks live in Account
}$code$),
    ('domain-services', 3, 'Watch for the procedural slide', $body$The classic literature warns that teams often give up too quickly on finding the right object and slide toward procedural programming: behavior moves out of entities into services until the model becomes a data bag. The symptom is a service whose methods mirror entity setters and contain nested conditionals touching many fields. Treat each new service method as a question: which object is being protected, and who should own this rule? Sometimes the answer really is a service; more often it is a method on the aggregate root or a value object that carries the decision. Rule of thumb: periodically review services for logic that could move back into the model.$body$, $code$// Application service: loads, authorizes, delegates, commits.
@Transactional
public InvoiceId matchPayment(MatchPayment command) {
    Payment payment = payments.get(command.paymentId());
    return invoiceMatching.match(payment, command.invoiceIds());
}$code$),
    ('domain-events-in-the-model', 1, 'Past-tense facts from the model', $body$A domain event records something meaningful that happened in the domain, named as a fact in the past tense: OrderPlaced, PaymentMatched, SeatReserved. The aggregate raises events as a side effect of its business methods, which keeps the record close to the state change that caused it instead of relying on an integration layer to infer what changed. Events carry the identifiers and data consumers need, and they should be immutable. Treat them as part of the domain language, not as transport messages; how they travel is a separate design decision. Rule of thumb: if an event name describes intent or a future action, it is a command wearing the wrong label.$body$, $code$public record OrderPlaced(OrderId orderId, CustomerId customerId,
                          Money total, Instant occurredAt) {
    public OrderPlaced {
        Objects.requireNonNull(orderId);
        Objects.requireNonNull(total);
        Objects.requireNonNull(occurredAt);
    }
}$code$),
    ('domain-events-in-the-model', 2, 'Publish only after commit', $body$Events raised inside a transaction must not be visible outside until the state change is durable. Publishing during the transaction can announce an order that a rollback later erases. Collect events in the aggregate and hand them to a publisher after the transaction commits, whether through an after-commit hook or by writing them to an outbox table in the same transaction and relaying afterwards. Consumers must also tolerate duplicates, because delivery is usually at least once. Rule of thumb: no external observer should learn about a change before the database that stores it agrees.$body$, $code$public void place() {
    if (lines.isEmpty()) {
        throw new IllegalStateException("order has no lines");
    }
    this.status = Status.PLACED;
    this.events.add(new OrderPlaced(id, customerId, total(), clock.instant()));
}
// After commit: publisher.dispatch(order.pullEvents());$code$),
    ('domain-events-in-the-model', 3, 'Design events for consumers', $body$An event is a contract. Include enough data for the common consumer to act without calling back, but avoid leaking the entire aggregate, which would couple consumers to internal structure. Keep events small, self-contained, and versioned; add fields rather than repurposing them, and prefer factual names such as SeatReserved over vague ones such as SeatUpdated. Distinguish internal events, used inside one context, from integration events that cross a boundary, where backward compatibility matters more. Rule of thumb: sketch the consumer on paper before finalizing the payload, and let its needs shape which fields travel.$body$, $code$public record SeatReserved(ReservationId reservationId,
                           ScreeningId screeningId,
                           SeatNumber seat,
                           Instant occurredAt) {
    public static final int VERSION = 1;
}$code$),
    ('repositories-as-domain-abstractions', 1, 'Interfaces that behave like collections', $body$A repository presents an aggregate collection to the domain: add an object, remove it, find it by identity. The interface is written in domain terms, and its implementation hides the database, mappers, and queries. Callers should never see sessions, entity managers, result sets, or SQL; if persistence idioms appear on the interface, the abstraction leaks and the model starts depending on infrastructure. Repositories exist so business rules can be tested and reasoned about without a database, and so storage choices remain replaceable. Rule of thumb: an interface method should read like something a domain expert could nod at, not like something a DBA would write.$body$, $code$public interface OrderRepository {
    Optional<Order> byId(OrderId id);
    void save(Order order);
    void remove(OrderId id);
}$code$),
    ('repositories-as-domain-abstractions', 2, 'Query methods that speak the domain', $body$Finders should express domain intent, not schema shape: findOverdueInvoices(CustomerId) or nextUnshippedOrders(Instant cutoff), rather than findByStatusAndCreatedAtLessThan. A pile of generic criteria methods pushes query logic into callers and quietly recreates a DAO. Where many combinations are truly needed, a specification type can express a rule the domain understands while the implementation translates it into queries. Keep each method named for the business question it answers, and return domain types rather than rows or maps. Rule of thumb: if a query name needs its parameters explained to a domain expert, the method is too low-level for the repository.$body$, $code$public interface InvoiceRepository {
    Optional<Invoice> byId(InvoiceId id);
    List<Invoice> overdueFor(CustomerId customer, LocalDate asOf);
    List<Invoice> awaitingPayment(int limit);
}$code$),
    ('repositories-as-domain-abstractions', 3, 'One repository per aggregate root', $body$Repositories exist for aggregate roots, not for every table. Internal entities are loaded and saved through their root, which protects invariants and keeps the persistence interface small. Avoid returning graphs that mix several aggregates, and avoid navigating lazily from one aggregate into another; look up the other aggregate explicitly when a use case needs it. This aligns naturally with one transaction per aggregate, because a repository fetches and stores exactly one consistency boundary. Rule of thumb: if a repository method returns objects from two aggregates in one call, ask what consistency the caller is really trying to obtain.$body$, $code$// Order is a root; OrderLine is loaded and stored through it.
Order order = orders.byId(orderId)
    .orElseThrow(() -> new OrderNotFound(orderId));
order.addLine(productId, quantity);
orders.save(order);$code$),
    ('factories-and-builders-in-domain-code', 1, 'Give creation rules a home', $body$When creating a valid object requires several steps, cross-field rules, or lookups of other objects, a bare constructor invites callers to assemble state partially or wrongly. A factory puts that knowledge in one place: it gathers inputs, validates the combination, and returns a complete object. Factories are especially valuable when creation involves choosing a subtype or applying defaults that are not properties of the type itself. Keep the factory close to the model and name it after the domain process, such as opening an account or scheduling a shipment. Rule of thumb: if two callers construct the same object differently, the creation rules belong in a factory.$body$, $code$public final class AccountFactory {
    public static Account open(Customer customer, Money initialDeposit,
                               OverdraftPolicy policy) {
        if (initialDeposit.isNegative()) {
            throw new IllegalArgumentException("deposit must be positive");
        }
        return new Account(AccountId.newId(), customer.id(),
                           initialDeposit, policy);
    }
}$code$),
    ('factories-and-builders-in-domain-code', 2, 'Protect invariants during creation', $body$A factory should be the narrow gate through which valid instances enter the system. Reconstructing an object from storage is a different concern: it must not re-apply business rules that may have changed since the data was written, so many teams keep a separate reconstitution path alongside the creating factory. Also beware factories that become god objects knowing how to build everything; when one factory grows branches for unrelated variants, the type probably carries too much responsibility. Rule of thumb: validate on creation, trust on reconstitution, and never let callers assemble an aggregate piece by piece.$body$, $code$static Account reconstitute(AccountId id, CustomerId owner,
                            Money balance, AccountStatus status) {
    // Storage path: trust persisted facts, do not replay creation rules.
    return new Account(id, owner, balance, status);
}$code$),
    ('factories-and-builders-in-domain-code', 3, 'Builders are convenience, not modeling', $body$Builders make construction with many optional parts readable, especially in tests and configuration code, and a build method can still validate before returning. They are not a substitute for modeling. If every field has a setter and the builder merely collects values, you have recreated a mutable object with extra steps, and invalid combinations surface late. Prefer builders for genuinely optional combinations, and static factory methods with domain names when the variants are few and meaningful. Rule of thumb: if a builder mirrors the fields one to one and nothing is optional, a constructor or factory communicates the intent more clearly.$body$, $code$public CustomerBuilder allow(Channel channel) {
    channels.add(channel);
    return this;
}

public Customer build() {
    if (channels.isEmpty()) {
        throw new IllegalStateException("at least one channel");
    }
    return new Customer(Set.copyOf(channels));
}$code$),
    ('anemic-model-anti-pattern', 1, 'Where the logic actually lives', $body$An anemic model has domain objects that are mostly getters and setters while services hold the rules. It looks like a real model because the classes carry domain names and relationships, but the behavior lives in procedural service methods that read and write object state, so encapsulation is nominal. The costs are concrete: invariants can be violated between calls, rules get duplicated across services, and every change ripples through the code that touches the object. Recognizing the pattern early matters because it usually starts as a shortcut and hardens into an architecture. Rule of thumb: if services contain the business decisions and entities only hold data, you have transaction scripts with domain-sounding names.$body$, $code$// Anemic: a data holder plus a service that owns the rule.
public class Account {
    private Money balance;
    public Money getBalance() { return balance; }
    public void setBalance(Money balance) { this.balance = balance; }
}$code$),
    ('anemic-model-anti-pattern', 2, 'Costs and how anemia grows', $body$Anemia usually begins with one service doing legitimate orchestration, then gradually absorbing calculations, validations, and lifecycle rules. Because the data objects have no guard rails, every reader must know which fields are trustworthy at which moment, and different services enforce different versions of the same rule. Testing drifts toward large service tests with many mocks, and the model becomes harder to understand than the code it replaced. The remedy is incremental: move one rule at a time behind a method on the object that owns the data, starting with rules that must never be violated. Rule of thumb: follow the conditionals; whichever object they protect should own them.$body$, $code$// Caller decides whether the withdrawal is legal.
if (account.getBalance().isAtLeast(amount)) {
    account.setBalance(account.getBalance().minus(amount));
}

// Better: the object enforces its own invariant.
account.withdraw(amount);$code$),
    ('anemic-model-anti-pattern', 3, 'When anemic is pragmatic', $body$Not every system needs a behavioral domain model. A CRUD application that mostly stores form data, integrates with a few systems, and enforces simple validations can be built honestly with a thin service layer and plain data holders; forcing rich model patterns there adds ceremony without benefit. Fowler points out that domain models are not always the best tool. The important thing is to choose deliberately and record the choice, rather than drifting into anemia while claiming to practice DDD. Revisit the decision when business rules start multiplying. Rule of thumb: match modeling depth to rule complexity, and never let the anemic choice be accidental.$body$, $code$// CRUD with no invariants: a thin service is honest here.
@Service
public class ContactService {
    public Contact updateEmail(ContactId id, Email email) {
        Contact contact = repository.get(id);
        contact.setEmail(email);
        return repository.save(contact);
    }
}$code$),
    ('hexagonal-architecture-and-ddd', 1, 'Ports and adapters around the domain', $body$Hexagonal architecture, also called ports and adapters, places the domain at the center and treats every external system as an edge. A port is an interface the application or domain defines, such as a repository or a payment gateway; an adapter is the technology-specific implementation, such as a JPA repository or an HTTP client. Because the interfaces belong to the inside, dependencies point inward and infrastructure can be replaced without touching the model. This complements DDD rather than replacing it: the model stays pure while integrations multiply at the boundary. Rule of thumb: if a domain package imports a framework type, the hexagon has a hole.$body$, $code$// Port defined by the domain.
public interface PaymentGateway {
    Receipt charge(CardToken token, Money amount);
}

// Adapter implemented in infrastructure.
public class StripeGateway implements PaymentGateway {
    public Receipt charge(CardToken token, Money amount) {
        return stripeClient.charge(token.value(), amount);
    }
}$code$),
    ('hexagonal-architecture-and-ddd', 2, 'Dependency direction and frameworks', $body$The payoff comes from one rule: source code dependencies point toward the domain. Application services orchestrate use cases and depend on ports; adapters depend on the application; the domain depends on nothing outside itself and the language. Frameworks sit at the edge, and wiring happens at startup. Teams usually enforce this with module boundaries and architecture tests, because a single convenient annotation on an entity can recreate coupling everywhere. This discipline is also what makes the model testable, since business rules can run against in-memory adapters without a database, web server, or container. Rule of thumb: compile the domain module alone; if that fails, something inward leaked.$body$, $code$public final class CheckoutService {
    private final PaymentGateway payments;   // port, not StripeGateway

    public CheckoutService(PaymentGateway payments) {
        this.payments = payments;
    }

    public Receipt checkout(Cart cart) {
        return payments.charge(cart.cardToken(), cart.total());
    }
}$code$),
    ('hexagonal-architecture-and-ddd', 3, 'Testability and operational payoff', $body$With ports in place, tests can substitute a fake repository or an in-memory event publisher, so most unit tests exercise real domain behavior quickly and deterministically. Integration tests then concentrate on adapters, where the genuine risk lies, such as SQL mapping or protocol handling. Operationally, adapters make explicit which external systems a service touches, which helps failure analysis and dependency planning. The architecture also supports mixed strategies: one bounded context can be hexagonal while a neighboring one stays a simple CRUD module. Rule of thumb: put fakes behind ports for the domain and real systems behind adapters, and test each in that spirit.$body$, $code$final class InMemoryOrders implements OrderRepository {
    private final Map<OrderId, Order> store = new HashMap<>();

    public Optional<Order> byId(OrderId id) {
        return Optional.ofNullable(store.get(id));
    }

    public void save(Order order) {
        store.put(order.id(), order);
    }
}$code$),
    ('ddd-and-relational-mapping', 1, 'Where object and table models disagree', $body$Relational schemas favor normalized sets joined by foreign keys, while domain models favor encapsulated aggregates with behavior. The two shapes rarely match one to one. Mapping decisions, such as joining tables back into an aggregate or splitting one concept across rows, affect loading strategy, locking, and invariant enforcement. Before writing code, decide how each aggregate will be stored and read, and accept that the schema will sometimes look different from the model. Keeping mapping behind repositories stops these decisions from bleeding into the domain. Rule of thumb: model behavior first, then choose the simplest schema that preserves the aggregate invariants.$body$, $code$@Entity
@Table(name = "purchase_order")
public class Order {
    @Id
    private UUID id;
    @Version
    private long version;
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "order_id")
    private List<OrderLine> lines = new ArrayList<>();
}$code$),
    ('ddd-and-relational-mapping', 2, 'Mapping aggregates to tables', $body$A common approach stores the aggregate root in one table and its child entities in tables joined by the root identifier, loading the cluster together inside a transaction. Value objects appear as columns or small grouped tables when they have structure. Identity, optimistic locking versions, and audit columns usually live on the root row. The dangers are lazy navigation that silently pulls half the database and mapping internal entities as independent roots, which weakens encapsulation. Keep the schema aligned with transaction boundaries so one write touches one aggregate. Rule of thumb: if loading a single aggregate requires dozens of queries, revisit both the mapping and the boundary.$body$, $code$@Transactional
public OrderId place(PlaceOrder command) {
    Order order = Order.place(command.customerId(), command.lines());
    orders.save(order); // root plus child rows, one transaction
    return order.id();
}$code$),
    ('ddd-and-relational-mapping', 3, 'Accepted denormalization and read models', $body$Strict normalization can be hostile to aggregate-oriented design. Totals, current statuses, and derived fields are often cached on the root row to avoid expensive joins and to keep invariants enforceable in one place. That redundancy is acceptable when a single writer owns the data and maintains it inside the same transaction. When different consumers need different shapes, prefer views, projections, or dedicated read models over duplicating fields everywhere. Document each redundant column with its owner and update rule. Rule of thumb: duplicate deliberately, inside the row owned by the aggregate, and never let a second writer change a field it does not own.$body$, $code$@Entity
@Table(name = "purchase_order")
public class Order {
    @Id private UUID id;
    @Version private long version;
    @Column(name = "total_amount") private BigDecimal totalAmount;

    // Cached total maintained whenever a line changes.
    void recalculateTotal() {
        this.totalAmount = lines.stream()
            .map(OrderLine::subtotalValue)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}$code$),
    ('event-storming-to-code', 1, 'From sticky notes to boundaries', $body$Event storming, introduced by Alberto Brandolini, is a workshop technique in which domain experts and developers line up past-tense domain events, then add commands, policies, aggregates, and external systems around them. The messy wall is exploratory: its value is shared understanding and a discovered vocabulary, not an artifact to transcribe literally into classes. After the session, cluster the events by language and by the people involved; those clusters suggest bounded contexts, and aggregates emerge where several commands must change the same consistency boundary. Rule of thumb: treat the wall as evidence about the domain, and design the software deliberately instead of copying stickers.$body$, $code$// Straight from the wall: past-tense facts, in order.
sealed interface CheckoutEvent
        permits CartAbandoned, OrderPlaced, PaymentTaken { }

record CartAbandoned(CartId cartId, Instant occurredAt)
        implements CheckoutEvent { }

record OrderPlaced(OrderId orderId, Instant occurredAt)
        implements CheckoutEvent { }$code$),
    ('event-storming-to-code', 2, 'Shape aggregates from the clusters', $body$Translate each cluster into a small set of aggregates by asking which invariants must hold immediately when a command arrives and which can lag. Commands that must not violate a rule together usually converge on one aggregate root; everything else becomes an event consumer or a read model. Keep the resulting model smaller than the wall suggests, because workshop notes mix policies, reports, and integration concerns that do not belong in the domain layer. Name types using the vocabulary the session produced, so meetings and code keep speaking the same language. Rule of thumb: a cluster with no aggregates is a supporting concern, not a core model.$body$, $code$// Commands that must keep one invariant together share one root.
public final class Cart {
    private final CartId id;
    private final List<CartItem> items = new ArrayList<>();

    public void addItem(ProductId product, int quantity) {
        items.add(new CartItem(product, quantity));
    }
}$code$),
    ('event-storming-to-code', 3, 'Keep the model evolving', $body$The first model from a workshop is a hypothesis, and the domain keeps moving. Schedule short modeling sessions when new events appear or a rule conflicts with reality, and treat the code as the shared artifact: rename types, move methods, and adjust boundaries as understanding improves. Refactoring is how strategic design stays alive; a model that fit last year can quietly become wrong. Record the rationale behind boundary decisions so the next engineer can revisit them with context. Rule of thumb: budget for modeling as an ongoing activity rather than a kickoff event, and let the ubiquitous language evolve with it.$body$, $code$// Workshop term corrected by the expert: reservation became hold.
public record SeatHold(SeatHoldId id, SeatId seatId, Instant expiresAt) {
    public boolean isExpiredAt(Instant now) {
        return !expiresAt.isAfter(now);
    }

    public SeatHold extendBy(Duration grace) {
        return new SeatHold(id, seatId, expiresAt.plus(grace));
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
    'ubiquitous-language-in-code', 'strategic-domain-analysis',
    'bounded-contexts-in-practice', 'context-mapping-patterns',
    'entities-and-identity', 'value-objects-modeling',
    'aggregates-and-consistency-boundaries', 'domain-services',
    'domain-events-in-the-model', 'repositories-as-domain-abstractions',
    'factories-and-builders-in-domain-code', 'anemic-model-anti-pattern',
    'hexagonal-architecture-and-ddd', 'ddd-and-relational-mapping',
    'event-storming-to-code'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
