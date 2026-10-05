-- V30 — Data formats and serialization in Java.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('json-with-jackson-basics', 'JSON Processing with Jackson', 'Process JSON with Jackson using data binding or the tree model, and configure the mapper deliberately.', 'Junior', 24, true, 1),
    ('jackson-annotations-and-customization', 'Jackson Annotations and Customization', 'Customize Jackson output with annotations, naming strategies, null policy, and small custom serializers.', 'Mid', 30, true, 1),
    ('jackson-polymorphic-serialization', 'Polymorphic Serialization with Jackson', 'Model polymorphic payloads with type discriminators and an explicit allowlist of subtypes.', 'Mid', 32, true, 1),
    ('json-schema-and-validation', 'JSON Schema and Payload Validation', 'Describe payloads with JSON Schema and validate inbound documents before binding them.', 'Senior', 38, true, 1),
    ('xml-processing-in-java', 'XML Processing in Modern Java', 'Choose between binding and streaming for XML, and harden parsers against external entity attacks.', 'Mid', 30, true, 1),
    ('yaml-for-configuration', 'YAML for Configuration Files', 'Write clear YAML for Spring configuration and Kubernetes manifests while avoiding type coercion traps.', 'Junior', 22, true, 1),
    ('csv-and-tabular-data', 'CSV and Tabular Data Processing', 'Parse delimited files correctly with proper quoting, streaming readers, and explicit encodings.', 'Mid', 30, true, 1),
    ('protocol-buffers-in-java', 'Protocol Buffers in Java', 'Work with generated Protocol Buffer classes, field presence, and strict wire compatibility rules.', 'Mid', 34, true, 1),
    ('avro-and-schema-registry-basics', 'Avro and Schema Registry Basics', 'Version Avro schemas with defaults and compatibility checks, using a registry to coordinate evolution.', 'Mid', 32, true, 1),
    ('choosing-a-serialization-format', 'Choosing a Serialization Format', 'Compare JSON, Protobuf, Avro, and XML on size, evolution, tooling, and operational cost.', 'Senior', 38, true, 1),
    ('object-mapping-between-layers', 'Mapping Objects Between Layers', 'Translate entities to DTOs with manual code or MapStruct instead of coupling layers through shared types.', 'Mid', 30, true, 1),
    ('deserialization-security', 'Deserialization Security in Java', 'Treat deserialization as untrusted work and remove Java native serialization from every boundary.', 'Senior', 40, true, 1),
    ('dates-numbers-and-locale-serialization', 'Dates Numbers and Locale Serialization', 'Serialize timestamps, decimals, and formatted text without locale or precision surprises.', 'Junior', 26, true, 1),
    ('streaming-large-payloads', 'Streaming Large Payloads Safely', 'Handle large JSON and XML documents with streaming parsers, bounded memory, and pagination.', 'Mid', 34, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('json-with-jackson-basics', 1, 'Data binding versus tree model', $body$Jackson offers two ways to work with JSON. Data binding maps payloads onto typed classes with readValue and writeValue, so the rest of the code works with domain types and the compiler helps. The tree model reads into JsonNode, which suits JSON whose shape is not known ahead of time or is deeply nested, at the cost of type safety. Prefer data binding when the payload has a stable contract, and use the tree model for one-off inspection, partial updates, or heterogeneous documents. Avoid converting everything to maps: map-based code pushes casting and null checks into business logic. In production, reuse one configured ObjectMapper; building a new mapper per call wastes caches and risks inconsistent behavior across the service.$body$, $code$ObjectMapper mapper = JsonMapper.builder().build();

record Quote(String sku, long amountCents) {}

Quote quote = mapper.readValue(json, Quote.class);

String text = mapper.writeValueAsString(quote);$code$),
    ('json-with-jackson-basics', 2, 'Reading and writing payloads', $body$Reading uses readValue with either a target class or a TypeReference, and writing uses writeValue or writeValueAsString. The TypeReference matters for generics: List.class loses the element type because of erasure and hands back untyped entries, which usually fails later as a ClassCastException far from the JSON. Wrap read exceptions where the payload is external so callers see a domain error with context rather than a raw parser message. When writing, remember that serialization of every getter can expose fields you did not intend; keep DTOs narrow. Configure one mapper per purpose: an API mapper with your annotations and a tolerant reader if you must accept unknown properties.$body$, $code$record Page(List<Item> items) {}

Page page = mapper.readValue(json, new TypeReference<Page>() {});

String body = mapper.writeValueAsString(new Request("book"));

try {
    mapper.readValue(body, Request.class);
} catch (JsonProcessingException ex) {
    throw new InvalidPayloadException("request", ex);
}$code$),
    ('json-with-jackson-basics', 3, 'Configuration defaults worth knowing', $body$Jackson has behavior built in that surprises teams. By default, binding fails on unknown properties, which catches typos early but breaks consumers when producers add fields; frameworks such as Spring Boot disable that check, so verify the effective configuration. Date and time types need the jackson-datatype-jsr310 module registered, otherwise they serialize as structureless arrays or timestamps that other systems misread. Auto-registering modules with findAndRegisterModules is convenient but order-dependent, so register explicitly in production. Property inclusion, case handling, and feature toggles all belong in one shared, tested configuration. A mapper assembled ad hoc in a utility class becomes an accidental API contract nobody reviews.$body$, $code$ObjectMapper mapper = JsonMapper.builder()
        .addModule(new JavaTimeModule())
        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
        .enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
        .build();

Instant createdAt = mapper.readValue(json, Instant.class);$code$),
    ('jackson-annotations-and-customization', 1, 'Renaming fields with annotations', $body$Annotations let the Java model differ from the wire contract. @JsonProperty renames a property, marks it required for creator binding, and can keep a getter and setter consistent when names differ. That separation is valuable when the external schema uses snake_case or names that clash with Java conventions. Keep annotations close to the boundary DTOs, not on persistence entities, or the external contract will leak into storage concerns. Annotate constructors and creators for immutable types, and remember that required only enforces presence during binding, not meaning. When a field is optional in the schema, model it as Optional or nullable rather than pretending every payload is complete. Renames are contract changes: treat them like any other breaking API edit.$body$, $code$record Customer(
        @JsonProperty("customer_id") String id,
        @JsonProperty(value = "email", required = true) String email) {}

record Update(
        @JsonProperty("display_name") String displayName) {}$code$),
    ('jackson-annotations-and-customization', 2, 'Naming strategies and ignored fields', $body$A naming strategy applies a convention across a class, which beats annotating every field when a whole API uses snake_case or kebab-case. Set it once on the mapper and cover it with a serialization test so a library upgrade cannot silently change wire formats. Use @JsonIgnore for fields that must never cross the boundary, such as internal identifiers or credentials, and @JsonIgnoreProperties to tolerate unknown input fields in tolerant readers. Prefer denying serialization of sensitive fields explicitly rather than relying on access modifiers. On deserialization, ignoring unknown properties is a compatibility decision: it lets producers evolve faster but can silently drop data the consumer was supposed to persist, so document the choice.$body$, $code$ObjectMapper mapper = JsonMapper.builder()
        .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE)
        .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        .build();

record Account(
        @JsonIgnore String internalToken,
        String displayName) {}$code$),
    ('jackson-annotations-and-customization', 3, 'Null handling and custom serializers', $body$Null policy is part of the contract. @JsonInclude can omit nulls globally or per class, which shrinks payloads but forces consumers to distinguish missing from null; if a field is required, omitting it can break their validation. Decide policy per API and test it. Custom serializers handle types that Jackson cannot represent sensibly, such as a value object that must be written as a string or a currency amount with fixed scale. Implement JsonSerializer or JsonDeserializer, register through a module so the mapper stays declarative, and keep the logic small; a serializer that reaches into repositories is a design bug. Custom code on the hot path also deserves a benchmark before it becomes the reason payloads are large.$body$, $code$class MoneySerializer extends JsonSerializer<Money> {
    @Override
    public void serialize(Money value, JsonGenerator gen, SerializerProvider p)
            throws IOException {
        gen.writeString(value.amount() + " " + value.currency());
    }
}

SimpleModule module = new SimpleModule();
module.addSerializer(Money.class, new MoneySerializer());$code$),
    ('jackson-polymorphic-serialization', 1, 'Type info with discriminators', $body$Polymorphism needs a way to identify the concrete type on the wire. @JsonTypeInfo with a property discriminator writes a marker field into each object, while @JsonSubTypes lists the known subtypes. The marker approach is explicit and readable, which is exactly what an external contract needs. Avoid include settings that wrap objects in extra arrays or rely on Java class names; both make payloads awkward and tie wire format to package layout. Pick a property name such as type and keep it stable, because consumers will branch on it. Also validate what arrives: a discriminator is untrusted input like everything else. When a hierarchy is closed, model it as such so new subtypes require a deliberate contract change.$body$, $code$@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes({
        @JsonSubTypes.Type(value = CardPayment.class, name = "card"),
        @JsonSubTypes.Type(value = TransferPayment.class, name = "transfer")
})
sealed interface Payment permits CardPayment, TransferPayment {}$code$),
    ('jackson-polymorphic-serialization', 2, 'Registering subtypes explicitly', $body$Subtypes can be declared with annotations or registered on a module with registerSubtypes. Module registration keeps knowledge of the hierarchy in one place and works when the base type lives in a library you cannot annotate. An explicit registration also limits what the mapper will construct: only listed types are accepted, which is the defensive default. Deserialization of polymorphic input should never guess; when a discriminator is unknown or missing, fail with a clear error rather than falling back to a default type. In code review, treat the set of accepted subtypes as a security-relevant allowlist. Document which types are wire-visible and why, so a later refactoring does not silently change what the API accepts.$body$, $code$SimpleModule module = new SimpleModule();
module.registerSubtypes(
        new NamedType(CardPayment.class, "card"),
        new NamedType(TransferPayment.class, "transfer"));

ObjectMapper mapper = JsonMapper.builder()
        .addModule(module)
        .build();$code$),
    ('jackson-polymorphic-serialization', 3, 'Evolution and safe defaults', $body$Discriminator values are public contract. Renaming a Java class is usually harmless until it changes a logical type name that clients send, so prefer explicit names in @JsonSubTypes rather than deriving them from the class. Adding a subtype is compatible for writers but breaks older readers that reject unknown values, which argues for tolerant consumers and strict producers. Removing a subtype is a breaking change; deprecate and observe traffic first. Never enable default typing on data from outside the trust boundary: it lets the payload choose arbitrary classes to instantiate, which is a well-known remote code execution hazard. If you need polymorphism, use an allowlisted hierarchy, and keep Java type names out of the payload.$body$, $code$@JsonSubTypes.Type(value = CardPayment.class, name = "card")
record PaymentEnvelope(String type, JsonNode body) {}

JsonNode payload = mapper.readTree(request);
String type = payload.path("type").asText();

// Old readers reject unknown type values, so add subtypes carefully$code$),
    ('json-schema-and-validation', 1, 'Schema as an explicit contract', $body$A JSON Schema describes allowed structure: required properties, types, formats, ranges, and additional property policy. Unlike a DTO, it is language-neutral, so consumers in other stacks and API catalogs can consume it, and it can be reviewed as data. Schemas are versioned documents; publishing them alongside the API makes validation expectations visible instead of implied by Java annotations. The main trade-off is duplication: a schema and a DTO can drift, so generate one from the other or add a test that derives a sample payload and validates it. Keep schemas focused on interoperability rules; business invariants such as credit limits still belong in code, where they can use the database and produce domain errors rather than generic validation failures.$body$, $code${
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["orderId", "totalCents"],
  "properties": {
    "orderId": { "type": "string", "minLength": 1 },
    "totalCents": { "type": "integer", "minimum": 0 }
  },
  "additionalProperties": false
}$code$),
    ('json-schema-and-validation', 2, 'Validating inbound documents', $body$Validate before binding when the payload is untrusted, so malformed structure fails with a precise path such as items[3].price instead of an obscure binding error. Most validators report a list of violations; translate them into your error model with field paths and stable codes, and cap how much detail you return to clients. Schema validation proves shape, never authorization or business correctness, so it complements rather than replaces checks against current state. For performance, cache compiled schemas at startup; parsing a schema per request is a hidden latency source. Decide whether additional properties are allowed: rejecting all extensions is strict and brittle, while allowing them silently can hide typos, so pick per API and document it.$body$, $code$JsonSchema schema = factory.getJsonSchema("resource:/schemas/order.json");
Set<ValidationMessage> errors = schema.validate(node);

if (!errors.isEmpty()) {
    throw new InvalidPayloadException(errors);
}$code$),
    ('json-schema-and-validation', 3, 'Schema registries and versions', $body$Registries centralize schemas for systems where producers and consumers deploy independently, especially streaming platforms. A registry assigns an identifier to each schema version, and messages reference that identifier so readers can fetch the writer schema and decode. Registries usually enforce compatibility modes before accepting a new version, which turns evolution rules into an automated gate instead of a review convention. For HTTP APIs, the schema often lives in the API description, which plays a similar role. Either way, treat schema changes as versioned artifacts: review them, keep old versions available for as long as old data exists, and never mutate a published schema in place, because older readers may still depend on exactly that shape.$body$, $code${
  "subject": "orders-value",
  "schema": "resource:/avro/order.avsc",
  "compatibility": "BACKWARD",
  "normalize": true
}$code$),
    ('xml-processing-in-java', 1, 'From JAXB to current options', $body$JAXB was removed from the JDK in Java 11, so XML binding today means adding the Jakarta XML Bind API and an implementation, or choosing another library such as Jackson XML. That is not just a packaging change: the ecosystem split means examples and tutorials from the JAXB era often target classes that no longer exist. Data binding still makes sense for small, stable documents with a known schema, and annotations feel familiar. For large or unpredictable XML, binding the whole document into memory is the wrong default. Decide deliberately between binding, streaming, and plain DOM, and pin the binding library version; XML libraries are a common source of security advisories, so upgrades are part of maintenance rather than optional.$body$, $code$// Java 11 and later: JAXB is no longer part of the JDK
XmlMapper mapper = XmlMapper.builder()
        .addModule(new JakartaXmlBindAnnotationModule())
        .build();

Order order = mapper.readValue(xml, Order.class);$code$),
    ('xml-processing-in-java', 2, 'Streaming with the StAX pull parser', $body$StAX reads XML as a stream of events and lets the caller pull the next token, which keeps memory proportional to the document depth rather than its size. Use XMLStreamReader to walk to an element of interest and then read only the subtree you need; skipping the rest discards it without building a tree. This is the right tool for large imports and for protocols that embed big payloads. The trade-off is manual state handling: you track element depth and names yourself, and the code reads less like the document structure than a binding would. Encapsulate that state machine in one class with focused tests, or the parser logic will spread through the application. Combine streaming with per-element binding when each item is small.$body$, $code$XMLInputFactory factory = XMLInputFactory.newFactory();
XMLStreamReader reader = factory.createXMLStreamReader(input);

while (reader.hasNext()) {
    int event = reader.next();
    if (event == XMLStreamConstants.START_ELEMENT
            && "item".equals(reader.getLocalName())) {
        processItem(reader);
    }
}$code$),
    ('xml-processing-in-java', 3, 'Defending against XXE attacks', $body$XML parsers resolve external entities by default in many configurations, which allows a crafted document to read local files or contact internal services. Harden every factory: disallow DOCTYPE declarations, set ACCESS_EXTERNAL_DTD and ACCESS_EXTERNAL_SCHEMA to empty strings, and disable entity expansion and external parameter entities. These settings apply to DocumentBuilderFactory, SAXParserFactory, XMLInputFactory, and transformer factories, each configured separately, which is why a shared hardened factory helper is worth maintaining. Also bound entity expansion to prevent denial of service through nested entities. Validation against a schema does not make a parser safe; hardening does. Add a regression test that feeds a document with an external entity and asserts rejection, so a dependency upgrade cannot quietly reopen the hole.$body$, $code$DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
factory.setXIncludeAware(false);
factory.setExpandEntityReferences(false);$code$),
    ('yaml-for-configuration', 1, 'YAML in applications and manifests', $body$YAML is a human-friendly configuration format used by Spring Boot application files, CI pipelines, and Kubernetes manifests. Indentation is structural, so spaces matter and tabs are invalid; a misplaced key silently changes meaning or fails to parse. Prefer lists of small documents over one giant file, and keep environment-specific values out of the base file. Because YAML is easy to write quickly, teams accumulate duplicated blocks and drift between environments. Treat configuration as code: review it, lint it, and test that it parses. In Spring Boot, profile-specific documents and property placeholders cover most needs, while plain YAML for manifests should be generated from templates instead of copied. The parser is permissive in places, so a validation step catches mistakes before deployment.$body$, $code$spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  jpa:
    open-in-view: false$code$),
    ('yaml-for-configuration', 2, 'Anchors aliases and merge keys', $body$Anchors and aliases remove duplication: define a block with &name, then reuse it with *name. A merge key, written as <<, pulls the keys of an aliased mapping into another mapping so a small override can extend a shared default. These features help in Kubernetes manifests where several containers share probes or resources. Two cautions apply. First, aliases can create cycles and blow up expansion, and some parsers limit alias expansion for that reason. Second, merge keys are a YAML 1.1 convenience, not part of the 1.2 core schema, so support varies between libraries and strict validators; SnakeYAML, used by Spring Boot, supports them. When portability matters, prefer templating over clever YAML tricks.$body$, $code$defaults: &defaults
  restartPolicy: Always
  imagePullPolicy: IfNotPresent

api:
  <<: *defaults
  image: javacraft/api:1.4.2$code$),
    ('yaml-for-configuration', 3, 'Type coercion pitfalls and safety', $body$Unquoted scalars are parsed by type, and the rules differ between YAML versions and libraries. The classic trap is a country code that looks boolean: in YAML 1.1 parsers, no, yes, on, and off are booleans, so a value of NO for Norway becomes false in a country-code field; the 1.2 core schema dropped those booleans, but widely used Java parsers still accept them. Leading zeros can turn a code into a number, and version strings become decimals. Quote anything that is semantically a string: identifiers, versions, and codes. For safety, avoid deserializing YAML into arbitrary Java types from untrusted sources, be cautious with custom tags, and prefer binding to explicit typed configuration classes so unexpected keys fail loudly.$body$, $code$country: "NO"
version: "1.10"
ratio: 0.5
enabled: true

record Settings(String country, String version, double ratio) {}$code$),
    ('csv-and-tabular-data', 1, 'Quoting and escaping rules', $body$The CSV format is described by RFC 4180, and its rules exist because plain text delimiters are ambiguous. A field containing the delimiter, a quote character, or a line break must be wrapped in double quotes, and embedded quotes are written as two quotes. Splitting lines on commas breaks the moment any field contains a comma or a multiline address, which is common in real exports. Use a library such as Apache Commons CSV or OpenCSV that implements the rules rather than writing a parser. Decide up front how you treat a header row, empty fields versus missing fields, and trailing delimiters. Consistency matters more than elegance: tests that round-trip data with commas, quotes, newlines, and Unicode expose parser bugs early.$body$, $code$try (CSVParser parser = CSVFormat.RFC4180.builder()
        .setHeader()
        .setSkipHeaderRecord(true)
        .build()
        .parse(reader)) {
    for (CSVRecord record : parser) {
        process(record.get("email"));
    }
}$code$),
    ('csv-and-tabular-data', 2, 'Streaming large delimited files', $body$Delimited files can be huge, and reading all lines into memory guarantees trouble when a nightly export grows. CSV libraries expose row iterators, so you can read one record at a time, transform it, and write the output incrementally. Keep the pipeline streaming end to end: accumulate only aggregates, not rows. Batch database writes while streaming instead of collecting entities, and flush writers in chunks. Bound record size so a malformed line cannot allocate unbounded memory, and count skipped rows rather than silently dropping them. For imports, record line numbers in errors so operators can fix the source file. When the file must be uploaded, accept it as a stream and process it as it arrives rather than storing a temporary copy.$body$, $code$try (Reader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8);
        CSVParser parser = CSVFormat.RFC4180.parse(reader)) {
    for (CSVRecord record : parser) {
        writer.write(record);
        if (++count % 500 == 0) writer.flush();
    }
}$code$),
    ('csv-and-tabular-data', 3, 'Encodings and dialect conventions', $body$Text encoding causes subtle production bugs: an export written as UTF-8 and read as windows-1252 turns accented names into mojibake, and a byte order mark at the start can corrupt the first header name. Always specify the charset explicitly when reading and writing, prefer UTF-8, and write a test with non-ASCII data. Delimiters also vary by convention and locale: many spreadsheets in European locales use semicolons because the comma is the decimal separator, and some tools use tabs instead. Do not guess from the file extension; sniff the first line or require configuration, then fail with a clear message when the dialect is unsupported. Document the export contract, including encoding, delimiter, header row, and quoting, so downstream systems can automate ingestion.$body$, $code$Charset charset = StandardCharsets.UTF_8;
CSVFormat format = CSVFormat.DEFAULT.builder()
        .setDelimiter(';')
        .setQuote('"')
        .setHeader()
        .build();

try (Reader reader = Files.newBufferedReader(path, charset)) {
    CSVParser parser = format.parse(reader);
}$code$),
    ('protocol-buffers-in-java', 1, 'Generated messages and builders', $body$Protocol Buffers start from a .proto definition and generate immutable Java classes with builders. You define messages and field numbers, generate code during the build, and work with getters, builders, and serialization methods; nothing is hand-written. Field numbers are the real contract, not names: they identify data on the wire, so they can never be changed or reused once released. Generated classes are verbose but fast, allocation-conscious, and validated at compile time across languages, which is why protobuf fits internal service calls and high-volume pipelines. Keep generated sources out of version control, pin the compiler and runtime versions to compatible releases, and treat the proto files as reviewable API artifacts. Never edit generated classes; regenerate them instead.$body$, $code$OrderProto.Order order = OrderProto.Order.newBuilder()
        .setOrderId("o-42")
        .setTotalCents(1599L)
        .addAllLines(lines)
        .build();

byte[] bytes = order.toByteArray();
OrderProto.Order parsed = OrderProto.Order.parseFrom(bytes);$code$),
    ('protocol-buffers-in-java', 2, 'Field presence and defaults', $body$In proto3, scalar fields have no explicit presence by default: an unset integer reads as zero and an unset string as empty, so you cannot distinguish absent from deliberately set to a default. That matters for partial updates, where absent means leave unchanged. Options exist: mark a field optional to get explicit presence tracking, use wrapper message types, or model the field so its default is not a valid value. Message-typed fields always have presence, which is one reason nested structures behave more predictably. Design update semantics explicitly and document which fields support partial updates. When presence tracking is essential, prefer optional where your runtime supports it, and test the absent-value path; it is where partial update bugs live.$body$, $code$OrderProto.Order.Builder builder = OrderProto.Order.newBuilder()
        .setOrderId("o-42");

OrderProto.Order order = builder.build();

// totalCents is not set: proto3 reads the scalar as 0, not as absent
boolean hasDiscount = order.hasDiscount();$code$),
    ('protocol-buffers-in-java', 3, 'Wire compatibility rules', $body$Protobuf evolution has strict rules. Adding a field is compatible because old readers ignore unknown fields and the wire format preserves them for forwarding. Changing a type, reusing a removed field number, or changing a field from singular to repeated breaks readers in ways that may go unnoticed until data is lost. Reserve numbers and names of deleted fields in the .proto file so a future change cannot accidentally reuse them. Unknown fields are retained on parse and copied when the message is re-serialized, which keeps intermediaries honest. Removing a field is safe for readers only if no writer still sends it; rename with a new number instead of changing meaning. Wire compatibility is a review checklist item, not something to discover after deployment.$body$, $code$message Order {
  string order_id = 1;
  int64 total_cents = 2;
  reserved 3, 4;
  reserved "legacy_status";
}

// Add new fields with new numbers; never reuse 3 or 4$code$),
    ('avro-and-schema-registry-basics', 1, 'Schemas that travel with data', $body$Avro stores records in a compact binary format and always associates them with a schema written in JSON. Unlike protobuf, the schema does not need to be compiled into the reader; the writer schema can travel with the data or be fetched by identifier. That property makes Avro popular for data pipelines and file formats where many producers write into shared storage. A field-level schema defines types, defaults, and documentation, and tools can generate Java classes from it. The trade-off is runtime cost and complexity: reading requires schema resolution, and mistakes in schema handling surface at runtime rather than compile time. Keep schemas versioned and reviewed as carefully as database migrations, because downstream consumers depend on their exact shape.$body$, $code${
  "type": "record",
  "name": "Order",
  "fields": [
    { "name": "orderId", "type": "string" },
    { "name": "totalCents", "type": "long" }
  ]
}$code$),
    ('avro-and-schema-registry-basics', 2, 'Evolution and schema resolution', $body$Avro handles evolution through schema resolution: the reader uses its own schema plus the writer schema to decode data. Adding a field works when it has a default, because old data simply lacks the value. Removing a field works when it had a default, because readers can synthesize it. Renaming should use aliases so old names still resolve. Type promotions are limited and must be planned, for example int to long. These rules are stricter than they look, so treat a schema change as a compatibility decision with a test that decodes data written by the previous version. Defaults are not cosmetic: they are the mechanism that makes forward and backward compatibility possible, and a field added without a default will break consumers reading older records.$body$, $code${
  "type": "record",
  "name": "Order",
  "fields": [
    { "name": "orderId", "type": "string" },
    { "name": "totalCents", "type": "long" },
    { "name": "currency", "type": "string", "default": "EUR" }
  ]
}$code$),
    ('avro-and-schema-registry-basics', 3, 'Working with a schema registry', $body$A schema registry assigns an integer identifier to each registered schema and stores compatibility rules. Producers register a schema once, then send the identifier with each message, letting consumers fetch the writer schema to decode without embedding it in every record. Registries usually support compatibility levels such as backward, forward, and full, and reject a new schema version that violates the configured level, which catches mistakes in CI rather than in production. Practical advice: register schemas as part of the build, treat registration like a migration with review, and keep old versions available while old data exists. The registry becomes a critical dependency, so plan for outages: cache schemas locally and fail predictably rather than dropping messages.$body$, $code$SchemaRegistryClient client = new CachedSchemaRegistryClient(url, 100);
int id = client.register("orders-value", new AvroSchema(schema));
Schema writer = client.getById(id);

GenericRecord record = new GenericData.Record(writer);
record.put("orderId", "o-42");
record.put("totalCents", 1599L);$code$),
    ('choosing-a-serialization-format', 1, 'Compare on the right axes', $body$Format choice should follow concrete requirements, not preference. Compare payload size, human readability, schema enforcement, evolution support, tooling across languages, and operational overhead. JSON is universal and readable, with moderate size and weak built-in typing. Protobuf and Avro are compact and schema-driven, but need code generation or a registry. XML is verbose yet strong for document-centric data and legacy integrations. Java native serialization has no place across boundaries. Score candidates against real payloads from your system and measure, because compression often erases the difference between JSON and binary formats for network-bound services. The right answer for an internal event stream may differ from the answer for a public API, and both can coexist in one platform.$body$, $code$| Format   | Size     | Readable | Evolution        | Tooling   |
|----------|----------|----------|------------------|-----------|
| JSON     | moderate | yes      | tolerant readers | universal |
| Protobuf | compact  | no       | strict rules     | generated |
| Avro     | compact  | no       | registry checks  | generated |
| XML      | verbose  | yes      | schema-based     | mature    |$code$),
    ('choosing-a-serialization-format', 2, 'Readability versus binary density', $body$Readable formats cost bytes but repay them in debuggability: operators can inspect logs, support can replay requests, and new engineers understand payloads without tooling. Binary formats optimize size, parse speed, and schema enforcement, which matters at high message rates or on constrained networks. That trade-off is not permanent: gzip or brotli make JSON competitive for many workloads, while protobuf remains smaller for high-frequency internal calls. Measure end to end: serialization CPU, network bytes, and latency percentiles all count. Also weigh tooling cost, such as broker-side inspection, dashboards, and on-call debugging. A pragmatic pattern is JSON at public edges and binary inside, with a mapping layer at the boundary, but do not add that layer speculatively; add it when measurements justify the complexity.$body$, $code$long jsonBytes = gzip(testPayload).length;
long protoBytes = protoSerializer.serialize(testEvent).length;

// Compare bytes and serialization CPU on realistic payloads
benchmark("json-gzip", () -> jsonSerializer.serialize(testEvent));
benchmark("protobuf", () -> protoSerializer.serialize(testEvent));$code$),
    ('choosing-a-serialization-format', 3, 'Ruling out Java serialization', $body$Java native serialization ties a payload to class names, descriptors, and version identifiers, so refactoring a class can break stored or in-flight data with confusing errors. It is also the classic vector for deserialization attacks, because reading a stream can instantiate arbitrary graphs and trigger code paths. These two problems are enough to keep it away from every boundary: HTTP, messaging, caches, and files that outlive a deployment. Use JSON, protobuf, or Avro instead, all of which define data independently of Java classes. For the rare internal case, restrict with filters, but treat that as containment, not a solution. Removing serialization is usually a migration: write the new format, keep a compatibility reader for old artifacts, and delete the old path once data has drained.$body$, $code$// Legacy path, not a pattern to copy
try (ObjectInputStream in = new ObjectInputStream(stream)) {
    Object value = in.readObject();
    handle(value);
}
// New payloads use JSON or protobuf instead$code$),
    ('object-mapping-between-layers', 1, 'Separate DTOs from entities', $body$Persistence entities and API payloads change for different reasons. An entity models storage and relationships, while a DTO models a contract. Reusing one class for both couples migrations to API versions and often leaks lazy-loaded graphs, internal identifiers, or sensitive columns into responses. DTOs also let you shape payloads for consumers: flattening, renaming, and omitting fields without persistence tricks. The cost is mapping code, which is real but manageable. Define DTOs near the boundary, keep them immutable where practical, and never expose them to the database layer. When the mapping becomes painful, that is usually a signal about design, such as a read model that serves several consumers, not a reason to merge entity and DTO again.$body$, $code$record OrderDto(String orderId, long totalCents, List<LineDto> lines) {}

OrderDto toDto(Order order) {
    return new OrderDto(
            order.getId().toString(),
            order.getTotalCents(),
            order.getLines().stream().map(this::toLineDto).toList());
}$code$),
    ('object-mapping-between-layers', 2, 'Manual mappers and MapStruct', $body$For small graphs, hand-written mapping is the best tool: explicit code, no surprises, easy to debug, and fast enough at typical scales. When payloads grow, MapStruct generates mapper implementations at compile time from annotated interfaces, so mismatches and missing properties surface as build errors rather than runtime reflection failures. MapStruct requires discipline for nested and collection mappings, and generated code is still code: review the configuration. Reflection-based mappers such as ModelMapper map by convention, which feels quick but hides failures until runtime and struggles with similar field names. Whichever you choose, test mappings with a round-trip test on realistic payloads and keep mapping rules in one layer, not scattered across controllers.$body$, $code$@Mapper
interface OrderMapper {

    OrderDto toDto(Order order);

    LineDto toLineDto(OrderLine line);
}$code$),
    ('object-mapping-between-layers', 3, 'Avoiding mapping over-engineering', $body$Mapping frameworks invite accidental complexity. Do not build a generic mapping engine for three fields or wrap every layer in its own DTO type. Start manual, and introduce a generator when duplication and payload size justify it. Watch for deep mapping costs: copying large object graphs on every request, triggering lazy loads, or mapping entities inside transactions to satisfy the mapper. Partial updates deserve special care; a mapper that writes nulls over unset fields turns a patch into data loss, so model presence explicitly. Keep a convention for direction and nulls, document it, and enforce it with tests. The goal is boring, predictable translation between layers, not a second domain model made of mappers.$body$, $code$OrderDto dto = new OrderDto(
        order.id().toString(),
        order.totalCents(),
        order.lines().stream().map(LineDto::from).toList());

assertThat(dto.lines()).hasSize(2);$code$),
    ('deserialization-security', 1, 'Why native deserialization is risky', $body$Java serialization reconstructs object graphs by invoking class constructors, readObject methods, and resolution hooks during deserialization, which means reading bytes can execute code. Attackers exploit this by supplying a graph assembled from classes on the classpath, so a dangerous gadget chain does not require a bug in your code, only a library that happens to be present. Even without attacks, version skew between writer and reader produces confusing failures. The practical consequences: never accept Java serialized data from outside a fully trusted boundary, and prefer formats that carry data rather than instructions, such as JSON with validated schemas. If a legacy protocol still uses it, contain the exposure and plan the migration, because the risk does not shrink with time.$body$, $code$// A serialized stream can name any class on the classpath
try (ObjectInputStream in = new ObjectInputStream(untrusted)) {
    Object value = in.readObject();
}
// Prefer formats that carry data, not instructions$code$),
    ('deserialization-security', 2, 'Allowlisting with ObjectInputFilter', $body$When Java deserialization cannot be removed immediately, constrain what may be read. ObjectInputFilter, introduced through JEP 290, inspects classes, array lengths, depth, and references during deserialization and returns allowed, rejected, or undecided. Configure a filter on the stream with setObjectInputFilter, or apply a process-wide default through the jdk.serialFilter system property; the more specific the context, the better. Build patterns as an allowlist of exactly the classes you expect, and reject everything else rather than trying to block known-bad names, which is a losing game. Set limits on array size and graph depth to blunt memory-based denial of service. Filters are defense in depth: they reduce risk without making the format safe.$body$, $code$ObjectInputFilter filter = ObjectInputFilter.Config.createFilter(
        "com.javacraft.orders.dto.*;maxdepth=20;maxarray=10000");

ObjectInputFilter.Config.setSerialFilter(filter);

try (ObjectInputStream in = new ObjectInputStream(stream)) {
    in.setObjectInputFilter(ObjectInputFilter.Config.getSerialFilter());
    Object value = in.readObject();
}$code$),
    ('deserialization-security', 3, 'Policy for untrusted input', $body$Write down one rule and enforce it: no native Java deserialization of untrusted input, ever. For other formats, treat parsing as untrusted work: disable polymorphic typing that lets the payload choose classes, harden XML parsers against external entities, bound document size and nesting depth, and validate structure against a schema before binding. Then validate meaning in domain code, because schema-valid data can still be malicious. Keep parser libraries patched, since most historical deserialization incidents trace back to a dependency rather than custom parsing. Log rejected payloads with enough context for investigation but never echo raw input into logs or errors. Finally, review new integrations against this policy; today the boundary usually arrives as a library that quietly enables the unsafe behavior.$body$, $code$JsonNode node = mapper.readTree(request.body());
OrderRequest payload = mapper.treeToValue(node, OrderRequest.class);

validator.validate(node);

// Parse only after policy checks: size, depth, schema, then bind$code$),
    ('dates-numbers-and-locale-serialization', 1, 'ISO-8601 dates on the wire', $body$Dates on the wire need one unambiguous representation, and ISO-8601 is the default answer. An instant with an offset, such as 2026-10-05T13:45:00Z, survives time zones, DST transitions, and distributed systems because it names a point in time. Epoch milliseconds are compact and fast but unreadable in logs and ambiguous about precision: seconds, milliseconds, and nanoseconds all appear in the wild. Pick one format per API and enforce it with configuration and tests; mixing local dates, offsets, and epoch values in one payload is a reliable source of bugs. Include the offset whenever a timestamp is meaningful to a user, and use date-only values for calendar concepts such as billing periods, which are not instants at all.$body$, $code$ObjectMapper mapper = JsonMapper.builder()
        .addModule(new JavaTimeModule())
        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
        .build();

record Event(String id, Instant createdAt, LocalDate billingDate) {}$code$),
    ('dates-numbers-and-locale-serialization', 2, 'Decimal precision in JSON', $body$JSON numbers have no defined precision, and many parsers decode fractional values as IEEE doubles, which cannot represent 0.10 or large monetary values exactly. If a field carries money, quantities, or measurements, bind it to BigDecimal in Java and require the producer to send a decimal literal; Jackson has features such as USE_BIG_DECIMAL_FOR_FLOATS for untyped reading. For interchange, some teams serialize decimal amounts as strings to remove all ambiguity, especially across languages and databases with different precision rules. Whichever representation you choose, define scale explicitly, reject values with unexpected scale, and test rounding at the boundary. Never let a double round-trip silently change a total, because reconciliation failures later are far more expensive than an extra validation rule now.$body$, $code$record Invoice(String id, BigDecimal total, int scale) {}

BigDecimal total = new BigDecimal("1599.00");
assertThat(total.scale()).isEqualTo(2);

String json = mapper.writeValueAsString(new Invoice("i-1", total, 2));$code$),
    ('dates-numbers-and-locale-serialization', 3, 'Locale-independent formatting rules', $body$Formatting must not depend on the machine locale. String.format with %f inserts a decimal comma under locales such as German, which breaks CSV parsing and JSON numbers; date formatters built from patterns still emit localized month and day names unless a locale is set. On the wire, always use ISO formatters or pass Locale.ROOT explicitly, and parse with the same discipline. For user interfaces, the opposite holds: localized formatting is a feature, so keep wire formatting and presentation formatting in separate code paths. A test that runs the suite once with a non-English default locale is cheap insurance, and it also catches sorted ordering differences that stem from collation rules. Locale bugs are invisible until a machine in another region runs the same code.$body$, $code$String wire = String.format(Locale.ROOT, "%.2f", amount);

DateTimeFormatter iso = DateTimeFormatter.ISO_INSTANT;
String producedAt = iso.format(Instant.now());

// Presentation code may and should use the user locale$code$),
    ('streaming-large-payloads', 1, 'Jackson streaming API', $body$The streaming API works at the token level with JsonParser and JsonGenerator, so memory use stays constant regardless of document size. You move the parser with nextToken, read names and values, and interpret structure yourself. That control is valuable for very large payloads, exports, and pipelines that must not buffer, but the code is lower level: depth tracking, error handling, and type conversion are manual. Use it where measurements show binding is too expensive, and keep the state machine in a small, well-tested class. For moderately large documents, binding per element combines safety with bounded memory: stream to each element boundary, bind that subtree to a class, process it, and discard it. Choose the highest-level approach that fits the payload.$body$, $code$try (JsonParser parser = mapper.createParser(input)) {
    while (parser.nextToken() != null) {
        if (parser.currentToken() == JsonToken.START_OBJECT) {
            OrderEvent event = mapper.readValue(parser, OrderEvent.class);
            process(event);
        }
    }
}$code$),
    ('streaming-large-payloads', 2, 'StAX and chunked processing', $body$XML has the same streaming remedy through StAX, where the application pulls events from XMLStreamReader and processes elements as they arrive. A typical pattern walks to a repeated element, binds or parses that subtree, handles it, and skips the rest, keeping memory proportional to one item rather than the file. The same chunked approach works for JSON arrays: parse item boundaries, then hand each chunk to a binder. Chunking also improves failure handling, because a bad item can be logged with its position and skipped while the rest of the payload continues. Bound the chunk size and total processed count so a hostile or corrupt input cannot run forever. Streaming is not just about memory; it shortens time to first result.$body$, $code$XMLStreamReader reader = factory.createXMLStreamReader(input);
while (reader.hasNext()) {
    if (reader.next() == XMLStreamConstants.START_ELEMENT
            && "order".equals(reader.getLocalName())) {
        processOrder(reader);
    }
}$code$),
    ('streaming-large-payloads', 3, 'Memory discipline and paging', $body$Streaming loses its advantage if a later step materializes everything. Avoid readTree on large payloads, do not collect parsed items into a list for convenience, and be careful with convenience APIs that silently buffer. Set explicit limits on request size, document depth, and string length before parsing, then reject oversized input with a clear error instead of letting the allocator hit a wall. Prefer pagination for APIs whose result sets are inherently large: a stable cursor lets clients process in bounded batches and retry individual pages. Reserve whole-document streaming for genuine machine-to-machine exchanges such as exports and imports. Instrument heap and latency in tests with a large fixture, because memory regressions appear only at scale and are much cheaper to catch before production.$body$, $code$// Bound input before parsing, then process in batches
int maxBytes = 5 * 1024 * 1024;
if (size > maxBytes) {
    throw new PayloadTooLargeException(size);
}

long processed = 0;
while (events.hasNext() && processed++ < 10_000) {
    handle(events.next());
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
    'json-with-jackson-basics', 'jackson-annotations-and-customization',
    'jackson-polymorphic-serialization', 'json-schema-and-validation',
    'xml-processing-in-java', 'yaml-for-configuration', 'csv-and-tabular-data',
    'protocol-buffers-in-java', 'avro-and-schema-registry-basics',
    'choosing-a-serialization-format', 'object-mapping-between-layers',
    'deserialization-security', 'dates-numbers-and-locale-serialization',
    'streaming-large-payloads'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
