-- V27 — API design across REST, GraphQL and gRPC.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('rest-resource-modeling', 'Modeling REST Resources', 'Model resources, collections, and relationships so REST endpoints stay predictable as a product grows.', 'Junior', 24, true, 1),
    ('openapi-first-design', 'OpenAPI-First API Design', 'Write the API contract before implementation and keep generated servers, clients, and reviews in sync.', 'Junior', 26, true, 1),
    ('api-versioning-strategies', 'API Versioning Strategies', 'Choose a versioning approach and pair it with additive change rules and a clear sunset policy.', 'Mid', 30, true, 1),
    ('api-error-contracts', 'Designing API Error Contracts', 'Design a stable error envelope with machine-readable codes and RFC 9457 problem details.', 'Mid', 28, true, 1),
    ('api-idempotency-and-safety', 'Idempotency and Safe Retries', 'Make retries safe with idempotency keys, duplicate detection, and clear submission semantics.', 'Mid', 32, true, 1),
    ('graphql-schema-design', 'GraphQL Schema Design', 'Design GraphQL types, nullability, and connections that can evolve without breaking clients.', 'Mid', 30, true, 1),
    ('graphql-in-java-with-spring', 'GraphQL in Java with Spring', 'Build GraphQL services with Spring for GraphQL, efficient data fetchers, and dataloaders.', 'Senior', 36, true, 1),
    ('graphql-security-and-limits', 'GraphQL Security and Query Limits', 'Limit query depth, complexity, and introspection so GraphQL endpoints stay safe in production.', 'Senior', 34, true, 1),
    ('grpc-and-protobuf-basics', 'gRPC and Protobuf Basics', 'Define protobuf services and messages with field numbering rules that preserve wire compatibility.', 'Junior', 26, true, 1),
    ('grpc-in-spring-services', 'gRPC in Spring Services', 'Implement gRPC services in Spring with interceptors, deadlines, and a mapped error model.', 'Mid', 32, true, 1),
    ('choosing-between-rest-graphql-grpc', 'Choosing Between REST GraphQL and gRPC', 'Select a protocol by consumer type, payload shape, streaming needs, and operational maturity.', 'Senior', 38, true, 1),
    ('api-rate-limiting-and-quotas', 'API Rate Limiting and Quotas', 'Apply rate limiting algorithms, per-tenant quotas, and clear limit communication.', 'Mid', 30, true, 1),
    ('api-observability-and-analytics', 'API Observability and Consumer Analytics', 'Instrument per-endpoint metrics, consumer analytics, and deprecation signals with sane cardinality.', 'Mid', 28, true, 1),
    ('api-security-at-the-edge', 'API Security at the Edge', 'Decide where authentication and authorization live and constrain input before it reaches services.', 'Mid', 30, true, 1),
    ('api-documentation-and-developer-experience', 'API Documentation and Developer Experience', 'Generate reference docs, quickstarts, and changelogs that help consumers ship faster.', 'Junior', 22, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('rest-resource-modeling', 1, 'Model nouns as addressable resources', $body$A REST resource is a thing clients can name and address, not a remote procedure call in disguise. Collections hold items; an item identifies one member, normally by an opaque server-assigned identifier. Use plural, lower-case, hyphenated path segments and let HTTP methods carry the verb: GET reads, POST creates in a collection, PUT replaces, PATCH partially updates, DELETE removes. Because clients bookmark, log, and monitor URLs, names outlive internal naming debates. If an endpoint name sounds like an action, look for the underlying thing that changes state. Rule of thumb: the path names the what, the method names the how.$body$, $code$POST /orders HTTP/1.1
Content-Type: application/json

{"reference": "ORD-1007", "quantity": 2}

HTTP/1.1 201 Created
Location: /orders/8f14e45f-ceea-167a$code$),
    ('rest-resource-modeling', 2, 'Keep nesting depth deliberate', $body$Nesting expresses ownership: a sub-resource that has no independent identity, such as the lines of an invoice, is a reasonable child. Deep paths with two or more variable segments become hard to authorize, cache, and document, and they force every client to reconstruct context the server could store. When a relationship is optional, shared, or many-to-many, expose it as a top-level collection with a filter parameter instead of a deep path. Set a depth budget, usually one level below the collection, and treat requests for deeper nesting as a signal to promote something. Rule of thumb: nest only what cannot exist on its own, and promote sub-resources once clients address them independently.$body$, $code$GET /invoices/{invoiceId}/lines

// Same data, addressed independently:
GET /invoice-lines?invoiceId={invoiceId}&status=OPEN

// Too deep to authorize and cache well:
GET /customers/{customerId}/invoices/{invoiceId}/lines$code$),
    ('rest-resource-modeling', 3, 'Avoid naming traps that age badly', $body$Paths should stay stable identifiers rather than descriptions of behavior. Exposing database vocabulary such as table names, surrogate keys, or internal status enumerations leaks implementation detail and makes refactoring visible to clients. Do not put verbs in paths or actions in query strings. Keep one casing convention and document it, because mixed conventions cause subtle client bugs on case-sensitive platforms. Collections should remain plural even when a collection currently holds one item. Renaming a published resource means introducing the new path, linking the old one, and deprecating it formally. Rule of thumb: if a name would look careless in a changelog, fix it before the first public release.$body$, $code$// Preferred
GET /users/{userId}

// Avoid: verb in path, internal term, ambiguous casing
GET /getUserById?id=42
POST /api/OrderTable/query$code$),
    ('openapi-first-design', 1, 'Design the contract before the code', $body$The OpenAPI document is the source of truth for paths, schemas, media types, and error responses. Writing it first forces awkward questions early: which fields are required, which are nullable, what validation failure looks like, and who owns each operation. Review the specification diff the way you review code, because a schema change is a compatibility change whether or not the implementation shipped yet. Serving generated interfaces from the same document keeps producers and consumers aligned. Behavioral details that matter to callers belong in the document, not in a wiki page or a chat history. Rule of thumb: if consumers must know it, the contract must say it.$body$, $code$paths:
  /orders:
    post:
      operationId: createOrder
      requestBody:
        required: true
      responses:
        "201":
          description: Order created$code$),
    ('openapi-first-design', 2, 'Generate servers and clients consistently', $body$Code generation turns the reviewed contract into typed stubs, request validation, and client libraries, which removes most hand-written serialization drift. Generation quality follows document quality: vague names, missing examples, and optional-by-default fields produce awkward APIs in every target language. Pin the generator version in the build so every team produces identical output, and never edit generated files by hand because the next run overwrites them. Decide early whether generated interfaces are the public surface or thin adapters above hand-written controllers. Run generation in continuous integration and fail the build when the committed or published output differs. Rule of thumb: the document is the input, generation is the stamp, drift is the enemy.$body$, $code$<plugin>
  <groupId>org.openapitools</groupId>
  <artifactId>openapi-generator-maven-plugin</artifactId>
  <version>7.10.0</version>
  <configuration>
    <inputSpec>src/main/resources/openapi.yaml</inputSpec>
    <generatorName>spring</generatorName>
  </configuration>
</plugin>$code$),
    ('openapi-first-design', 3, 'Detect drift after release', $body$Once clients depend on the published document, silent drift becomes the main risk: a serializer omits a field, a filter grows an undocumented parameter, a response gains a value nobody promised. Detect it by validating real responses against the contract schemas in integration tests, and by comparing the running service surface with the published document in continuous integration. Treat the specification as a versioned artifact with a changelog entry, even when the API surface did not change. When a behavior must change quickly, update the document first and let the pipeline reveal affected consumers. Rule of thumb: undocumented behavior is not a feature consumers can rely on, it is an accident waiting to break someone.$body$, $code$mockMvc.perform(get("/orders/{id}", "42"))
    .andExpect(status().isOk())
    .andExpect(content().contentType(MediaType.APPLICATION_JSON));

// A CI step additionally validates the response body
// against the schemas declared in openapi.yaml.$code$),
    ('api-versioning-strategies', 1, 'Choose one versioning axis', $body$URI versioning such as /v2/orders is visible, easy to route, and trivial to cache, which keeps it the pragmatic default for public HTTP APIs. Header or media-type versioning keeps URLs stable and treats version selection as content negotiation, but it is harder to debug because versions disappear from logs, dashboards, and browsers. The exact mechanism matters less than consistency: mixing axes inside one product confuses consumers and multiplies the compatibility test matrix. Reserve a new major version for genuinely breaking changes, and define from day one what you consider breaking. Rule of thumb: keep the version dimension in one place and allow everything else to evolve additively.$body$, $code$# URI versioning: explicit and cache friendly
GET /v2/orders HTTP/1.1

# Media type versioning: stable URLs
Accept: application/vnd.example.v2+json

# Header versioning: invisible to browser tooling
X-Api-Version: 2$code$),
    ('api-versioning-strategies', 2, 'Evolve additively by default', $body$Most breaking changes are avoidable. Adding an optional request field, a new response field, a new endpoint, or a new enum value keeps existing clients working, provided clients tolerate unknown fields and values, which the contract should state explicitly. Renaming anything, tightening validation, changing a type or default, or reordering semantics breaks clients even when the HTTP shape looks unchanged. When a genuine break is unavoidable, introduce it as a new major version rather than mutating a published one, and keep both versions reading the same data model during the transition. Rule of thumb: additive by default, breaking only with an announced migration path.$body$, $code$record OrderResponse(String id, String status,
                     Instant estimatedDelivery) {}

// Adding an optional field is additive.
// Removing, renaming, or retyping a field is breaking,
// even when existing payloads still parse.$code$),
    ('api-versioning-strategies', 3, 'Announce sunset through headers and telemetry', $body$A deprecation note in a changelog does not reach automated consumers. RFC 8594 defines the Sunset response header, which announces when a URI is likely to stop responding, and RFC 9745 defines the Deprecation header, which reports when the resource became deprecated and can link to migration documentation through a rel value. Pair those signals with usage telemetry so you can name the consumers still calling the old path and contact them before enforcement. Publish a timeline that spans at least one full consumer release cycle. Rule of thumb: never sunset a version while you are unable to prove who still uses it.$body$, $code$# Every response from the deprecated version carries:
Deprecation: @1735689600
Sunset: Wed, 01 Jan 2026 00:00:00 GMT
Link: <https://api.example.com/docs/migrate-v1>;
      rel="deprecation"; type="text/html"$code$),
    ('api-error-contracts', 1, 'Standardize one error envelope', $body$Every error response should share one structure so clients can write a single handling path. RFC 9457 problem details define a JSON object with type, title, status, detail, and instance members, served as application/problem+json; the type URI identifies the problem class while detail describes this specific occurrence. Include a stable machine-readable code or type, because human text changes with copy edits and localization and must never drive control flow. Keep the envelope identical across 4xx and 5xx responses so middleware can parse failures without special cases. Rule of thumb: clients branch on the problem type or code, never on the message string.$body$, $code${
  "type": "https://api.example.com/problems/insufficient-credit",
  "title": "Insufficient credit",
  "status": 403,
  "detail": "Balance 12 EUR is below the required 30 EUR.",
  "instance": "/requests/7f2a"
}$code$),
    ('api-error-contracts', 2, 'Expose codes, hide internals', $body$Machine-readable codes let clients react deliberately: validation_failed, rate_limited, payment_required. Map exceptions to codes in one place at the API boundary so the mapping stays consistent as services grow. Never echo stack traces, SQL fragments, hostnames, or internal class names; they help attackers and surface in customer screenshots. Return field-level validation failures with paths and reasons, capped in number and length. Log a correlation identifier server-side and return it to the caller so support can join a complaint to a trace. Rule of thumb: the response explains what the caller can do next, while the logs explain what your team must fix.$body$, $code$ProblemDetail problem = ProblemDetail.forStatusAndDetail(
    HttpStatus.BAD_REQUEST, "quantity must be positive");
problem.setType(URI.create(
    "https://api.example.com/problems/invalid-quantity"));
problem.setProperty("field", "quantity");
return problem;$code$),
    ('api-error-contracts', 3, 'Pick statuses with deliberate meaning', $body$Status codes are part of the contract, so choose them for meaning rather than convenience: 400 for malformed syntax or validation, 401 versus 403 for authentication versus authorization, 404 for unknown resources, 409 for state conflicts, 422 when syntactically valid input fails semantics, 429 with Retry-After for throttling, and 503 when load shedding. Never return 200 with an error body, because gateways, retry logic, and dashboards all depend on status. Document each code per endpoint in the contract. For every failure class, decide whether a client retry is safe, harmful, or useless. Rule of thumb: when two failures require different client behavior, they deserve different statuses or problem types.$body$, $code$@ExceptionHandler(OrderConflictException.class)
ResponseEntity<ProblemDetail> handle(OrderConflictException ex) {
    ProblemDetail body = ProblemDetail.forStatus(HttpStatus.CONFLICT);
    body.setProperty("orderId", ex.orderId());
    return ResponseEntity.status(HttpStatus.CONFLICT).body(body);
}$code$),
    ('api-idempotency-and-safety', 1, 'Design mutations for safe repetition', $body$HTTP defines GET, HEAD, PUT, and DELETE as idempotent: repeating the request has the same intended effect as sending it once. POST is not, so a retried payment or order creation can produce a duplicate side effect. Networks, mobile clients, message brokers, and users all repeat requests, so treat repetition as normal traffic rather than misbehavior. Decide for every mutating endpoint what a second identical request should do, and make that behavior explicit in the contract. The Idempotency-Key request header, specified in an IETF HTTPAPI draft, gives clients a portable way to say this request repeats a previous intention. Rule of thumb: assume every write will arrive twice.$body$, $code$POST /payments HTTP/1.1
Idempotency-Key: 9c1f4e2a-7d3b-4a11-9f0e-2b6c8d5e1a44
Content-Type: application/json

{"amount": 3000, "currency": "EUR"}$code$),
    ('api-idempotency-and-safety', 2, 'Persist the key with the outcome', $body$An idempotency key only works when the server stores the mapping from key to outcome atomically with the side effect, scoped to the caller and endpoint. On the first request, record the key in progress; on duplicates, return the stored response or report that work is still running. Store a fingerprint of the request body and reject reuse of the same key with a different payload, which usually signals a client bug. Expire keys after a documented retention window that comfortably covers client retry behavior. Concurrent duplicates must be resolved by a uniqueness constraint, not by a read-then-write check. Rule of thumb: the database constraint is the arbiter, application code is only the messenger.$body$, $code$CREATE TABLE idempotency_record (
    user_id UUID NOT NULL,
    idempotency_key VARCHAR(128) NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    response_status INT,
    response_body JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, idempotency_key)
);$code$),
    ('api-idempotency-and-safety', 3, 'Suppress duplicates at the edge', $body$Duplicate suppression belongs as close to the entry point as possible, before expensive downstream calls and before any irreversible effect. A gateway can drop obviously repeated requests, but only the service that owns the resource understands what a duplicate means, so the strongest guarantee lives there. Replay responses must repeat the original status and body so client retry logic sees the same success it would have seen. Distinguish a retry of one intention from a genuine second intention, which requires a fresh key. Generate keys on the client, one per user action, and never bind them to a form session. Rule of thumb: one key per intention, stored server side until it safely expires.$body$, $code$@PostMapping("/payments")
public ResponseEntity<Payment> create(
        @RequestHeader("Idempotency-Key") String key,
        @RequestBody CreatePayment request) {
    return paymentService.createOnce(key, request);
}$code$),
    ('graphql-schema-design', 1, 'Model types around client workflows', $body$A GraphQL schema is a product surface, not a mirror of your database. Types and fields are the vocabulary clients compose into queries, so model the domain concepts clients reason about instead of exposing rows and joins; otherwise every storage change becomes an API change. Keep related fields cohesive under meaningful types, name object types singularly and collection fields plurally, and delete anything no client needs. Evolve additively: adding types, fields, and enum values is compatible, while removing or renaming fields is breaking. Use the built-in @deprecated directive to mark fields you intend to remove so tooling can warn consumers. Rule of thumb: publish a field only when you can resolve it efficiently for any nesting a client can write.$body$, $code$type Order {
  id: ID!
  reference: String

  # Still served for old clients
  legacyRef: String @deprecated(reason: "Use reference")
}$code$),
    ('graphql-schema-design', 2, 'Treat nullability as a promise', $body$Writing an exclamation mark after a type declares a non-null guarantee that clients may rely on without null checks, and breaking that guarantee later is a breaking change. Non-null is also a propagation risk: if resolution of a non-null field fails, the error nulls out the nearest nullable ancestor, potentially wiping out a whole branch of otherwise useful data. Reserve non-null for values guaranteed by construction, such as identifiers and required relationships. If empty genuinely means empty, make both the list and its items non-null. When in doubt, leave the field nullable and let partial responses work for you. Rule of thumb: promise exactly what the data model guarantees today, not what you hope it becomes.$body$, $code$type Order {
  id: ID!
  # Nullable: legacy orders may predate the discount
  discount: Discount
  # Non-null list of non-null items; empty means empty
  lines: [OrderLine!]!
}$code$),
    ('graphql-schema-design', 3, 'Paginate with connections, not raw lists', $body$An unbounded list field invites a query that returns an entire table the moment a client forgets a filter. The connection pattern wraps results in edges and pageInfo, exposes first, after, last, and before arguments, and hands out opaque cursors that are commonly base64-encoded positions rather than offsets or identifiers. Edges add one level of indirection but give relationship metadata a natural home and let you change the pagination mechanism without a schema break. Always declare a maximum page size, because clients will request more than you want to serve. Add totalCount only when the cost is bounded and consumers truly need it. Rule of thumb: any list that grows with the business belongs in a connection.$body$, $code$type OrderConnection {
  edges: [OrderEdge!]!
  pageInfo: PageInfo!
}

type OrderEdge {
  cursor: String!
  node: Order!
}$code$),
    ('graphql-in-java-with-spring', 1, 'Wire Spring for GraphQL cleanly', $body$Spring for GraphQL builds on GraphQL Java and connects schema handling to the Spring runtime, so SDL files placed on the classpath, typically under src/main/resources/graphql, are loaded automatically and exposed as a GraphQlSource. Controllers declare @QueryMapping, @MutationMapping, or @SchemaMapping methods whose names default to schema fields; handler methods can accept @Argument, the parent object, @ContextValue entries, or a DataLoader, and may return plain values or Reactor types. Keep resolvers thin and delegate to services so business logic stays testable. Enable schema mapping inspection at startup to catch unmapped fields and nullability mismatches before users see silent nulls. Rule of thumb: the schema is the contract, controllers are only glue.$body$, $code$@Controller
public class OrderController {

    @QueryMapping
    public Order order(@Argument String id) {
        return orderService.find(id);
    }
}$code$),
    ('graphql-in-java-with-spring', 2, 'Kill N+1 with batched loaders', $body$GraphQL resolves fields independently, so a resolver that fetches a related entity once per parent quietly becomes one query per row, the classic N plus one problem. Spring for GraphQL integrates GraphQL Java DataLoaders: register a batch loader through a BatchLoaderRegistry bean and receive it in handler methods; keys registered during one selection set execution collapse into a single batched call, and the framework dispatches it after registration so batching can actually happen. Return CompletionStage or CompletableFuture values from the loader so execution stays asynchronous. Bound batch sizes and IN-list lengths, and measure per-field latency instead of trusting the aggregate. Rule of thumb: any resolver that touches the database for a list of parents must batch.$body$, $code$@SchemaMapping
public CompletableFuture<List<Line>> lines(Order order,
        DataLoader<String, List<Line>> dataLoader) {
    // One batched query instead of one per order
    return dataLoader.load(order.id());
}$code$),
    ('graphql-in-java-with-spring', 3, 'Carry context, secure every field', $body$Resolvers run inside a context you control, so pass authentication, tenant, and request data through @ContextValue rather than reading ambient statics; that context is also where loaders and per-request caches live. Field-level authorization must live in the resolver or an instrumentation hook and must run for every path a client can compose, including nested fields that a broad query drags in. Translate exceptions into GraphQL errors with safe messages and stable extension codes, and keep stack traces out of responses. Mutations should return payload types that expose both the result and typed user errors, so client handling stops being string matching. Rule of thumb: treat every field as if it were its own public endpoint.$body$, $code$@SchemaMapping
public List<Invoice> invoices(Account account,
        @ContextValue Tenant tenant) {
    // Tenant comes from the request context, never arguments
    return invoiceService.listFor(tenant.id(), account.id());
}$code$),
    ('graphql-security-and-limits', 1, 'Bound depth and complexity', $body$GraphQL lets clients express arbitrarily nested and repeated selections, so a tiny request can expand into enormous work. Enforce a maximum depth and a maximum complexity score in which every field and every multiplicand list contributes cost, and reject oversized operations with a clear error before execution begins. GraphQL Java ships analysis instrumentations for both depth and complexity, applied together; depth alone misses wide repetitive selections, and complexity alone can underestimate deep recursion through cyclic types. Derive budgets from the schema and cover them in tests, because adding a field can silently change worst-case cost. Rule of thumb: review every new field as if a hostile client could request it a thousand times in one document.$body$, $code$GraphQL.newGraphQL(schema)
    .instrumentation(new ChainedInstrumentation(List.of(
        new MaxQueryDepthInstrumentation(10),
        new MaxQueryComplexityInstrumentation(1000))))
    .build();$code$),
    ('graphql-security-and-limits', 2, 'Prefer persisted documents for known clients', $body$First-party clients send a small, known set of operations, so accept only documents approved in advance: the client sends a hash or identifier instead of full query text, and the server executes only allowlisted operations. This blocks arbitrary query shapes, removes the need to parse hostile documents at scale, and enables caching of validation results. Public APIs cannot rely on the technique because third parties author their own operations, so they depend on depth and cost budgets plus per-consumer rate limits. Keep a development path for ad hoc queries that logs what was requested, and never enable it in production. Rule of thumb: first-party traffic gets an allowlist, third-party traffic gets budgets.$body$, $code${
  "operationName": "OrderSummary",
  "documentId": "sha256:8f14e45fceea167a5a36dedd4bea2543",
  "variables": { "id": "42" }
}$code$),
    ('graphql-security-and-limits', 3, 'Limit introspection and error details', $body$Introspection helps developers and attack tooling equally: a single query reveals every type, field, argument, and deprecation notice. Many teams disable introspection for anonymous public traffic while keeping it available to authenticated developers or internal tooling, and persisted documents make that decision easy because clients never send query text. Control what errors reveal as well: verbose resolver messages leak persistence structure, and field suggestions in error output can disclose unreleased schema members. Rate limit expensive single operations by cost rather than request count. And keep the schema itself secure at the field level. Rule of thumb: assume the schema is discoverable and defend data, not shape.$body$, $code${"errors": [
  {"message": "Operation exceeds the depth limit of 10",
   "path": [],
   "extensions": {"code": "QUERY_TOO_DEEP"}}
]}$code$),
    ('grpc-and-protobuf-basics', 1, 'Define services and messages in proto files', $body$A proto file is the contract: service blocks declare RPC methods, message blocks declare request and response payloads, and proto3 is the modern syntax default. Field numbers are the identity of a field on the wire, while names matter only to generated code and humans, which is why reordering a message is safe but renumbering is not. Choose the package and Java options deliberately, because generated package and class names are painful to change once consumers compile against them. Prefer small purpose-built messages over one generic envelope, since a shared envelope couples every caller forever. Rule of thumb: a message describes one thing a service sends, not everything it might send.$body$, $code$syntax = "proto3";

package orders.v1;

message GetOrderRequest {
  string order_id = 1;
}

message Order {
  string order_id = 1;
  string status = 2;
}$code$),
    ('grpc-and-protobuf-basics', 2, 'Number fields once and reserve forever', $body$Field numbers are how protobuf identifies data in its binary wire format, so they must be unique within a message and must never be reused. Numbers 1 through 15 encode in a single byte and belong to the fields that are set most often; the implementation reserves 19000 through 19999, and the maximum field number is 536,870,911. When you remove a field, reserve its number and its name so a future editor cannot reintroduce it with different meaning; reuse is how decode ambiguity, corruption, and leaked data happen. Renaming a field keeps wire compatibility but breaks source compatibility. Rule of thumb: fields enter a message and never leave unremembered.$body$, $code$message Order {
  reserved 3, 7;
  reserved "legacy_ref";

  string order_id = 1;
  OrderStatus status = 2;
}$code$),
    ('grpc-and-protobuf-basics', 3, 'Compile stubs in the build', $body$Protocol buffers are compiled: protoc, or the Maven and Gradle plugins that wrap it, read proto files and generate message classes plus client and server stubs for your language. Generation belongs in the normal build, not in a manual step or a committed folder, so the schema and the code cannot drift apart. Pin the toolchain version, because upgrading protoc can change generated APIs and needs a deliberate review. Publish proto files from a versioned artifact or module so consumers compile against exactly the contract you released, and keep one source of truth for each message. Rule of thumb: regenerate stubs on every build and let the diff tell you what changed.$body$, $code$<plugin>
  <groupId>org.xolstice.maven.plugins</groupId>
  <artifactId>protobuf-maven-plugin</artifactId>
  <configuration>
    <protocArtifact>
      com.google.protobuf:protoc:${protobuf.version}:exe:${os.detected.classifier}
    </protocArtifact>
  </configuration>
</plugin>$code$),
    ('grpc-in-spring-services', 1, 'Implement services the Spring way', $body$Spring gRPC provides autoconfiguration and dependency injection for gRPC servers and clients, but the service class still extends the generated base class and completes each call through a StreamObserver. Keep that adapter thin: map protobuf messages to domain types, delegate to ordinary Spring services, and translate results back. Blocking database or HTTP work should run on a bounded executor or a dedicated thread pool, because occupying the gRPC event loop starves other calls. Register interceptors as beans so authentication, logging, and deadlines are applied uniformly. Test through generated stubs rather than internals. Rule of thumb: generated classes are transport plumbing, your Spring services are the logic.$body$, $code$@Service
public class OrderGrpcService
        extends OrderServiceGrpc.OrderServiceImplBase {

    @Override
    public void getOrder(GetOrderRequest req,
            StreamObserver<OrderReply> observer) {
        OrderReply reply = mapper.toReply(service.find(req.getOrderId()));
        observer.onNext(reply);
        observer.onCompleted();
    }
}$code$),
    ('grpc-in-spring-services', 2, 'Propagate deadlines and metadata', $body$A deadline tells every hop how much time remains, and gRPC propagates it automatically, so the server can read the remaining budget from the context and abandon work that can no longer help. Set default deadlines on client stubs instead of trusting callers to remember; a call without a deadline can pin connections and threads indefinitely. Carry authentication tokens, tenant identifiers, and correlation identifiers in metadata, attach them at the client through interceptors, and forward what downstream services need. Never schedule work that outlives the call that created it, and respond to cancellation by releasing resources promptly. Rule of thumb: every stub gets a deadline, every edge gets an interceptor.$body$, $code$OrderServiceGrpc.OrderServiceBlockingStub stub = OrderServiceGrpc
    .newBlockingStub(channel)
    .withDeadlineAfter(2, TimeUnit.SECONDS);

OrderReply reply = stub.getOrder(request);$code$),
    ('grpc-in-spring-services', 3, 'Map failures to gRPC statuses', $body$gRPC keeps a deliberately small error model: OK, INVALID_ARGUMENT, NOT_FOUND, PERMISSION_DENIED, DEADLINE_EXCEEDED, RESOURCE_EXHAUSTED, UNAVAILABLE, and a handful of others, optionally carrying trailing metadata. Translate domain exceptions into a Status with a code that tells the caller what to do, and finish calls with onError; never leak internal exception text across the boundary. Map in one place, an interceptor or shared advice, so every service behaves consistently. When clients need structured details such as field violations, the richer Google error model carries protobuf payloads in trailing metadata, but proxies and load balancers usually cannot see them. Rule of thumb: clients branch on the status code, never on message text.$body$, $code$try {
    observer.onNext(service.find(req.getOrderId()));
    observer.onCompleted();
} catch (OrderNotFound ex) {
    observer.onError(Status.NOT_FOUND
        .withDescription("order not found")
        .asRuntimeException());
}$code$),
    ('choosing-between-rest-graphql-grpc', 1, 'Start from consumers and payloads', $body$The protocol follows the consumer, not personal preference. Public and partner integrations usually favor REST, because every language, gateway, and debugging tool speaks HTTP, and documentation doubles as the product. First-party product clients that need many related resources in one round trip fit GraphQL, where the client selects exactly the fields it renders and the server executes one composed query. Internal service-to-service calls with stable contracts and hot paths fit gRPC and protobuf, where code generation and compact payloads pay off. Payload shape reinforces the choice: uniform resource documents suit REST, deeply related graphs suit GraphQL, and small typed messages suit protobuf. Rule of thumb: optimize for a caller you can name.$body$, $code$record ConsumerProfile(String type, boolean needsStreaming,
                       boolean deeplyRelatedData) {}

// Public integrations       -> REST over HTTP/JSON
// First-party UI clients    -> GraphQL
// Internal callers, streams -> gRPC$code$),
    ('choosing-between-rest-graphql-grpc', 2, 'Weigh streaming and transport needs', $body$Streaming decides many comparisons. gRPC supports client streaming, server streaming, and bidirectional streams over HTTP/2, which suits telemetry feeds, long uploads, and high-frequency updates. REST can stream responses with chunked encoding and push updates through server-sent events, which behaves well through proxies the tooling already understands. GraphQL subscriptions typically run over WebSockets or server-sent events and fit occasional live updates to product clients rather than sustained binary throughput. Weigh operational reality too: gRPC wants HTTP/2-aware load balancing, while REST and GraphQL ride commodity infrastructure. Rule of thumb: choose the simplest transport that satisfies the hardest of your latency, volume, and streaming requirements.$body$, $code$syntax = "proto3";

service OrderService {
  rpc TrackOrder(TrackOrderRequest) returns (stream OrderUpdate);
}$code$),
    ('choosing-between-rest-graphql-grpc', 3, 'Account for operational maturity', $body$Each protocol carries operational weight. REST inherits HTTP caching, conditional requests, and familiar observability from the wider ecosystem. GraphQL concentrates many operations behind one endpoint, so it needs query cost controls, persisted documents, and per-operation metrics to stay operable. gRPC needs HTTP/2-aware load balancing, deadline discipline, and a publishing process for proto files. Evolution also differs: REST changes additively, GraphQL adds fields and deprecates others, and protobuf never reuses field numbers. Match the protocol to the maturity, staffing, and tooling of the teams on both sides of the boundary. Rule of thumb: choose what your teams can operate at three in the morning, not what demos best.$body$, $code$// One GraphQL endpoint hides many operations, so tag by name
Counter.builder("graphql.operation")
    .tag("operation", operationName)
    .tag("outcome", outcome)
    .register(registry);$code$),
    ('api-rate-limiting-and-quotas', 1, 'Choose the right limiting algorithm', $body$Fixed windows are trivial to implement but allow double-rate bursts across a boundary. Sliding windows smooth that edge with more state. Token buckets allow controlled bursts because tokens accumulate while a client is idle, which matches real traffic, while leaky buckets enforce a steady output rate. Match the algorithm to the harm you are preventing: expensive queries need concurrency limits as well as request limits, and cheap reads can tolerate bursts. When more than one instance serves traffic, counters must live in a shared store, and the check-and-decrement must be atomic. Rule of thumb: decide the burst you are willing to accept before you pick the algorithm.$body$, $code$Bucket bucket = Bucket.builder()
    .addLimit(Bandwidth.classic(50,
        Refill.greedy(50, Duration.ofSeconds(1))))
    .build();

if (!bucket.tryConsume(1)) {
    return ResponseEntity.status(429).build();
}$code$),
    ('api-rate-limiting-and-quotas', 2, 'Scope quotas to tenants', $body$Limits keyed by IP address misbehave behind NAT, corporate proxies, and mobile networks, where thousands of users share one address. Authenticate first, then key the counter by principal or tenant, falling back to IP only for unauthenticated traffic. Independent per-tenant quotas stop one noisy consumer from consuming everyone else capacity, and tiers let interactive user traffic, batch jobs, and internal callers have different budgets. Route weights help when endpoints differ wildly in cost, so one expensive report does not count the same as a cheap lookup. Rule of thumb: quotas belong to identities you can contact and reason with, not to network addresses.$body$, $code$String key = "quota:" + tenant.id();
long used = counter.increment(key, currentWindow());
if (used > tenant.limits().monthlyRequests()) {
    throw new QuotaExceededException(tenant.id());
}$code$),
    ('api-rate-limiting-and-quotas', 3, 'Communicate limits before clients hit them', $body$A 429 without guidance pushes clients into blind retries and support tickets. Return Retry-After when the wait is time-based, and expose remaining budget and reset information; the IETF is standardizing RateLimit and RateLimit-Policy response headers so clients can anticipate throttling instead of discovering it. Distinguish transient rate limiting from durable quota exhaustion, because the correct client behavior differs: back off versus wait for a new period or upgrade a plan. Emit metrics for rejections and alert when legitimate tenants are throttled persistently. Rule of thumb: a well-behaved client should be able to predict the limit before it is enforced.$body$, $code$HTTP/1.1 429 Too Many Requests
Retry-After: 30
Content-Type: application/problem+json

{"type":"https://api.example.com/problems/rate-limited",
 "title":"Too many requests","status":429}$code$),
    ('api-observability-and-analytics', 1, 'Measure per endpoint, not per service', $body$Service-wide aggregates hide the endpoint that burns CPU or fails for one tenant. Instrument request rate, error rate, and latency histograms per route template and method, keeping concrete paths and identifiers out of labels. Track request and response sizes for capacity work, and split out time spent in downstream dependencies when that explains latency better than total duration. Percentiles describe user experience far better than averages, into which the slow tail disappears. Every HTTP server framework already exposes some of this; make sure route patterns, not raw URLs, become the label values. Rule of thumb: if a label value can grow with traffic or data, it does not belong in a metric.$body$, $code$Timer.builder("http.server.requests")
    .tag("method", method)
    .tag("route", routePattern)
    .tag("status", status)
    .publishPercentileHistogram()
    .register(registry);$code$),
    ('api-observability-and-analytics', 2, 'Keep cardinality under control', $body$Every unique label combination becomes a time series, so identifiers such as user id, request id, session id, or resource id explode storage, cost, and query latency. Choose a small controlled vocabulary: route template, method, status class, tenant tier, dependency name. High-cardinality detail belongs in logs or traces, where you can query it after the fact without taxing the metrics backend. Review new metric labels in code review the same way you review a schema change, because cardinality only grows and the cost arrives quietly. Rule of thumb: two or three label dimensions is usually enough, and ten is a design smell.$body$, $code$// Good: bounded label values
Metrics.counter("api.calls",
    "route", "/orders/{id}",
    "tier", tenant.tier()).increment();

// Bad: one series per user id
// Metrics.counter("api.calls", "userId", user.id()).increment();$code$),
    ('api-observability-and-analytics', 3, 'Turn observability into deprecation evidence', $body$Observability also answers who still uses what. Log a consumer identifier taken from credentials or a client header against deprecated operations, sampled to control volume, and build dashboards per version and endpoint. That evidence turns the standard deprecation debate from opinion into fact. Emit Deprecation and Sunset headers on deprecated responses so automated tooling can observe deadlines, and alert when usage fails to decline as the date approaches. Track error rates by client version as well, because a regression in a new version will appear there first. Rule of thumb: deprecate only what you can measure, and contact whoever remains.$body$, $code$log.atInfo()
    .addKeyValue("deprecatedRoute", route)
    .addKeyValue("clientId", clientId)
    .addKeyValue("apiVersion", version)
    .log("deprecated API call");$code$),
    ('api-security-at-the-edge', 1, 'Authenticate at the edge, authorize inside', $body$A gateway is a good place to terminate TLS, validate tokens, and reject unauthenticated traffic before it reaches expensive services. But fine-grained authorization needs domain knowledge the gateway does not have: which order belongs to this caller, which project may be read, which tenant owns the record. Keep coarse checks at the edge and perform resource ownership checks inside the service that owns the data. Forward verified identity in trusted, signed headers, and ensure external callers cannot set those headers directly. When services are reachable through other paths, validate the token again there. Rule of thumb: the edge decides who you are, the service decides what you may do.$body$, $code$@PreAuthorize("@orders.canEdit(#id, authentication.name)")
public Order updateOrder(long id, OrderUpdate update) {
    // Ownership is a domain decision, not a gateway one
    return orders.save(id, update);
}$code$),
    ('api-security-at-the-edge', 2, 'Separate scopes from roles', $body$Scopes describe what an application was granted for a token; roles describe what a person may do inside an organization. Keep scope checks coarse and stable, for example orders.read and payments.write, because scopes sit on the contract boundary and integration partners depend on them. Map roles to permissions in one service-side component, since roles are local policy that changes more often than the API surface and must not leak into every endpoint definition. A request may carry both, so evaluate each explicitly instead of assuming one implies the other. Rule of thumb: scopes gate features, roles gate people.$body$, $code$Set<String> granted = token.scopes();
if (!granted.contains("payments.write")) {
    throw new ForbiddenException("missing scope payments.write");
}
// Roles map to permissions inside the service,
// not in the published wire contract.$code$),
    ('api-security-at-the-edge', 3, 'Constrain every client-controlled input', $body$Every parser and buffer is an attack surface, so cap request body size, header size, JSON nesting, string length, and collection length at the edge, where oversized or malformed payloads can die cheaply. Reject unexpected content types, bound XML entity expansion where XML is unavoidable, and validate uploads by content rather than file extension. A web application firewall absorbs known attack patterns and noisy scanners, but it is a coarse filter, not a substitute for validation inside services, since internal callers bypass the edge entirely. Read and idle timeouts neutralize slow drip attacks. Rule of thumb: define a maximum for everything a client controls, and enforce it in more than one place.$body$, $code$# Reject oversized requests before controllers run
server.max-http-request-header-size=16KB
server.tomcat.max-swallow-size=2MB
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=12MB$code$),
    ('api-documentation-and-developer-experience', 1, 'Generate reference docs from the contract', $body$Hand-written reference pages drift within weeks. Generate endpoint references, schemas, and examples from the OpenAPI document, the GraphQL schema, or the proto files so documentation changes in the same commit as behavior changes. Then add the meaning a generator cannot infer: what each operation is for, when to choose it, which errors are retryable, and realistic example values. Publish versioned documentation next to each API version and keep retired versions reachable for stragglers. Build docs in continuous integration so broken references fail fast. Rule of thumb: the generated part must build automatically, the human part must explain why the endpoint exists.$body$, $code$# CI step: fail the build when docs do not build
- name: Generate reference docs
  run: npx --yes @redocly/cli build-docs openapi.yaml

- name: Upload docs
  uses: actions/upload-artifact@v4
  with:
    path: openapi.html$code$),
    ('api-documentation-and-developer-experience', 2, 'Quickstarts that reach a working call', $body$Developers judge an API within the first ten minutes, and most abandon one that cannot produce a successful response quickly. A quickstart should take a reader from zero to a working call with copy-pasteable snippets, starting with curl so no SDK ambiguity is involved, then showing one SDK path. Cover how to obtain credentials, what the first error looks like, and where limits are documented. Keep text short, keep code runnable, and test the quickstart in continuous integration so it cannot rot silently. Link the obvious next step: a sandbox, a webhook guide, or a pagination recipe. Rule of thumb: a quickstart that takes longer than fifteen minutes usually signals product complexity, not documentation weakness.$body$, $code$curl -X POST https://api.example.com/v1/orders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reference": "ORD-1007", "quantity": 2}'

# Expect 201 Created and a Location header.
# The same call works in the sandbox with seed data.$code$),
    ('api-documentation-and-developer-experience', 3, 'Sandboxes and changelogs readers act on', $body$A sandbox with seed data lets consumers experiment without polluting production or opening support tickets; make it resettable, clearly labeled as non-production, and safe to share. For changelogs, write entries a consumer can act on: what changed, who is affected, what to do, and by when. Group entries by compatibility impact rather than by internal team, and link each one to the relevant contract diff. Automated feeds help power users, but a short curated summary is what everyone actually reads. Announce deprecations both in the changelog and through response headers, then confirm adoption with usage data. Rule of thumb: if a consumer must write in to ask whether a change affects them, the changelog failed.$body$, $code$## 2026-03-01 - Orders API v1.4

- Added: estimatedDelivery on Order (additive, no action needed)
- Deprecated: GET /v1/orders/legacy (removal 2026-09-01)
- Breaking: none in this release$code$)
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
    'rest-resource-modeling', 'openapi-first-design', 'api-versioning-strategies',
    'api-error-contracts', 'api-idempotency-and-safety', 'graphql-schema-design',
    'graphql-in-java-with-spring', 'graphql-security-and-limits',
    'grpc-and-protobuf-basics', 'grpc-in-spring-services',
    'choosing-between-rest-graphql-grpc', 'api-rate-limiting-and-quotas',
    'api-observability-and-analytics', 'api-security-at-the-edge',
    'api-documentation-and-developer-experience'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
