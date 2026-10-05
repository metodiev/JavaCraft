-- V9 — Gradle build engineering tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('gradle-quickstart-and-structure', 'Gradle Quickstart and Project Structure', 'Create a small Gradle project with the wrapper, settings file, and a build script that runs its first build.', 'Junior', 24, true, 1),
    ('gradle-kotlin-dsl', 'Gradle Kotlin DSL Essentials', 'Compare the Kotlin and Groovy dialects, rely on type-safe accessors, and convert existing scripts with confidence.', 'Junior', 26, true, 1),
    ('gradle-tasks-and-build-lifecycle', 'Gradle Tasks and Build Lifecycle', 'Follow a build through configuration and execution while inspecting, ordering, and labeling the tasks that run.', 'Junior', 28, true, 1),
    ('gradle-plugins', 'Gradle Plugins', 'Apply core and community plugins correctly and move repeated configuration into shared conventions.', 'Junior', 24, true, 1),
    ('gradle-dependency-configurations', 'Gradle Dependency Configurations', 'Choose between implementation, api, compileOnly, and runtimeOnly with a clear picture of each configuration role.', 'Mid', 32, true, 1),
    ('gradle-version-catalogs', 'Gradle Version Catalogs', 'Centralize coordinates in libs.versions.toml and share versions and bundles across every module.', 'Mid', 28, true, 1),
    ('gradle-multi-project-builds', 'Gradle Multi-Project Builds', 'Structure a build with settings includes, project dependencies, and convention plugins that remove duplication.', 'Mid', 36, true, 1),
    ('gradle-jvm-toolchains', 'Gradle JVM Toolchains', 'Pin the Java language version with toolchains so local machines and CI compile with the same JDK.', 'Mid', 30, true, 1),
    ('gradle-testing-and-junit5', 'Gradle Testing and JUnit 5', 'Configure JUnit 5 on the test task, filter what runs, and parallelize safely with proper isolation.', 'Mid', 34, true, 1),
    ('gradle-incremental-builds-and-caching', 'Gradle Incremental Builds and Caching', 'Understand up-to-date checks, share outputs through build caches, and debug cache misses.', 'Mid', 38, true, 1),
    ('gradle-configuration-cache', 'Gradle Configuration Cache', 'Learn what the configuration cache stores, why common build patterns break it, and how to adopt it.', 'Mid', 36, true, 1),
    ('gradle-wrapper-and-version-alignment', 'Gradle Wrapper and Version Alignment', 'Manage Gradle upgrades through the wrapper and keep plugin versions compatible with the chosen release.', 'Mid', 28, true, 1),
    ('gradle-publishing-libraries', 'Publishing Libraries with Gradle', 'Publish libraries with maven-publish, sign releases, and ship trustworthy module metadata.', 'Senior', 42, true, 1),
    ('migrating-maven-to-gradle', 'Migrating from Maven to Gradle', 'Plan a phased move from Maven, import BOMs, map lifecycle phases, and know when to stay.', 'Senior', 40, true, 1),
    ('gradle-vs-maven', 'Gradle versus Maven', 'Compare the two build tools on model, performance, and ecosystem to make a grounded team choice.', 'Senior', 36, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('gradle-quickstart-and-structure', 1, 'Settings file defines the build', $body$Every Gradle build starts with a settings file. `settings.gradle.kts` tells Gradle which projects participate in the build, what the root project is called, and where plugins and dependency repositories come from. The settings file runs once during initialization, before any build script executes. In a single-module project it still matters: `rootProject.name` controls the name of generated artifacts and IDE modules, so teams set it explicitly instead of accepting the directory name. Keep structure decisions here, such as `include` calls, and keep build behavior in `build.gradle.kts`. Mixing the two makes builds harder to reason about. Rule of thumb: if a change alters the shape of the build, it belongs in settings.$body$, $code$pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

rootProject.name = "orders-service"$code$),
    ('gradle-quickstart-and-structure', 2, 'Build script applies plugins', $body$`build.gradle.kts` configures one project: the plugins it applies, the dependencies it needs, and the tasks it customizes. A minimal Java build applies `java`, or `java-library` when other modules compile against it, plus `application` when it produces a runnable program. Plugins register tasks and conventions; the script only adjusts what differs from the defaults. Prefer the `plugins` block at the top of the file because it resolves exactly one version per plugin and enables static accessors. Declare the toolchain and repositories once, then keep the file small. When a build script grows past configuration into logic, move that logic into a convention plugin so multiple modules can share it without copy-paste.$body$, $code$plugins {
    application
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.4")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}$code$),
    ('gradle-quickstart-and-structure', 3, 'Wrapper runs the first build', $body$The recommended way to run Gradle is through the wrapper checked into the repository. `gradlew` and `gradlew.bat`, together with `gradle/wrapper/gradle-wrapper.jar` and `gradle-wrapper.properties`, download and run the exact Gradle version the project pins, so every developer and CI agent uses the same build tool. Never edit wrapper files by hand; regenerate them with the `wrapper` task. From a clean checkout, `./gradlew tasks` lists the available tasks and `./gradlew build` compiles, tests, and assembles in one command. If the wrapper is missing, the project is not yet a Gradle build or the wrapper was never generated; run `gradle init` or `gradle :wrapper` where Gradle is installed.$body$, $code$# from the repository root
./gradlew :wrapper
./gradlew tasks
./gradlew build
./gradlew test$code$),
    ('gradle-kotlin-dsl', 1, 'Kotlin DSL versus Groovy DSL', $body$Gradle accepts two script flavors. Groovy DSL files end in `.gradle` and are interpreted dynamically; Kotlin DSL files end in `.gradle.kts` and are compiled, which produces real compiler errors and enables navigation and refactoring in IntelliJ IDEA or Android Studio. The two can coexist in one build, even inside the same multi-project tree, so migration does not need to be a big bang. Kotlin scripts are slightly slower to compile the first time because Gradle must compile them, but the daemon caches that work. The Kotlin DSL is the default for new builds generated by `gradle init --dsl kotlin`. Teams starting today should choose Kotlin DSL; the typing pays off as soon as scripts exceed trivial configuration.$body$, $code$// build.gradle.kts
tasks.register("hello") {
    doLast { println("hello from Kotlin DSL") }
}

// Groovy equivalent in build.gradle:
// task hello { doLast { println "hello from Groovy DSL" } }$code$),
    ('gradle-kotlin-dsl', 2, 'Type-safe accessors and IDE support', $body$Applying a plugin generates Kotlin accessors for the model it contributes. Instead of writing `tasks.findByName("test")`, you can use `tasks.test` or `tasks.named<Test>("test")`, and dependency configurations become typed functions such as `implementation(...)`. Accessors come from the `plugins` block, which is why a top-level `apply(plugin = ...)` breaks completion: Gradle cannot know the types in advance. IDEs import the build through the Tooling API, so reliable code completion requires syncing the Gradle project rather than opening the folder as a plain Kotlin project. When accessors cannot appear, for example inside an `apply` from a script plugin, fall back to the generic `tasks.named` API with an explicit type parameter and keep casts out of the script.$body$, $code$plugins {
    `java-library`
}

tasks.named<Test>("test") {
    useJUnitPlatform()
}$code$),
    ('gradle-kotlin-dsl', 3, 'Migrating scripts one at a time', $body$Migrate incrementally: rename one script to `.gradle.kts`, make it compile, and commit before touching the next. Most Groovy constructs have direct Kotlin equivalents, but some need attention: string interpolation becomes `$name` or `${expression}`, closures become lambdas, and property assignment often changes from `=` to a typed setter call. Prefer the `plugins` block over `buildscript` so accessors work. Groovy-only dynamic tricks, such as reaching into `project.ext`, usually indicate hidden coupling and should be replaced with typed properties or providers instead of translated literally. If a build still mixes both dialects after conversion, that is acceptable; Gradle supports it. Keep a build scan or `--dry-run` output before and after each converted script to prove the task graph did not change.$body$, $code$# rename one script at a time, then verify
mv build.gradle build.gradle.kts
./gradlew --dry-run build
./gradlew check

# commit the converted script before touching the next one$code$),
    ('gradle-tasks-and-build-lifecycle', 1, 'Initialization, configuration, execution phases', $body$Gradle runs every build in three phases. Initialization decides which projects participate by reading the settings file. Configuration evaluates build scripts, applies plugins, and assembles the task graph for the requested tasks. Execution runs the selected tasks in dependency order. Configuration happens even when you run one task, so expensive work placed there slows every invocation, including `./gradlew help`. Register tasks lazily with `tasks.register`, which defers creation until the task is needed, and configure them with `configureEach` rather than iterating all tasks eagerly. Think of the task graph as a directed acyclic graph: `dependsOn` adds edges, and Gradle decides the order. Understanding which phase your code runs in explains most confusing build behavior.$body$, $code$tasks.register("printVersion") {
    group = "help"
    description = "Prints the project version"
    doLast {
        println("version: $version")
    }
}$code$),
    ('gradle-tasks-and-build-lifecycle', 2, 'Extra actions and task ordering', $body$The core of a task is its action, but you can attach additional behavior with `doFirst` and `doLast`. This is convenient for small steps and common in existing builds, yet it splits behavior across locations, so prefer a custom task type when logic becomes substantial. Two ordering relationships exist and they differ: `dependsOn` means the other task must run and its outputs are consumed, while `mustRunAfter` and `shouldRunAfter` only order tasks that are already scheduled. Using `mustRunAfter` when you actually need outputs produces flaky builds, because running a single task will not trigger the producer. Rule of thumb: depend on what you consume, and only order what must not overlap.$body$, $code$tasks.register("seedData") {
    doLast { println("seed") }
}

tasks.register("integrationTest") {
    dependsOn("seedData")
    doLast { println("run integration tests") }
}$code$),
    ('gradle-tasks-and-build-lifecycle', 3, 'Inputs, outputs, and task inspection', $body$A task that declares inputs and outputs lets Gradle skip it when nothing relevant changed; the console then shows `UP-TO-DATE`. Annotations such as `@Input`, `@InputFiles`, `@OutputDirectory`, and `@Internal` define what matters, and values fed through providers stay lazy until execution. Missing inputs are dangerous: the task may be skipped although its behavior would change, which hides real regressions. To inspect builds, `./gradlew tasks` lists tasks by group, `./gradlew help --task test` shows one task in detail, and `./gradlew build --dry-run` prints the graph without running it. When creating custom tasks, add them to a meaningful group and write a description; both show up in these listings and make the build discoverable for teammates.$body$, $code$abstract class GenerateBuildInfo : DefaultTask() {
    @get:Input
    abstract val gitHash: Property<String>

    @get:OutputFile
    abstract val outputFile: RegularFileProperty

    @TaskAction
    fun generate() {
        outputFile.get().asFile.writeText("commit=" + gitHash.get())
    }
}$code$),
    ('gradle-plugins', 1, 'Core plugins and what they provide', $body$Plugins are how Gradle adds capability, and the core distribution ships the ones Java teams use daily. The `base` plugin introduces lifecycle tasks such as `clean`, `assemble`, and `check`. The `java` plugin adds source sets, compile and test tasks, and configurations such as `implementation` and `testImplementation`. `java-library` extends it with `api` for dependencies that leak into consumers. `application` adds `run` and packaging for a main class. Applying a plugin is a contract: it registers tasks, configurations, and conventions you can configure but not invent. Start from the narrowest plugin that fits the module, because every plugin adds configuration surface and potential classpath conflicts. A library module rarely needs `application`, and an application module usually does not need publishing plugins.$body$, $code$plugins {
    `java-library`
    application
}

application {
    mainClass = "com.example.orders.App"
}

java {
    toolchain { languageVersion = JavaLanguageVersion.of(21) }
}$code$),
    ('gradle-plugins', 2, 'Resolving plugins by id', $body$Plugin resolution is separate from dependency resolution, and the `plugins` block is the preferred declaration point. Core plugins are bare ids such as `java` (Kotlin DSL: `` `java` `` for names colliding with Kotlin keywords). Community plugins add a version, for example `id("org.springframework.boot") version "3.4.1"`, and Gradle fetches them from the Gradle Plugin Portal unless settings redirect the repository. Versions belong in one place; putting them in `gradle/libs.versions.toml` lets several modules reference the same plugin alias. Avoid the legacy `buildscript` classpath plus `apply(plugin = ...)` pattern in new builds: it bypasses version catalogs, obscures origin, and loses type-safe accessors. When upgrading a plugin, update the alias once and let dependency verification fail loudly if the resolved coordinates change unexpectedly.$body$, $code$# gradle/libs.versions.toml
[versions]
spring-boot = "3.4.1"

[plugins]
spring-boot = { id = "org.springframework.boot", version.ref = "spring-boot" }$code$),
    ('gradle-plugins', 3, 'Conventions instead of duplicated configuration', $body$When several modules repeat the same plugin list and configuration, the duplication drifts. Gradle offers two escape hatches. `buildSrc` is a special included build whose classes and precompiled script plugins are available to every project; a `build-logic` included build is the more modern, cache-friendly variant. A precompiled script plugin is a file like `java-conventions.gradle.kts` applying `java-library`, the toolchain, and common test dependencies; modules then apply `id("java-conventions")` and own only what is specific to them. This keeps root build scripts empty, avoids `allprojects` or `subprojects` configuration, and works with the configuration cache because logic is compiled and injected rather than evaluated per project. Migrate the two most duplicated blocks first and delete the copies.$body$, $code$// build-logic/src/main/kotlin/java-conventions.gradle.kts
plugins {
    `java-library`
}

java {
    toolchain { languageVersion = JavaLanguageVersion.of(21) }
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.4")
}$code$),
    ('gradle-dependency-configurations', 1, 'Implementation versus api exposure', $body$`implementation` and `api` differ in what consumers of your module can see. A dependency declared with `implementation` stays on your compile and runtime classpaths but is hidden from anyone compiling against you. A dependency declared with `api` appears on their compile classpath, so changing it can force downstream recompilation and can introduce version conflicts. The practical consequence is also speed: trimming the exposed API reduces compile classpaths and recompilation. A rule of thumb is to start with `implementation` everywhere and promote to `api` only when a type from that dependency appears in your public signatures. Library modules should enforce this deliberately; using `api` casually turns unrelated upgrades into breaking changes.$body$, $code$plugins {
    `java-library`
}

dependencies {
    api("com.fasterxml.jackson.core:jackson-databind:2.18.2")
    implementation("org.apache.commons:commons-lang3:3.17.0")
}$code$),
    ('gradle-dependency-configurations', 2, 'Compile-only and runtime-only dependencies', $body$Some dependencies are needed at only one stage. `compileOnly` contributes types for compilation but is absent from the runtime classpath; annotation processors and servlet APIs that the container supplies are typical examples. `runtimeOnly` is the inverse: the dependency is present at runtime but not needed on the compile classpath, such as a JDBC driver or a logging backend bound through a service loader. Getting the choice wrong usually fails late: a `compileOnly` dependency referenced in code compiles fine and then throws `NoClassDefFoundError` in production, while an unnecessary `implementation` entry bloats the runtime classpath. Use `compileOnly` only when the runtime truly provides the library, and prefer `runtimeOnly` over `implementation` whenever nothing in your code imports the package directly.$body$, $code$dependencies {
    compileOnly("org.projectlombok:lombok:1.18.36")
    annotationProcessor("org.projectlombok:lombok:1.18.36")

    runtimeOnly("org.postgresql:postgresql:42.7.5")
}$code$),
    ('gradle-dependency-configurations', 3, 'Resolvable and consumable configurations', $body$Configurations are named buckets that play one of two roles. Declarable configurations such as `implementation` accept dependency declarations; resolvable configurations such as `runtimeClasspath` answer the question what files does this need; consumable configurations such as `apiElements` describe what a project publishes to others. The Java plugin wires them: `testImplementation` extends `implementation`, so tests see main dependencies, and `apiElements` splits from `runtimeElements` so consumers get the right classpath for their role. This is why `implementation` in a `java-library` module does not leak: it simply is not part of the consumable view. Inspect relationships with `./gradlew dependencies` and `./gradlew outgoingVariants` when a dependency seems missing or appears unexpectedly.$body$, $code$configurations {
    create("dbMigration") {
        canBeResolved = true
        canBeConsumed = false
    }
}

dependencies {
    add("dbMigration", "org.flywaydb:flyway-core:11.1.0")
}$code$),
    ('gradle-version-catalogs', 1, 'The libs.versions.toml catalog file', $body$Version catalogs centralize dependency coordinates in a TOML file at `gradle/libs.versions.toml`, which Gradle exposes as the `libs` accessor. The `[versions]` table holds version strings, `[libraries]` maps aliases to modules, `[plugins]` maps aliases to plugin ids, and `[bundles]` groups libraries used together. Gradle generates type-safe accessors, so a typo becomes a compile error in Kotlin DSL instead of a runtime surprise. Catalogs also separate coordinates from where they are used, making upgrades a one-line change. Because every project in the build sees the same catalog, this is the default home for version declarations in new Gradle builds. Keep the file organized by concern and remove entries that no module uses.$body$, $code$[versions]
junit = "5.11.4"

[libraries]
junit-jupiter = { module = "org.junit.jupiter:junit-jupiter", version.ref = "junit" }

[bundles]
testing = ["junit-jupiter"]$code$),
    ('gradle-version-catalogs', 2, 'Shared versions through aliases and bundles', $body$`version.ref` points at a single `[versions]` entry so related artifacts move together; this is how families such as Jackson or JUnit stay aligned. Aliases use kebab-case and map to dotted accessors, so `junit-jupiter` becomes `libs.junit.jupiter`. A `[bundles]` entry collects several library aliases, which lets a module reference one bundle accessor instead of listing rows. Bundles are convenient but blunt: they should represent a real grouping such as testing libraries, not a grab bag. Two cautions. First, a catalog declares requested versions, and conflict resolution can still select something else when another dependency requests higher. Second, do not hide versions inside `[libraries]` entries if they are shared; a hardcoded version is invisible to upgrades.$body$, $code$[versions]
jackson = "2.18.2"

[libraries]
jackson-databind = { module = "com.fasterxml.jackson.core:jackson-databind", version.ref = "jackson" }
jackson-module-kotlin = { module = "com.fasterxml.jackson.module:jackson-module-kotlin", version.ref = "jackson" }$code$),
    ('gradle-version-catalogs', 3, 'Catalogs across modules and builds', $body$The default `gradle/libs.versions.toml` is automatically visible to every project in a multi-project build, so modules only need to reference `libs` accessors. When an organization needs one catalog for many repositories, publish it: a build applying the `version-catalog` plugin with `maven-publish` can publish the catalog itself, and consumers import it in settings with `dependencyResolutionManagement` and a `create("libs")` block calling `from(...)` with the published coordinates. Imported and local catalogs can be combined, and a local entry can override a version for one repository. Keep at most a small number of catalogs, name them clearly, and treat published catalog upgrades like library upgrades: they change many modules at once and deserve a review.$body$, $code$// settings.gradle.kts
dependencyResolutionManagement {
    versionCatalogs {
        create("libs") {
            from("com.example:platform-catalog:2.1.0")
        }
    }
}$code$),
    ('gradle-multi-project-builds', 1, 'Describing the project tree', $body$A multi-project build is declared entirely in the settings file. `include("core", "api", "app")` adds subprojects whose directories match their paths; nested paths such as `services:billing` map to `services/billing`. The build then contains one project per module, each with its own `build.gradle.kts`, and the root project can stay deliberately empty. Keep the root build script free of shared configuration blocks; it should rarely do more than define common plugins in `pluginManagement` or the version catalog. Splitting a monolith follows evidence: modules that change together and deploy together are weak candidates for division, while modules with different change rates or consumers benefit. Start with one build and one settings file; create composite builds only when a true repository boundary exists.$body$, $code$rootProject.name = "commerce-platform"

include("core", "pricing", "orders", "services:billing")

project(":core").projectDir = file("libs/core")$code$),
    ('gradle-multi-project-builds', 2, 'Project dependencies between modules', $body$Subprojects depend on each other with project dependencies: `implementation(project(":core"))`. Because Gradle builds the graph, it computes the correct order and can build in parallel with `org.gradle.parallel=true`. Which configuration you use matters between modules exactly as it does for external libraries: `api` exposes a module to consumers of the dependent module, `implementation` keeps it internal. Avoid creating cycles; Gradle reports them clearly, but the fix is a design change, usually extracting shared types into a lower module. Also avoid depending on the application module from a library; direction should follow dependency inversion so the graph stays acyclic and testable. Use `./gradlew projects` and the `dependencies` task with an explicit configuration to inspect the result.$body$, $code$// orders/build.gradle.kts
plugins {
    `java-library`
}

dependencies {
    implementation(project(":core"))
    api(project(":pricing"))
}$code$),
    ('gradle-multi-project-builds', 3, 'Convention plugins replace duplicated blocks', $body$In a healthy multi-project build, module scripts are short. Reusable behavior lives in a `build-logic` included build that compiles precompiled script plugins; a module then applies `id("java-conventions")` and declares only its unique dependencies and tasks. This is preferable to `subprojects { }` or `allprojects { }` blocks in the root script, which configure projects eagerly, ignore lazy APIs, and frequently break the configuration cache. A convention plugin is also reviewable and testable like normal code. Introduce them in this order: pick the most duplicated configuration, extract it behind an id, convert a couple of modules, then delete the old blocks once every consumer migrates. Track remaining duplication with a search for repeated plugin lists in module scripts.$body$, $code$// orders/build.gradle.kts after convention extraction
plugins {
    id("java-conventions")
}

dependencies {
    implementation(project(":core"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.4")
}$code$),
    ('gradle-jvm-toolchains', 1, 'Declaring the Java toolchain', $body$A toolchain tells Gradle which JDK compiles and runs the project, independent of the JDK that runs Gradle itself. Declare it in the `java` extension with `languageVersion = JavaLanguageVersion.of(21)`. Every compile, test, and javadoc task then uses a matching installation; Gradle detects locally installed JDKs and, when a download repository is configured, can provision a missing one. Toolchains supersede `sourceCompatibility` for correctness because the same JDK is used for compilation and test execution on every machine. Prefer them over depending on whatever `JAVA_HOME` points to; that environment variable applies globally and varies per developer. When you need bytecode for an older release than the compiler, pair the toolchain with `options.release` on JavaCompile tasks.$body$, $code$plugins {
    java
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}$code$),
    ('gradle-jvm-toolchains', 2, 'Provisioning JDKs for every machine', $body$Detection finds JDKs in standard locations, `JAVA_HOME`, SDKMAN, and IDE installations. When nothing matches the requested language version, Gradle can download one if a toolchain resolver is configured; the Foojay Disco resolver is the common choice, applied in settings with `id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"`. Provisioned JDKs are stored under the Gradle user home and reused. In locked-down environments, disable downloads with `org.gradle.java.installations.auto-download=false` and preinstall the required JDKs, optionally pointing at them with `org.gradle.java.installations.paths`. Run `./gradlew -q javaToolchains` to see exactly what Gradle detected, from where, and whether it counts as a JDK or only a JRE. That listing resolves most confusing toolchain selection errors.$body$, $code$// settings.gradle.kts
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

# then inspect what Gradle detected
./gradlew -q javaToolchains$code$),
    ('gradle-jvm-toolchains', 3, 'Consistency across machines and CI', $body$Toolchains make builds portable but they do not make the whole environment identical. Three moving parts deserve separate attention: the JDK that runs the Gradle daemon, the toolchain that compiles and tests code, and the release level of the bytecode. CI images should preinstall or provision the same toolchain versions developers use and pin the wrapper, while `javaToolchains` output belongs in upgrade checklists. Setting `JAVA_HOME` only changes the default JVM; it does not override a declared toolchain. If your organization requires strict API compatibility, combine the toolchain with `options.release`, because a newer JDK happily compiles against newer APIs unless the release flag forbids it. Document the supported JDK range in the repository so new machines converge without guesswork.$body$, $code$tasks.withType<JavaCompile>().configureEach {
    options.release = 21
}

tasks.named<Test>("test") {
    javaLauncher = javaToolchains.launcherFor {
        languageVersion = JavaLanguageVersion.of(21)
    }
}$code$),
    ('gradle-testing-and-junit5', 1, 'Wiring JUnit 5 test tasks', $body$The `java` plugin creates a `test` task and a `test` source set; JUnit 5 needs two declarations. Add the Jupiter aggregator to `testImplementation` and the platform launcher to `testRuntimeOnly`, then call `useJUnitPlatform()`. Without the launcher on the runtime classpath, Gradle fails to start tests with a message about missing engines or launcher. JUnit Platform is the entry point that discovers engines; Jupiter is the engine that runs `@Test` methods. For projects already carrying JUnit 4 tests, add the `junit-vintage-engine` to run them side by side while migrating. Keep test dependencies out of `implementation` so they never reach published metadata, and remember that the `test` source set has configuration names derived from the main ones, such as `testImplementation` and `testRuntimeOnly`.$body$, $code$dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.4")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}$code$),
    ('gradle-testing-and-junit5', 2, 'Filtering and configuring test execution', $body$Long test suites are managed through the `Test` task rather than the build script. `./gradlew test --tests "com.example.pricing.*"` selects classes, and `filter { includeTestsMatching("...") }` bakes a selection into the task for custom suites. `maxHeapSize`, `jvmArgs`, `failFast`, and `testLogging` control how the forked JVM runs and what the console shows; failing fast is useful in CI, less so when you want a full failure list locally. Two pitfalls recur: writing filters that silently match nothing, which reports success, and letting a test task inherit the default heap when integration tests need more. Publish reports instead of parsing the console; Gradle writes HTML and XML under the build directory, and CI systems consume the XML reliably.$body$, $code$tasks.test {
    useJUnitPlatform {
        includeTags("unit")
    }
    maxHeapSize = "1g"
    testLogging { events("failed", "skipped") }
}$code$),
    ('gradle-testing-and-junit5', 3, 'Parallel test execution and isolation', $body$Tests run in a forked JVM, and `maxParallelForks` controls how many forks execute concurrently. More forks shorten wall-clock time when the machine has spare cores, but they also multiply memory use and expose shared state. Any test touching a fixed port, a shared database, or the filesystem can start failing intermittently, so parallel execution requires isolation: unique schemas or containers per worker, unique temp directories, and no assumptions about ordering. Gradle exposes a worker identifier through the `org.gradle.test.worker` system property so tests can derive unique resource names. `forkEvery` caps how many test classes a single fork handles and should stay at its default unless a leaky framework demands restarts; a low value severely degrades performance. Enable parallelism after you have a deterministic suite, not before.$body$, $code$tasks.test {
    // read the worker id inside tests via org.gradle.test.worker
    maxParallelForks = 4
    forkEvery = 200
}$code$),
    ('gradle-incremental-builds-and-caching', 1, 'Up-to-date checks and their inputs', $body$Before executing, Gradle fingerprints a task inputs and outputs; if nothing changed since the previous run, the task is skipped and shown as `UP-TO-DATE`. Compile tasks track sources and the compile classpath, test tasks track classes and test dependencies, and custom tasks track whatever their properties declare. This mechanism only works when declarations are complete. A task that reads a file without declaring it may be skipped while its result should have changed, which is one of the hardest build bugs to notice. Conversely, an over-broad input such as a timestamp makes the task run every time and silently destroys incrementality. When debugging, inspect the task properties and add missing annotations rather than forcing reruns with `--rerun-tasks` as a habit.$body$, $code$abstract class RenderDocs : DefaultTask() {
    @get:InputDirectory
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val sourceDir: DirectoryProperty

    @get:OutputDirectory
    abstract val outputDir: DirectoryProperty
}$code$),
    ('gradle-incremental-builds-and-caching', 2, 'Local and remote build caches', $body$The build cache extends work avoidance beyond a single workspace. With `org.gradle.caching=true`, task outputs are keyed by inputs and stored locally, so a clean build can restore compiled classes from earlier runs; with a remote HTTP cache configured in settings, outputs are shared across machines and CI agents. The usual topology has CI populate the cache from clean builds while developers only read from it, expressed with `isPush` set from an environment check on the remote cache. The local cache is enabled by default once caching is on, while the remote cache needs a URL and credentials. Only cacheable tasks participate; tasks that merely copy files or have no outputs are excluded by design. Treat the cache as an optimization: builds must remain correct when it is empty.$body$, $code$// settings.gradle.kts
val isCi = System.getenv().containsKey("CI")

buildCache {
    remote<HttpBuildCache> {
        url = uri("https://cache.example.com/")
        isPush = isCi
    }
}$code$),
    ('gradle-incremental-builds-and-caching', 3, 'Relocatability and diagnosing cache misses', $body$Cached entries are reused only if the key matches, and keys include input fingerprints. File inputs are identified by absolute path unless path sensitivity is declared, so entries created in one checkout directory cannot be restored in another; declare `@PathSensitive(PathSensitivity.RELATIVE)` on file and directory inputs to make a task relocatable and shareable. Other common causes of misses are changed build script classpaths, different Gradle or JDK versions, and environment values baked into task configuration. Diagnose with `--info` to see why a task was not up-to-date, or a build scan to compare entries across builds. Rule of thumb: every unexplained miss is a declaration bug; fix the input model instead of disabling caching for the task.$body$, $code$# diagnose why a task ran again
./gradlew compileJava --info

# clean run that should be restored from cache
./gradlew clean compileJava --build-cache$code$),
    ('gradle-configuration-cache', 1, 'What the configuration cache stores', $body$The configuration cache is not the build cache. The build cache stores task outputs; the configuration cache stores the result of the configuration phase: the task graph, each task configured state, and the dependency information needed to run it. On a cache hit Gradle skips evaluating settings, build scripts, and plugins entirely and executes the stored graph. The cache key covers build scripts, init scripts, included build logic, version catalogs, environment variables and system properties read at configuration time, and file state checked then. That makes rebuilds after the first one much faster, especially for large multi-project builds where configuration dominates. Since Gradle 9 it is the preferred execution mode, moving toward being enabled by default, so new build logic should satisfy it from the start.$body$, $code$# gradle.properties
org.gradle.configuration-cache=true

# command line
./gradlew build
./gradlew build   # second run reuses the stored task graph$code$),
    ('gradle-configuration-cache', 2, 'Common violations and safe fixes', $body$Most configuration cache failures come from build logic that assumes a live `Project`. Referencing `project` inside a `doLast` action, reading mutable script variables at execution time, or calling the environment during execution are typical problems. Fixes are mechanical once learned: move values into task properties, wire them with providers such as `providers.environmentVariable` or `layout.buildDirectory`, avoid resolving configurations at configuration time, and replace task extension lookups with typed properties. Captured script-level values are narrowed by copying primitives into local values. Because the cache also resolves configurations eagerly, latent dependency errors surface earlier. Run with `--configuration-cache-problems=fail` to turn warnings into hard failures once the build is clean, so regressions cannot creep back in.$body$, $code$val appVersion = providers.gradleProperty("app.version")

tasks.register("printVersion") {
    val value = appVersion
    doLast { println(value.get()) }
}$code$),
    ('gradle-configuration-cache', 3, 'Adopting the configuration cache safely', $body$Adoption is a loop, not a flag flip. Enable the cache locally, run the tasks that matter, and read every reported problem, including warnings. Fix the build logic or the plugin that caused each one; when a third-party plugin is the culprit, check whether a newer version supports the cache, and temporarily exclude that specific task if not. Track progress over time in CI, where `--configuration-cache-problems=fail` enforces a clean state. For ephemeral CI agents where the cache never survives two builds, the read-only mode lets Gradle use hits without spending time storing entries. Expect measurable gains on large builds and modest ones on small single-module projects. The stricter input tracking also tends to surface real configuration bugs that were previously silent.$body$, $code$# gradle.properties while experimenting
org.gradle.configuration-cache=true
org.gradle.configuration-cache.problems=warn

# strict enforcement in CI
./gradlew build --configuration-cache-problems=fail$code$),
    ('gradle-wrapper-and-version-alignment', 1, 'Commit the wrapper, pin the version', $body$The wrapper is part of the source tree: `gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.jar`, and `gradle-wrapper.properties`. Checking all of them in guarantees that every machine and CI agent runs the same Gradle release, without a system installation. The properties file records the distribution URL, so the pinned version is visible in a diff during review. Wrapper files are generated, not downloaded manually: run `gradle :wrapper` from an installed Gradle, and regenerate rather than hand-edit. Builds should invoke `./gradlew` exclusively; mixing `gradle` and `./gradlew` on one machine produces two caches and confusing version behavior. If your organization blocks binary files, the wrapper JAR is the known exception you must negotiate, because Gradle provides no workaround.$body$, $code$# refresh wrapper files with an installed Gradle 9.8
gradle :wrapper --gradle-version 9.8.0 --distribution-type bin

# always build through the committed wrapper
./gradlew build$code$),
    ('gradle-wrapper-and-version-alignment', 2, 'Upgrading Gradle deliberately', $body$Upgrade the wrapper through the wrapper task: `./gradlew :wrapper --gradle-version 9.8.0`. Run it twice if you want the shell scripts and JAR refreshed as well, then commit the result as one reviewable change. Read the release notes for breaking changes and deprecations before choosing a target, and prefer a recent patch release over a brand-new major. Because a Gradle upgrade can change task behavior, caches, and plugin compatibility, run the full build on CI in the upgrade branch, including integration tests, rather than only `assemble`. Keep the previous version reachable in history so a revert is a single commit. Schedule upgrades regularly; jumping several majors at once multiplies migration work and turns a routine task into a project.$body$, $code$git switch -c chore/gradle-upgrade
./gradlew :wrapper --gradle-version 9.8.0
git diff -- gradle/wrapper/gradle-wrapper.properties
./gradlew build --warning-mode all
git commit -am "Upgrade Gradle wrapper"$code$),
    ('gradle-wrapper-and-version-alignment', 3, 'Aligning plugin and Gradle versions', $body$Plugins declare their own compatibility expectations, and the Gradle compatibility matrix ties Gradle releases to Java versions and embedded Kotlin. A plugin built for a newer Gradle may fail on an older wrapper; one compiled against an old API may warn loudly then break a major later. Pin plugin versions, keep them in the version catalog, and upgrade the wrapper and plugins together on a branch, checking each plugin release note. `--warning-mode all` turns deprecation warnings into visible guidance instead of hidden noise, and the `validatePlugins` task checks build logic wiring. Kotlin DSL scripts also embed a Kotlin version; plugins that ship their own Kotlin must stay aligned with it. A short compatibility table in the repository, wrapper version plus plugin versions, prevents support guesswork.$body$, $code$# surface deprecations before a Gradle upgrade
./gradlew build --warning-mode all

# check the wrapper version that CI will use
./gradlew --version$code$),
    ('gradle-publishing-libraries', 1, 'Defining publications with maven-publish', $body$The `maven-publish` plugin turns a module into an artifact producer. You create a `MavenPublication` and attach the Java component with `from(components["java"])`, which derives coordinates from the group, project name, and version. Publishing then needs a destination: a `publishing.repositories` block declaring a Maven repository URL, with credentials resolved from properties or environment variables, never committed. Keep group and version consistent across modules; they usually come from the version catalog or a shared convention. Use `publishToMavenLocal` when you only want to consume the artifact from another local build, and a snapshot or staging repository before a release repository. The plugin also generates the POM, so verify it rather than assume: wrong metadata reaches consumers and is expensive to correct after an artifact is public.$body$, $code$plugins {
    `maven-publish`
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
        }
    }
}$code$),
    ('gradle-publishing-libraries', 2, 'Signing and secret handling', $body$Repository requirements usually include signed artifacts. The `signing` plugin adds signing tasks and can sign every publication that declares itself, producing detached OpenPGP signature files alongside the artifacts. Credentials and keys belong in Gradle properties outside version control, typically the user home `gradle.properties` or environment variables in CI; the configuration cache does not serialize that file content, only its fingerprint, so secrets stored there are not copied into cache entries. Sign conditionally: require signatures on release builds and skip them for snapshots to keep local iteration fast. Verify what you upload, because a broken signature is discovered by consumers. Treat release credentials as production secrets: least privilege, rotation, and no long-lived tokens shared across repositories.$body$, $code$plugins {
    signing
    `maven-publish`
}

signing {
    sign(publishing.publications["mavenJava"])
}$code$),
    ('gradle-publishing-libraries', 3, 'Module metadata and consumer compatibility', $body$Publishing does not stop at the POM. Gradle Module Metadata is written automatically alongside it, describing variants such as `apiElements` and `runtimeElements`, plus constraints and capabilities. Gradle consumers pick the right variant; Maven consumers read the POM, where `api` and `implementation` map to compile and runtime scopes. Because richer metadata matters, keep the POM accurate and avoid mixing environments: publishing a dependency only as compile scope while relying on runtime-only behavior misleads Maven consumers. Version immutability is the other rule: once an artifact and its metadata are released, they should never change, because caches and lock files record checksums. Verify a release by consuming it from a clean project before announcing it, using the same repositories consumers will use.$body$, $code$./gradlew publishToMavenLocal
./gradlew generatePomFileForMavenJavaPublication
ls build/publications/mavenJava/

# consume from a clean project before announcing a release$code$),
    ('migrating-maven-to-gradle', 1, 'Phasing the migration safely', $body$Treat a Maven to Gradle migration as a sequence of small, reversible steps. Start with a compatibility pass: build the Maven project, record its artifacts, then scaffold Gradle with `gradle init --type pom`, which converts the POM into Gradle files. Run both builds side by side and compare the critical outputs before deleting anything. Migrate one module at a time in multi-module builds, keeping the old build green until the new one is trusted. The riskiest parts are custom plugins, resource filtering, and profiles; port them explicitly instead of relying on the converter. A migration is complete when the Gradle build is the only one in CI, not when the files exist, and the old build remains reachable in history for rollback.$body$, $code$gradle init --type pom --dsl kotlin

# keep both builds green while comparing artifacts
./mvnw -q verify
./gradlew build$code$),
    ('migrating-maven-to-gradle', 2, 'Importing BOMs and dependency constraints', $body$Maven centralizes versions in `dependencyManagement` and imports BOMs. Gradle expresses the same intent with platforms: `implementation(platform("org.springframework.boot:spring-boot-dependencies:3.4.1"))` lets the platform control versions while you declare dependencies without one. Apply a platform to every configuration that resolves dependencies, or use the `java-platform` plugin to publish your own constraints. Two differences matter. Maven versions act as defaults that participants closely follow; Gradle treats catalog and platform versions as requests, and conflict resolution may select a higher version. Second, constraints transitively affect consumers, so review them before publishing a platform. Convert exclusions explicitly, then use the `dependencies` and `dependencyInsight` reports to prove the resolved graph matches the old build.$body$, $code$dependencies {
    implementation(platform("org.springframework.boot:spring-boot-dependencies:3.4.1"))
    implementation("org.springframework.boot:spring-boot-starter-web")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
}$code$),
    ('migrating-maven-to-gradle', 3, 'Lifecycle mapping and migration trade-offs', $body$Maven runs fixed phases; Gradle composes a task graph and provides lifecycle tasks that approximate the familiar names: `clean`, `classes` for compile, `test`, `assemble` for package, `check` for verify, and `publish`. That mapping lets CI scripts migrate with little change. Not every build should migrate. A small, stable project with no custom plugins gains little and pays conversion and retraining costs; a large build with slow configuration, expensive test cycles, or a need for shared build logic usually gains a lot. Custom Maven plugins, exotic profiles, and builds that depend on repository layout quirks raise the cost. Decide with evidence: estimate configuration time, incremental build time, and maintenance burden, then migrate when the expected payoff clearly exceeds the disruption.$body$, $code$# Maven phase to Gradle lifecycle task
# mvn clean   -> ./gradlew clean
# mvn compile -> ./gradlew classes
# mvn verify  -> ./gradlew check
# mvn package -> ./gradlew assemble$code$),
    ('gradle-vs-maven', 1, 'Build models: task graph versus phases', $body$Maven defines a fixed lifecycle of phases and binds plugin goals to them, so ordering is predictable but rigid. Gradle builds a directed acyclic graph of tasks with explicit dependencies, so execution order follows the data rather than a template, and unrelated tasks can run in parallel. The flexibility cuts both ways: Gradle permits configurations Maven cannot express, and also permits messy builds where ordering is accidental. Maven wins on uniformity; every experienced Maven developer can read any POM. Gradle wins on adaptation, which is why Android, Kotlin, and most new large JVM builds choose it. Rule of thumb: choose Maven when convention matches your needs exactly, and Gradle when your build has requirements, performance targets, or sharing needs that convention cannot express.$body$, $code$# Maven: linear lifecycle phases
mvn verify

# Gradle: task graph with the same outcome
./gradlew check
./gradlew check --dry-run$code$),
    ('gradle-vs-maven', 2, 'Performance and caching models', $body$Performance differences come from work avoidance. Maven rebuilds through its lifecycle with limited incrementality and no shared output cache by default. Gradle adds up-to-date checks, so unchanged tasks are skipped, and a build cache that can restore outputs produced on another machine or in CI. The daemon keeps a warm JVM and compiled build logic between invocations, removing startup cost that dominates small Maven commands. The configuration cache removes repeated script evaluation for large builds. Compile avoidance further limits recompilation when an implementation dependency changes but the classpath shape does not. The practical rule: Gradle rewards investment in declared inputs and isolated build logic, while a poorly structured Gradle build can be as slow as Maven. Measure configuration time and task execution separately before drawing conclusions.$body$, $code$# where does build time go
./gradlew build --profile

# re-run with caches disabled to compare
./gradlew build --no-build-cache$code$),
    ('gradle-vs-maven', 3, 'Ecosystem and team-level choice', $body$Both tools are mature, so the decision is mostly organizational. Maven has decades of plugins, abundant documentation, and near-universal familiarity; onboarding is cheap and build files are boring in a good way. Gradle has first-class Kotlin DSL, stronger incremental and caching features, first-party Android support, and build logic that can be written as tested code. Switching costs are real: CI scripts, internal plugins, release tooling, and team habits all move together. Prefer consistency within a repository and, where possible, within a platform team; mixed ecosystems double the expertise needed for support. If you stay with Maven, invest in parallel builds and dependency analysis. If you adopt Gradle, invest in convention plugins, the wrapper, and caching discipline.$body$, $code$# compare the current build on the same machine
time ./mvnw -T 1C verify
time ./gradlew check --parallel

# then weight CI cost, plugin needs, and team skills$code$)
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
    'gradle-quickstart-and-structure', 'gradle-kotlin-dsl',
    'gradle-tasks-and-build-lifecycle', 'gradle-plugins',
    'gradle-dependency-configurations', 'gradle-version-catalogs',
    'gradle-multi-project-builds', 'gradle-jvm-toolchains',
    'gradle-testing-and-junit5', 'gradle-incremental-builds-and-caching',
    'gradle-configuration-cache', 'gradle-wrapper-and-version-alignment',
    'gradle-publishing-libraries', 'migrating-maven-to-gradle',
    'gradle-vs-maven'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
