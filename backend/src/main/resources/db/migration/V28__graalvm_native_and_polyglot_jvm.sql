-- V28 — GraalVM native images and the polyglot JVM.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('startup-time-engineering', 'Startup Time Engineering', 'Measure where startup time goes and apply the tactics that genuinely move it without hurting peak performance.', 'Mid', 30, true, 1),
    ('class-data-sharing-and-appcds', 'Class Data Sharing and AppCDS', 'Use class data sharing and AOT caches to cut JVM startup cost without changing application code.', 'Mid', 32, true, 1),
    ('graalvm-native-image-basics', 'GraalVM Native Image Basics', 'Understand what happens when the closed-world assumption turns bytecode into a standalone native binary.', 'Mid', 28, true, 1),
    ('native-image-with-spring-boot', 'Native Images with Spring Boot', 'Build Spring Boot services as native images with AOT processing, runtime hints, and honest expectations about build cost.', 'Senior', 40, true, 1),
    ('reflection-and-dynamic-features-in-native', 'Reflection and Dynamic Features in Native Images', 'Learn why reflection and resources break under static analysis and how reachability metadata fixes them.', 'Senior', 38, true, 1),
    ('native-image-testing-and-profiling', 'Testing and Profiling Native Images', 'Validate and profile native executables in CI while accounting for their different memory behavior.', 'Senior', 36, true, 1),
    ('jvm-vs-native-tradeoffs', 'JVM vs Native Image Trade-offs', 'Compare JVM and native deployments on startup, memory, throughput, and tooling before committing.', 'Mid', 34, true, 1),
    ('kotlin-for-java-developers', 'Kotlin for Java Developers', 'Get productive with Kotlin from a Java background with practical guidance on the features that matter daily.', 'Junior', 30, true, 1),
    ('kotlin-idioms-that-help-java-teams', 'Kotlin Idioms for Java Teams', 'Adopt Kotlin gradually in mixed-language teams without fragmenting the codebase or the build.', 'Junior', 24, true, 1),
    ('scala-and-jvm-language-overview', 'Scala and JVM Languages Overview', 'Survey Scala 3 and the wider JVM language landscape with clear eyes about ecosystem trade-offs.', 'Junior', 22, true, 1),
    ('jvm-language-interoperability', 'JVM Language Interoperability', 'Call Java from Kotlin, Kotlin from Java, and Scala from anything else without losing debuggability.', 'Mid', 32, true, 1),
    ('jvm-alternatives-today', 'JVM Alternatives Today', 'Compare the JVM runtime options that ship today and know when a different stack is worth adopting.', 'Junior', 26, true, 1),
    ('jvm-ecosystem-and-distributions', 'JVM Ecosystem and Distributions', 'Choose an OpenJDK build for production by matching vendor support, native-image options, and update windows.', 'Junior', 24, true, 1),
    ('long-term-java-strategy', 'Long-Term Java Strategy', 'Build a Java adoption policy across LTS releases that accounts for ecosystem lag and refactoring budgets.', 'Mid', 34, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('startup-time-engineering', 1, 'Where Startup Time Actually Goes', $body$JVM startup interleaves several kinds of work. The runtime reads and parses class files, loads and links them, and runs static initializers. Frameworks then discover configuration through classpath scanning and reflection. After the application is up, the just-in-time compiler still interprets most code until hot methods are profiled and compiled, so the first seconds carry higher latency than steady state. For a large server application that combines a web framework with persistence and serialization libraries, this can take several seconds even on fast hardware. The right first step is to measure, not guess. Rule of thumb: separate class loading cost, framework initialization, and warmup before choosing a tactic, because each has different remedies.$body$, $code$BufferingApplicationStartup startup = new BufferingApplicationStartup(2048);
long start = System.nanoTime();
SpringApplication app = new SpringApplication(ServiceApplication.class);
app.setApplicationStartup(startup);
ConfigurableApplicationContext ctx = app.run(args);
long bootMs = (System.nanoTime() - start) / 1_000_000;
System.out.println("boot ms: " + bootMs);

startup.getSteps().forEach(step -> System.out.println(
    step.getName() + " " + step.getDuration().toMillis() + " ms"));$code$),
    ('startup-time-engineering', 2, 'Costs You Can Remove or Delay', $body$Three contributors dominate typical startup profiles. Class loading and linking scale with the number of classes the framework touches. Eager singleton beans that open connections, warm caches, or scan packages all delay readiness. JIT warmup is the part you cannot remove without changing runtimes, because it is the throughput investment that pays off after traffic arrives. Many teams find that one autoconfigured subsystem, not the entire framework, dominates the profile, so profiling beats assumption. Lazy initialization can skip beans the request path never uses, at the price of paying their cost on a first request and turning startup mistakes into runtime surprises that appear under traffic. Rule of thumb: remove or defer work that is never needed, and treat warmup as the price of peak performance.$body$, $code$spring:
  main:
    lazy-initialization: true
  jmx:
    enabled: false

# Re-measure after each change: lazy initialization moves cost
# to first use and can delay failures until a request arrives.$code$),
    ('startup-time-engineering', 3, 'Tactics That Actually Move the Needle', $body$The reliable levers fall into three groups. Architectural levers narrow component scanning, disable unused auto-configurations, and keep readiness gates from blocking on optional work. Ahead-of-time levers shift class parsing and linking into a training run through class data sharing and AOT caches, and Spring Boot can build an AOT cache into container images on recent JDKs. Runtime levers go further: a native image eliminates JVM warmup for suitable workloads, at the cost of peak throughput and tooling. Each tactic carries a price. Lazy initialization can hide failures until first use, caches must match the deployed classpath and JDK exactly, and native builds are slower to produce. Rule of thumb: apply cheap tactical fixes first, then measure again, because startup budgets are usually won by removing work rather than optimizing it.$body$, $code$# Baseline: measure the unmodified start.
time java -jar app.jar --server.port=8080

# Reuse an archive produced during a training run.
java -XX:ArchiveClassesAtExit=app.jsa -jar app.jar --server.port=8080
java -XX:SharedArchiveFile=app.jsa -jar app.jar$code$),
    ('class-data-sharing-and-appcds', 1, 'How CDS and AppCDS Work', $body$Class data sharing stores the parsed and linked form of classes in an archive that the runtime maps directly into memory. JDK 12 and later ship a default archive covering over a thousand commonly used platform classes, so some form of CDS is already active in every modern JVM even when nobody configured it. Application CDS extends the same mechanism to your classpath: a training run records the classes the application actually loads and produces an archive that later runs reuse. The result is faster startup and, when several processes share one read-only archive, lower total memory. There is no application code change and no behavior change, which is why CDS is one of the safest startup optimizations available. Rule of thumb: treat class data sharing as a free win and enable it before larger interventions.$body$, $code$# Record every class loaded during a training run.
java -XX:DumpLoadedClassList=app.lst -jar app.jar

# Build a static archive from that list, then reuse it.
java -Xshare:dump -XX:SharedClassListFile=app.lst \
     -XX:SharedArchiveFile=app.jsa -cp app.jar
java -Xshare:auto -XX:SharedArchiveFile=app.jsa -jar app.jar$code$),
    ('class-data-sharing-and-appcds', 2, 'Building and Shipping the Archive', $body$An archive is valid only for the exact JDK build and classpath that produced it. A production pipeline should create it on the same image that runs the service, verify that it is actually used, and fail loudly when it is not. Classpath ordering and JAR timestamps matter: a directory on the classpath or a rebuilt snapshot JAR can silently invalidate the archive, and the JVM then starts without sharing. Log class loading with the shared-source output to confirm hits, and start with the mode that refuses to run without the archive rather than quietly degrading. Treat archive creation as a build step with its own verification, not as an optional local tweak. Rule of thumb: if the archive is worth shipping, it is worth a test that proves it is used.$body$, $code$# Verify classes come from the shared archive.
java -Xlog:class+load:file=cds.log \
     -XX:SharedArchiveFile=app.jsa -jar app.jar
grep -c "shared objects file" cds.log

# Fail fast when the archive cannot be used.
java -Xshare:on -XX:SharedArchiveFile=app.jsa -jar app.jar$code$),
    ('class-data-sharing-and-appcds', 3, 'AOT Caches and the Leyden Direction', $body$The ahead-of-time cache delivered in JDK 24 goes beyond CDS by storing classes not only parsed but loaded and linked. A training run records an AOT configuration, a second step creates the cache, and production runs start much faster with it. Reported improvements on a representative server application have been around forty percent of startup time, with cache files occupying tens to hundreds of megabytes on disk. Newer JDKs also simplify cache creation into a single command. Because this area is evolving quickly, pin the JDK version and re-verify the cache on every upgrade instead of assuming format compatibility. Rule of thumb: train with a workload that resembles production, and treat cache creation as a build stage with its own tests.$body$, $code$# Record a training run, then create the cache.
java -XX:AOTMode=record -XX:AOTConfiguration=app.aotconf \
     -cp app.jar com.example.App
java -XX:AOTMode=create -XX:AOTConfiguration=app.aotconf \
     -XX:AOTCache=app.aot -cp app.jar

# Production runs reuse the cache.
java -XX:AOTCache=app.aot -cp app.jar com.example.App$code$),
    ('graalvm-native-image-basics', 1, 'From Bytecode to Standalone Binary', $body$The native-image builder takes your bytecode together with parts of the Java runtime and links them into a single executable. During the build it runs static analysis to decide which classes, methods, and fields can ever be reached, then compiles only those. Code executed during the build is called build time, and code executed in the produced binary is run time; the distinction matters because static initializers that run at build time freeze their values into the image heap. The result is a binary that starts in milliseconds and needs no JVM installed on the target machine. It is a different deployment artifact, not a packaging trick. Rule of thumb: treat the native build as an opinionated compiler whose assumptions must hold for your whole application.$body$, $code$# From sources or from a jar, one builder produces one binary.
native-image HelloWorld
native-image -jar app.jar -o app

# The binary carries the runtime and starts as a plain process.
./app --help$code$),
    ('graalvm-native-image-basics', 2, 'The Closed-World Assumption', $body$Static analysis can only see what is provably reachable, so native-image assumes a closed world at build time: no class outside that analysis will exist at runtime. Dynamic features break this assumption because their targets come from data, such as a class name in configuration or a proxy interface list resolved at runtime. Reflection, dynamic proxies, JNI, serialization, and classpath resources therefore need explicit metadata before the builder includes their targets. This is the defining trade-off of the technology: smaller images and instant startup in exchange for a build that must be told about every dynamic access. Libraries decide whether that cost is acceptable, since a framework that reflects freely needs extensive metadata. Rule of thumb: the more reflective a dependency, the more metadata and testing it will demand.$body$, $code$// Constant arguments are resolved during the build.
Class<?> lenient = Class.forName("java.lang.String");

// Computed names need reachability metadata instead.
String name = config.get("parser.class");
Class<?> parser = Class.forName(name);$code$),
    ('graalvm-native-image-basics', 3, 'When Native Images Are a Fit', $body$Native images fit workloads where startup latency or footprint dominates: command line tools, serverless functions with cold starts, scale-to-zero services, and dense container fleets where per-instance memory is real money. They fit less well when peak throughput from a fully warmed JIT matters more than startup, when the stack depends on runtime bytecode generation or dynamic agents, or when the build pipeline cannot absorb minutes of compilation and high build memory. Library support usually decides the outcome, because an unmaintained dependency without reachability metadata can stall an otherwise ideal candidate. Prototype with real dependencies early rather than benchmarking a hello world program. Rule of thumb: check ecosystem support for your exact stack before committing to native delivery, and keep the JVM build available as a fallback.$body$, $code$# A small runtime image: the executable carries its own runtime.
FROM gcr.io/distroless/base-debian12
COPY target/app /app
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]$code$),
    ('native-image-with-spring-boot', 1, 'Spring AOT Processing Explained', $body$On the JVM, Spring parses configuration classes and builds bean definitions during application startup. For a native image that work moves to build time: the AOT engine runs the context up to the point where bean definitions exist, then generates source code that registers those definitions directly and avoids reflection at runtime. Generated sources land under target/spring-aot/main/sources with Maven and build/generated/aotSources with Gradle, and they are readable enough to inspect when a bean behaves unexpectedly. Bean instances are not created during the AOT phase, so constructors and connection pools do not run at build time. Rule of thumb: when a bean is missing or misconfigured in a native image, read the generated registration code before assuming a reflection problem.$body$, $code$<build>
    <plugins>
        <plugin>
            <groupId>org.graalvm.buildtools</groupId>
            <artifactId>native-maven-plugin</artifactId>
        </plugin>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>$code$),
    ('native-image-with-spring-boot', 2, 'Runtime Hints for Your Code', $body$When your own code reflects at runtime, Spring cannot infer that from the source, so you register runtime hints that feed both the AOT engine and the native-image builder. A RuntimeHintsRegistrar declares reflective access, resource patterns, and proxy interfaces, and an annotation such as ImportRuntimeHints activates it on a configuration class. Nested configuration property classes that are not inner classes also need explicit annotation to remain bindable in a native image. A hint that is never exercised is a guess, so cover the reflective path in a native test. Rule of thumb: register the narrowest hint that works, because broad hints bloat the image and can hide genuine mistakes until a path fails in production.$body$, $code$public class ReflectionHints implements RuntimeHintsRegistrar {
    @Override
    public void registerHints(RuntimeHints hints, ClassLoader loader) {
        hints.reflection().registerType(Customer.class,
            MemberCategory.INVOKE_PUBLIC_METHODS);
        hints.resources().registerPattern("templates/*.html");
    }
}
// Activate with @ImportRuntimeHints(ReflectionHints.class)$code$),
    ('native-image-with-spring-boot', 3, 'Libraries, Build Cost, and Expectations', $body$The practical ceiling for a Spring Boot native image is set by its dependency graph. Spring Boot and many mainstream libraries ship the metadata and AOT support needed to work, but libraries that generate bytecode at runtime, rely on unregistered dynamic proxies, or use wide reflection remain problematic. Check current Spring Boot and GraalVM documentation for known limitations before upgrading, because support changes between releases. Expect builds measured in minutes rather than seconds, with high peak memory and a pinned GraalVM version, so native compilation deserves its own builder and pipeline stage with a JVM build kept green as fallback. Rule of thumb: budget native build time and memory explicitly, and never make the native pipeline the only way to ship.$body$, $code$# Host build with the native build tools.
./mvnw -Pnative native:compile
./target/demo

# Or a container image via the native buildpack.
./mvnw -Pnative spring-boot:build-image$code$),
    ('reflection-and-dynamic-features-in-native', 1, 'Why Reflection Breaks Under Static Analysis', $body$Static analysis follows code paths it can prove, but reflection turns a string into a member access at runtime, so the builder cannot know which target to include. The binary then throws ClassNotFoundException, NoSuchMethodException, or a missing resource error where HotSpot worked, often only in a rare path that tests never covered. Resources fail for a related reason, because only files known at build time are bundled. Dynamic proxies need every interface listed, JNI needs its native methods registered, and serialization needs constructors and classes declared. None of this is a bug; it is the contract of a closed world. Rule of thumb: audit runtime reflection when planning a native migration, starting with frameworks and serialization boundaries.$body$, $code$// These work on the JVM but need metadata in a native image.
String text = Files.readString(Path.of("config/limits.json"));
Class<?> type = Class.forName("com.acme.CustomMapper");
Object mapper = type.getConstructor().newInstance();
Method load = type.getMethod("load", String.class);
load.invoke(mapper, text);$code$),
    ('reflection-and-dynamic-features-in-native', 2, 'Collecting Reachability Metadata', $body$The tracing agent solves the discovery problem. Run the application on a JVM with the agent attached, exercise realistic paths, and let it write JSON metadata describing reflection, resources, proxies, and serialization usage. Run several scenarios and merge the results, because the agent records only what was executed. Generated files belong in a META-INF/native-image directory on the classpath, and the builder picks them up automatically. Review the output rather than trusting it blindly, since classes that are reachable only from tests become permanent image content. Metadata is production configuration: keep it in version control, review changes, and delete entries when the reflective call disappears. Rule of thumb: coverage of the agent run determines the quality of the metadata it produces.$body$, $code$# Record dynamic feature usage during a realistic JVM run.
java -agentlib:native-image-agent=config-output-dir=target/agent \
     -jar app.jar

# Merge additional runs that exercise other paths.
java -agentlib:native-image-agent=config-merge-dir=target/agent \
     -jar app.jar --scenario=import$code$),
    ('reflection-and-dynamic-features-in-native', 3, 'Debugging Missing Registrations', $body$Diagnose failures by reproducing the missing class, method, or resource from the stack trace, then decide whether the fix belongs in a hint, a metadata file, or a code change that removes the dynamic access entirely. Newer GraalVM releases can make problems visible earlier: exact reachability metadata mode checks registrations instead of silently returning empty results, and a missing-registration reporting mode can warn or exit so gaps surface in tests rather than production. A small metadata entry registering a type with all declared constructors and public methods often fixes a JSON mapper call. Prefer constant arguments in reflective calls wherever the code allows, because constants are resolved at build time without any metadata. Rule of thumb: make tests fail on missing registrations and keep hints close to the code that needs them.$body$, $code$# Report unregistered dynamic access instead of failing late.
native-image --exact-reachability-metadata -jar app.jar

# reachability-metadata.json
{
  "reflection": [
    {
      "type": "com.acme.CustomMapper",
      "allDeclaredConstructors": true,
      "allPublicMethods": true
    }
  ]
}$code$),
    ('native-image-testing-and-profiling', 1, 'Testing the Executable, Not the JVM', $body$A native executable is a different runtime artifact, so JVM tests prove less than teams hope. Build tool integrations can compile a test suite into a native executable and run it, which catches missing metadata and build-time initialization mistakes, but native test compilation is expensive. Most teams keep the full unit suite on the JVM and run a focused integration suite natively against the real executable. That suite must exercise every path that reflects or loads resources at least once, because untested dynamic paths fail only in production. Assert on observable behavior, including readiness and startup probes. Rule of thumb: JVM tests for logic and speed, native tests for integration, metadata coverage, and configuration binding.$body$, $code$# Compile and run focused tests as a native executable.
./mvnw -Pnative test
./gradlew nativeTest

# Smoke test the shipped binary.
./target/app --version
curl -fsS localhost:8080/health$code$),
    ('native-image-testing-and-profiling', 2, 'Profiling and Flight Recorder Support', $body$Native executables are ordinary processes, so system profilers, performance counters, and tools like perf work without any JVM awareness. For Java-level insight, GraalVM supports JDK Flight Recorder events when the image is built with monitoring enabled; start a recording at the usual runtime flag and analyze the file with standard tooling. Not every HotSpot feature is available in the same form, and JFR support in native images has limitations compared with the JVM, so validate what a recording actually contains. Profile-guided optimization, where the distribution supports it, can feed recorded profiles back into the build to improve throughput. Debug symbols and readable stack traces need explicit build options. Rule of thumb: instrument the workload like any native service, then add JFR where Java-level detail is genuinely needed.$body$, $code$# Build with monitoring support, then record a real workload.
native-image --enable-monitoring=jfr -jar app.jar
./app -XX:StartFlightRecording=filename=recording.jfr

# Inspect the recording with the standard JDK tooling.
jfr summary recording.jfr
jfr print --events jdk.ExecutionSample recording.jfr$code$),
    ('native-image-testing-and-profiling', 3, 'Memory Footprint and Sizing', $body$Native executables typically start with much smaller resident memory than a JVM process, because there is no interpreter, JIT compiler, or metaspace. They still allocate a Java heap, thread stacks, and internal structures outside it, so the footprint is smaller rather than free. GraalVM derives heap defaults from the machine configuration, and the default collector favors footprint over pause times, with G1 available on some platforms and editions for lower pauses. Container limits change what the process sees, so test with the memory limit you deploy with rather than the build machine configuration. Rule of thumb: measure resident set and heap together under realistic load, and set an explicit maximum heap inside containers.$body$, $code$# Compare resident set of both deployment shapes under load.
ps -o rss= -p $(pgrep -f "java -jar")
ps -o rss= -p $(pgrep -f ./app)

# Give the image an explicit heap ceiling for a container.
./app -Xmx512m$code$),
    ('jvm-vs-native-tradeoffs', 1, 'Startup and Memory Wins Are Real', $body$The strongest case for native images is what happens before any request arrives. A JVM service may need seconds to become ready, while a native executable often does it in a fraction of that time, and its idle memory is a fraction of a JVM process. That combination changes what you can build: per-request function instances, scale-to-zero deployments that wake quickly, command line tools users tolerate, and dense packing where every hundred megabytes saved is real money. These wins are consistent and measurable across frameworks, not marketing claims. The catch is that they describe cold behavior; once traffic is flowing the comparison changes. Rule of thumb: quantify startup and idle footprint first, because those are the numbers native images reliably improve.$body$, $code$# Time to first healthy response, warm and cold.
time curl -fsS localhost:8080/actuator/health

# Resident memory after the same warmup sequence.
ps -o rss= -p $(pgrep -f "java -jar")
ps -o rss= -p $(pgrep -f ./app)$code$),
    ('jvm-vs-native-tradeoffs', 2, 'Peak Throughput and Tooling Trade-offs', $body$A long-running JVM invests in profile-guided optimization and speculative inlining that can beat a statically compiled image on sustained throughput, and features such as runtime class generation, attach agents, and full diagnostics remain richer on HotSpot. Native builds are also slower and hungrier to produce, and an image cannot load arbitrary bytecode or attach most agents after startup. Meanwhile the JVM keeps improving its own startup and memory story with class data sharing, AOT caches, and modern collectors, closing part of the gap for services that run for hours. Rule of thumb: choose native images for cold paths and constrained footprints, and choose the JVM when peak sustained throughput, dynamic behavior, and deep tooling matter most.$body$, $code$# Build both shapes from the same source tree.
./mvnw -Pnative native:compile    # fast start, low idle memory
./mvnw spring-boot:build-image    # long-lived, peak throughput

# Compare with the same workload and warmup.
wrk -t4 -c64 -d60s http://localhost:8080/orders$code$),
    ('jvm-vs-native-tradeoffs', 3, 'Ecosystem Maturity and Decision Rules', $body$Native image support is years younger than the JVM, so maturity varies by library. Mainstream frameworks and many web, persistence, and messaging stacks work, while niche libraries may need metadata you maintain yourself, and some frameworks still behave differently in native mode. Vendors differ in which GraalVM builds they ship and support, which affects how long fixes take to reach your platform. The decision is rarely permanent for a company and often per service, so the same organization can run JVM and native workloads side by side while sharing libraries and CI conventions. Rule of thumb: decide per service using startup frequency and footprint pressure as drivers, then revisit when the ecosystem or workload changes.$body$, $code$// Keep domain code portable across deployment shapes.
@RestController
class HealthController {
    @GetMapping("/health")
    String health() {
        return "ok";
    }
}$code$),
    ('kotlin-for-java-developers', 1, 'Null Safety You Can Lean On', $body$Kotlin puts nullability in the type system: a String cannot hold null, a String? can, and the compiler refuses direct member access on a nullable receiver unless you use a safe call, an Elvis expression, or an explicit check. Smart casts remove most casts after a null check, and safe call chains return null instead of throwing. The guarantee weakens at Java boundaries, where declarations arrive as platform types the compiler cannot enforce, which is why annotating the Java side and choosing explicit Kotlin types at the boundary matter. The not-null assertion operator compiles, but it converts a compile-time guarantee back into a runtime crash. Rule of thumb: avoid the assertion operator in application code and let nullable types flow to a deliberate decision point.$body$, $code$fun greeting(name: String?): String {
    val trimmed = name?.trim()
    if (trimmed.isNullOrEmpty()) {
        return "hello, guest"
    }
    return "hello, ${trimmed}"
}$code$),
    ('kotlin-for-java-developers', 2, 'Data Classes and Value Semantics', $body$A data class generates equals, hashCode, toString, copy, and destructuring components from its primary constructor properties, removing boilerplate and adding a copy function that records lack. Equality follows the declared properties, so everything inside them is still your responsibility, and copy is shallow. Destructuring assigns positionally, so reordering constructor parameters silently changes meaning wherever components are extracted. Persistence frameworks usually want no-arg constructors and mutable properties, so data classes are a poor fit for managed entities. Rule of thumb: use data classes for values that cross boundaries, such as messages, identifiers, and events, and keep entities and framework-managed types explicit.$body$, $code$data class Payment(val id: String, val amountCents: Long)

fun main() {
    val failed = Payment("p-1", 500)
    val retried = failed.copy(amountCents = 750)
    val (id, cents) = retried
    require(cents > 0) { "amount must be positive: ${cents}" }
}$code$),
    ('kotlin-for-java-developers', 3, 'Extensions, Coroutines, and Interop Rules', $body$Extension functions add callable-looking members to types you do not own, but they are resolved statically, cannot override existing members, and disappear from Java because the receiver becomes a plain first parameter. Coroutines let you write concurrent code in sequential style with suspend functions and structured scopes that cancel together, which is far lighter than blocking a thread per task, at the cost of a library dependency and a new mental model. For interop, a few annotations control what Java sees: JvmStatic for companion members, JvmOverloads to generate overloads for default parameters, JvmField to expose a property as a field, and Throws to declare checked exceptions. Rule of thumb: review each Kotlin API from the Java side once, because interop surprises are cheapest to fix at the definition.$body$, $code$fun String.toOrderId(): OrderId = OrderId(this.uppercase())

suspend fun loadOrder(id: OrderId): Order = coroutineScope {
    val order = repository.find(id)
    withContext(Dispatchers.IO) { enrich(order) }
}$code$),
    ('kotlin-idioms-that-help-java-teams', 1, 'Where Kotlin Wins Quickly', $body$Kotlin pays off fastest in code dense with data shaping and null handling: request models, mapping layers, configuration, and tests, where null safety, data classes, collection extensions, and named arguments cut lines and review surface. Spring supports Kotlin directly with dedicated extensions, and Kotlin DSLs produce more type-safe build scripts. The gains show up as fewer boundary failures and less ceremony per class rather than as raw performance, because both languages compile to the same bytecode and run on the same runtime. Rule of thumb: start with new service code and tests in bounded areas, measure the difference in review and defect feedback, and let demonstrated wins, not enthusiasm, drive the next module.$body$, $code$data class CreateOrderRequest(val customerId: String, val items: List<LineItem>)

fun CreateOrderRequest.validate(): CreateOrderRequest {
    require(customerId.isNotBlank()) { "customerId required" }
    require(items.isNotEmpty()) { "items required" }
    return this
}$code$),
    ('kotlin-idioms-that-help-java-teams', 2, 'Adding Kotlin Without Splitting the Build', $body$Kotlin and Java compile together in one module because both produce ordinary class files, so a gradual migration can rewrite one class at a time while Java continues to call the result. Add the Kotlin plugin, keep source folders side by side, and be explicit about dependency direction so the mix does not become circular. Kotlin calls Java freely, while Java sees only the API shape Kotlin compiles to, so boundary design matters more than internal style. Generated bytecode still carries Kotlin metadata, and reflection-based frameworks generally keep working, but annotation processors need Kotlin-aware execution such as KSP. Keep formatting and lint rules unified across both languages. Rule of thumb: move one module or layer at a time and keep the build green after every step.$body$, $code$plugins {
    kotlin("jvm") version "2.2.0"
    java
}

dependencies {
    implementation(kotlin("stdlib"))
}

kotlin {
    jvmToolchain(21)
}$code$),
    ('kotlin-idioms-that-help-java-teams', 3, 'Conventions That Keep the Mix Sane', $body$Mixed-language codebases fail socially before they fail technically. Agree on when a file should be Kotlin: new code first, rewrites when you are touching the file anyway, and never a sweeping mandate that produces churn without value. Keep nullability contracts explicit at the boundary by avoiding platform-type leakage and annotating Java APIs that Kotlin consumes. Review Kotlin for Java-facing ergonomics, such as default parameters, companion functions, and extension methods that vanish from Java call sites. Keep one test framework and one logging convention so reviewers stop translating between two styles. Rule of thumb: write the interoperability rules where new engineers will find them, and enforce them in code review rather than in a migration epic.$body$, $code$// Kotlin side: publish an API that reads naturally from Java.
object OrderIds {
    @JvmStatic
    fun normalize(raw: String): String = raw.trim().uppercase()
}$code$),
    ('scala-and-jvm-language-overview', 1, 'Scala 3 in One Pass', $body$Scala 3 rebuilt the language around clearer syntax and a more principled type system. Enums describe algebraic data types with exhaustive pattern matching, opaque types hide representation without runtime cost, extension methods are part of the language, and given instances with using clauses replace most of the old implicit machinery. Optional braces and indentation-based syntax remove punctuation noise. The result is expressive code for domain modeling, pipelines, and type-heavy libraries, with a learning curve that remains steeper than Kotlin for a typical Java team. Rule of thumb: judge Scala by its compiled output and assembly, not its syntax, because it targets the same JVM and interoperates with your existing JARs.$body$, $code$enum Status:
  case Queued, Running
  case Failed(reason: String)

def describe(s: Status): String = s match
  case Status.Queued  => "queued"
  case Status.Running => "running"
  case Status.Failed(reason) => s"failed: ${reason}"$code$),
    ('scala-and-jvm-language-overview', 2, 'When Teams Reach for Scala', $body$Teams choose Scala when a problem benefits from expressive types and functional composition: data processing pipelines, streaming systems, analytics engines, and libraries that encode domain rules in the type system. Much of that reputation comes from the ecosystem around the language, including Spark and functional libraries, rather than from syntax alone. The costs are real: a smaller hiring pool among mainstream Java developers, slower compiles in many builds, and library churn between Scala 2 and Scala 3 that some organizations are still working through. Rule of thumb: adopt Scala for teams that will genuinely invest in the type system and functional style, not as a general default for ordinary business services.$body$, $code$case class Order(id: String, totalCents: Long)

val paid: List[Order] = orders.filter(_.totalCents > 0)
val revenue: Long = paid.map(_.totalCents).sum
val byBand: Map[String, List[Order]] = paid.groupBy { order =>
  if (order.totalCents > 50_000) "high" else "standard"
}
println(s"revenue: ${revenue}, bands: ${byBand.keySet}")$code$),
    ('scala-and-jvm-language-overview', 3, 'Ecosystem Trade-offs Against Java', $body$Scala runs on the JVM and interoperates with Java classes, so it inherits the platform libraries and tools, but the surrounding experience differs. Build tooling is split between sbt and Maven or Gradle integrations, and binary compatibility across Scala versions is stricter than Java's, so libraries are compiled for a specific version line. IDE support is good but historically more delicate than for Java, and compile times encourage splitting large projects. Dependency availability trails mainstream Java for enterprise libraries that rely heavily on annotation processors, because Scala does not run that pipeline the same way. Rule of thumb: check the exact Scala version and a library's release cadence before committing, and keep a Java fallback for lagging dependencies.$body$, $code$// Scala calls Java collections directly, with no wrappers.
val list = new java.util.ArrayList[String]()
list.add("first")
list.add("second")
val size: Int = list.size   // 2$code$),
    ('jvm-language-interoperability', 1, 'The Common Denominator Is Bytecode', $body$JVM languages share one contract: classes with methods and fields in the standard class file format, resolved by name at runtime. That is why Kotlin can call a Java library, Java can call Kotlin, and Scala can consume both. The friction is not bytecode but source-level constructs with no direct equivalent. Kotlin extensions become static methods, Scala case classes become classes with generated companions, default parameters become synthetic methods, and nullability annotations are the only hint the other language gets. Compilation order also matters, because mixed sources need a toolchain that compiles them together. Rule of thumb: design cross-language APIs as if the other language sees only plain classes, because at the call site it effectively does.$body$, $code$// Kotlin declarations compile to ordinary JVM members.
class Greeter {
    @JvmOverloads
    fun greet(name: String = "world") = "hello, ${name}"
}
// From Java: new Greeter().greet() or .greet("team")$code$),
    ('jvm-language-interoperability', 2, 'JARs, Builds, and Annotation Processing', $body$Shared JARs are the practical unit of interop: publish Java, Kotlin, and Scala artifacts to the same repository and consume them from each other, but be deliberate about ownership. Java annotation processors operate on Java sources only, so Kotlin projects run processors through kapt or KSP, and Scala projects generally do not participate in that pipeline at all; mapping and serialization libraries often use compiler plugins instead. Compiler output keeps binary compatibility manageable, but language-specific inline and macro features can leak implementation details to callers in other languages. Rule of thumb: keep public APIs free of language tricks, expose plain classes and interfaces at module boundaries, and let build tooling enforce which language owns each module.$body$, $code$plugins {
    java
    kotlin("jvm") version "2.2.0"
}

sourceSets {
    main {
        java.srcDirs("src/main/java")
        kotlin.srcDirs("src/main/kotlin")
    }
}$code$),
    ('jvm-language-interoperability', 3, 'Debugging a Mixed Stack', $body$A stack trace in a mixed application contains frames from several languages, and modern toolchains map them back to source lines through debug information, including Kotlin metadata for inline functions. When frames look wrong, check that debug information was compiled into the exact artifact you are running and that the IDE attaches to matching sources. For repository-wide triage, keep an ownership map from module to language so an issue lands with someone who knows the idiom in play, because debugging a coroutine or a Scala macro is different work from debugging a Java loop. Reproducing with the smallest failing module usually beats reasoning about interop at the top level. Rule of thumb: verify the artifact first, then the debug mapping, then the code.$body$, $code$# Which language produced this class, and what does it expose?
javap -p -classpath app.jar com.example.OrderMapper

# Kotlin metadata travels inside the class file.
javap -v -classpath app.jar com.example.OrderMapper \
    | grep -A1 "kotlin.Metadata"$code$),
    ('jvm-alternatives-today', 1, 'The JVMs You Can Actually Run', $body$Most Java deployments run HotSpot, the default OpenJDK virtual machine, and new features land there first. Eclipse OpenJ9, distributed most visibly through IBM Semeru builds, offers an alternative runtime tuned for a small footprint and fast startup with different garbage collection behavior. GraalVM ships its own JIT compiler, which some workloads run faster on, and the same project provides native-image for turning bytecode into standalone binaries. Vendors such as Azul and BellSoft build distributions around these choices, sometimes adding low-latency collectors of their own. Rule of thumb: standardize hot paths on HotSpot or GraalVM, and treat OpenJ9 as a deliberate choice for memory-constrained or fast-start environments.$body$, $code$# Which virtual machine is actually running?
java -XshowSettings:vm -version

# Which garbage collector is active?
java -XX:+PrintFlagsFinal -version | grep -E "UseG1GC|UseSerialGC"

# Compare a vendor build against the default one.
docker run --rm ibm-semeru-runtimes:open-21-jre java -version$code$),
    ('jvm-alternatives-today', 2, 'JIT Choices and Native Toolchains', $body$The JIT compiler turns bytecode into optimized machine code while the application runs, and its quality shapes peak throughput. GraalVM uses the same compiler engine in both its JIT mode and native-image, so some teams adopt GraalVM as a drop-in JVM first, profile there, and later explore a native build with familiar data. OpenJ9 takes a different approach with reduced warmup obligations and a different memory profile that suits long-lived processes under tight footprint budgets. Switching JVMs is cheaper than switching languages: usually a base image and flags, followed by performance validation against real traffic. Rule of thumb: benchmark any runtime switch on your own workload with production-like limits, because published comparisons rarely match your system.$body$, $code$# The same artifact on two runtimes, no recompilation.
docker run --rm eclipse-temurin:21-jre \
    java -jar app.jar --server.port=8080

docker run --rm ibm-semeru-runtimes:open-21-jre \
    java -jar app.jar --server.port=8080$code$),
    ('jvm-alternatives-today', 3, 'Choosing a Runtime Without Churn', $body$A runtime decision should follow a constraint you can state plainly: memory per instance, cold-start latency, throughput target, platform architecture, or a vendor support agreement. Keep the artifact neutral by avoiding JVM-specific flags in code, so the choice stays reversible; flags belong in deployment descriptors and base images rather than annotations or configuration baked into jars. Test the top two candidates with production-like traffic and container limits, and record the decision with the evidence and a review date. Operational familiarity matters too, because a marginally faster runtime that nobody can debug at two in the morning is not faster where it counts. Rule of thumb: choose the simplest runtime that satisfies the measured constraint, then re-evaluate on a schedule.$body$, $code$FROM eclipse-temurin:21-jre
# Keep runtime flags in the deployment layer, not in code.
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"
COPY app.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]$code$),
    ('jvm-ecosystem-and-distributions', 1, 'What an OpenJDK Build Contains', $body$Nearly every production JDK is built from OpenJDK source and validated against a compatibility kit, but vendors differ in patches, support terms, platform coverage, and bundled tooling. The release train alternates feature releases every six months with long-term-support releases at longer intervals, and vendors commit to support windows that range from months to many years. For native image work the build must include the native-image toolchain, which not every distribution bundles, and that toolchain version constrains which library metadata versions you can use. Rule of thumb: record for each service which JDK vendor, version, and support end date it depends on, and audit that inventory before every upgrade cycle.$body$, $code$# Identify the vendor build actually running in production.
java -version

# Pin the installation path instead of trusting the path order.
java -XshowSettings:properties -version 2>&1 | grep java.home
command -v java$code$),
    ('jvm-ecosystem-and-distributions', 2, 'Vendors, Support, and Native Tooling', $body$Vendor differences that matter most in practice are support duration, security patch cadence, container and architecture coverage, and whether GraalVM native image is included or must be installed separately. Some vendors ship GraalVM-based JDKs under their own names, and licensing terms for the native toolchain differ between distributions, so read them before standardizing across teams. An update pipeline should treat the JDK as a dependency with an exact version rather than a floating base image tag. Rule of thumb: choose one vendor for long-term support and a second for portability, pin exact builds in Dockerfiles, and review the pair annually against the support windows you actually rely on.$body$, $code$# Pin the exact build, not a floating tag.
FROM eclipse-temurin:21.0.4_7-jre-jammy
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"
COPY app.jar /app/app.jar
HEALTHCHECK CMD java -version || exit 1
ENTRYPOINT ["java", "-jar", "/app/app.jar"]$code$),
    ('jvm-ecosystem-and-distributions', 3, 'Deciding for Production', $body$A defensible choice weighs four things: how long the vendor supports the version, how quickly security fixes arrive, whether the build includes what your delivery pipeline needs such as the native-image toolchain, and how much operational knowledge exists on the team. Run a small benchmark with your own artifact across the shortlist, including container memory limits and startup probes, and confirm that observability agents and profilers work against each candidate. Record the decision with evidence, owners, and a review date so it can be revisited deliberately instead of by accretion. Rule of thumb: make the most boring supported build the default, and require an explicit exception process for anything exotic.$body$, $code$# Compare candidates with identical artifact and limits.
docker run --memory=512m --rm eclipse-temurin:21-jre \
    java -jar app.jar

docker run --memory=512m --rm ibm-semeru-runtimes:open-21-jre \
    java -jar app.jar$code$),
    ('long-term-java-strategy', 1, 'Planning Across LTS Releases', $body$Java ships feature releases every six months, with long-term-support versions arriving periodically, and vendors support those versions for windows that differ by vendor. A workable production policy adopts a known LTS, tracks the next one during early access, and plans migration windows measured in quarters, because frameworks, agents, and build plugins lag the compiler. That lag is the real constraint: a version is not adoptable by a large estate until the slowest critical dependency supports it. Maintain an inventory that maps each service to its JDK version and support end date, so upgrades can be batched by risk instead of by enthusiasm. Rule of thumb: run one version behind the newest LTS in production and test the newest in staging.$body$, $code$record JdkPolicy(String service, String jdk, LocalDate supportEnds) {

    boolean needsReview(LocalDate today) {
        return supportEnds.isBefore(today.plusMonths(6));
    }
}$code$),
    ('long-term-java-strategy', 2, 'Ecosystem Lag and Dependency Audits', $body$When a new LTS lands, the critical path is rarely application code but the build chain: bytecode-processing libraries, agents, database drivers, and framework versions must all declare support first. Audit before scheduling: list compile and runtime dependencies, note which ones touch internals or rely on heavy reflection, and check their release notes for the target version. Native image adds another layer, because metadata and AOT support must exist for the same library version if you build images. Budget time for the tail of the estate that always resists, and keep a documented exception list so stragglers stay visible. Rule of thumb: the upgrade is done when the last dependency supports it, not when the compiler accepts it.$body$, $code$# Inventory the runtime dependency set before choosing a target.
./mvnw -q dependency:tree -Dscope=runtime -DoutputFile=deps.txt

# Flag dependencies that lag on the current LTS.
grep -E "driver|agent|bytecode" deps.txt | head -20

# Check the bytecode version of a stubborn artifact.
javap -v -classpath lib/legacy.jar com.acme.Legacy | grep major$code$),
    ('long-term-java-strategy', 3, 'Refactoring Budget and Adoption Policy', $body$Platform upgrades are easier when the codebase has no accumulated use of removed internals. Reserve a standing budget, for example a small percentage of each iteration, for refactoring debt: removing deep reflection, replacing deprecated APIs, and deleting build flags that no longer apply. Pair that with an adoption policy that states which JDKs may run in production, who approves exceptions, how long version overlap may last, and what evidence a service must provide before moving. For native and polyglot choices, the same policy should say when they are allowed, so experiments stay real but bounded. Rule of thumb: policies age well when they define review dates and exit criteria rather than permanent bans or permanent permissions.$body$, $code$// Policy as data: every exception carries a review date.
record AdoptionRule(String technology, String status, LocalDate nextReview) {

    boolean overdue(LocalDate today) {
        return nextReview.isBefore(today);
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
    'class-data-sharing-and-appcds', 'graalvm-native-image-basics',
    'jvm-alternatives-today', 'jvm-ecosystem-and-distributions',
    'jvm-language-interoperability', 'jvm-vs-native-tradeoffs',
    'kotlin-for-java-developers', 'kotlin-idioms-that-help-java-teams',
    'long-term-java-strategy', 'native-image-testing-and-profiling',
    'native-image-with-spring-boot', 'reflection-and-dynamic-features-in-native',
    'scala-and-jvm-language-overview', 'startup-time-engineering'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
