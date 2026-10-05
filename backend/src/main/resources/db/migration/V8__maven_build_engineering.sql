-- V8 — Maven build engineering tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('maven-quickstart-and-conventions', 'Maven Quickstart and Conventions', 'Create the standard Maven layout, name an artifact with coordinates, and run the first build.', 'Junior', 22, true, 1),
    ('maven-pom-anatomy', 'Maven POM Anatomy', 'Read a POM from modelVersion to parent and learn what each element controls.', 'Junior', 24, true, 1),
    ('maven-build-lifecycle-and-phases', 'Maven Build Lifecycle and Phases', 'Follow the default lifecycle through its phases and bind plugin goals without surprises.', 'Junior', 26, true, 1),
    ('maven-dependency-scopes', 'Maven Dependency Scopes', 'Choose dependency scopes that place each library on the correct classpath per phase.', 'Junior', 24, true, 1),
    ('maven-transitive-dependencies-and-exclusions', 'Maven Transitive Dependencies and Exclusions', 'Trace transitive dependencies, trim them with exclusions, and read the resolved tree.', 'Mid', 32, true, 1),
    ('maven-dependency-management-and-boms', 'Maven Dependency Management and BOMs', 'Centralize versions with dependencyManagement and imported BOMs across a module set.', 'Mid', 34, true, 1),
    ('maven-plugins-and-executions', 'Maven Plugins and Executions', 'Configure plugin goals and executions and know the common plugins real builds use.', 'Mid', 34, true, 1),
    ('maven-surefire-and-failsafe', 'Maven Surefire and Failsafe', 'Split unit and integration tests between surefire and failsafe and run them predictably.', 'Mid', 32, true, 1),
    ('maven-multi-module-builds', 'Maven Multi-Module Builds', 'Structure an aggregator, parent, and modules and keep reactor versions aligned.', 'Mid', 38, true, 1),
    ('maven-profiles-and-properties', 'Maven Profiles and Properties', 'Override properties and activate profiles by OS, file, or JDK without fragmenting builds.', 'Mid', 30, true, 1),
    ('maven-settings-and-repositories', 'Maven Settings and Repositories', 'Configure mirrors, proxies, and credentials in settings.xml instead of project POMs.', 'Mid', 30, true, 1),
    ('maven-wrapper-and-version-pinning', 'Maven Wrapper and Version Pinning', 'Pin a Maven version with the wrapper so local builds and CI use the same release.', 'Mid', 28, true, 1),
    ('maven-toolchains', 'Maven Toolchains', 'Select a JDK toolchain from toolchains.xml and compile independently of the running JVM.', 'Senior', 38, true, 1),
    ('maven-reproducible-builds', 'Maven Reproducible Builds', 'Make builds bit-for-bit reproducible and verify the result with the artifact plugin.', 'Senior', 40, true, 1),
    ('maven-release-and-versioning', 'Maven Release and Versioning', 'Manage versions, releases, and SNAPSHOT hygiene with automation that stays repeatable.', 'Senior', 42, true, 1),
    ('maven-enforcer-and-quality-gates', 'Maven Enforcer and Quality Gates', 'Enforce JDK, Maven, and dependency rules that fail the build before bad artifacts ship.', 'Senior', 40, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('maven-quickstart-and-conventions', 1, 'Conventions replace build configuration', $body$Maven defines a standard project layout: production sources under src/main/java, resources under src/main/resources, tests under src/test/java, and generated output under target. Because the layout is conventional, the POM does not need to list source directories at all. That is the core bargain: follow the conventions and Maven already knows where everything is, so configuration shrinks to what is genuinely unusual. Deviating from the layout is possible but costs clarity, because every reader and every plugin must then be told about the deviation. Rule of thumb: keep the standard layout, and add configuration only for deviations you can justify in review.$body$, $code$orders-service/
  pom.xml
  src/main/java/dev/javacraft/App.java
  src/main/resources/application.properties
  src/test/java/dev/javacraft/AppTest.java
  target/$code$),
    ('maven-quickstart-and-conventions', 2, 'Coordinates name every artifact', $body$Every Maven artifact is identified by coordinates: groupId names the organization or project family, artifactId names the artifact within it, and version selects one release line. The groupId is usually a reversed domain such as dev.javacraft, and the triple is called the GAV. Repositories store artifacts under paths derived from these coordinates, and dependencies reference the same trio, so choosing stable, meaningful coordinates is an API decision, not paperwork. The pitfall is renaming or relocating coordinates later: consumers must change every dependency, and cached copies linger under the old path. Treat coordinates as a public contract once anything is published.$body$, $code$<groupId>dev.javacraft</groupId>
<artifactId>orders-service</artifactId>
<version>1.0.0-SNAPSHOT</version>
<packaging>jar</packaging>

<!-- Later, other projects depend on this same triple. -->$code$),
    ('maven-quickstart-and-conventions', 3, 'Run the first build', $body$With the layout and coordinates in place, the first build is a single command. mvn test compiles main and test sources and runs unit tests; mvn package also assembles the distributable artifact, and mvn install copies it into the local repository so other projects on the machine can consume it. Maven logs each phase and each plugin goal, so read the output top to bottom to learn what actually ran. Repeatedly running package while sources are unchanged mostly repeats work; during development, mvn test usually answers the question with less effort. Rule of thumb: run the smallest lifecycle phase that answers your current question.$body$, $code$# Maven reads the conventions; no build script is needed.
mvn test           # compiles sources and runs unit tests
mvn clean package  # rebuilds and produces the jar in target/
mvn install        # also copies the jar into the local repository
mvn clean          # removes target/ and starts fresh$code$),
    ('maven-pom-anatomy', 1, 'Model version and core coordinates', $body$Every POM starts with modelVersion 4.0.0, the version of the project object model schema that Maven reads. Below it sit the coordinates that identify this build: groupId, artifactId, and version. Optional elements such as name, description, and url document the project for generated sites and repository listings but never change build behavior. The model is declarative: you describe the desired result, and Maven decides which goals to run. The main pitfall is cargo-culting large POMs; most elements are unnecessary in a small project. Rule of thumb: if removing an element changes neither the build nor the published metadata, it probably does not belong.$body$, $code$<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>dev.javacraft</groupId>
  <artifactId>orders-service</artifactId>
  <version>1.0.0-SNAPSHOT</version>
  <packaging>jar</packaging>
</project>$code$),
    ('maven-pom-anatomy', 2, 'Packaging decides build products', $body$Packaging selects the default lifecycle bindings for a project. jar is the default, producing a library archive; war produces a web archive; pom produces no artifact beyond metadata and is used for aggregator and parent projects, which bind goals only to install and deploy. Because bindings differ by packaging, the same phases can do different work in different projects. A frequent mistake is setting packaging to pom on a module that actually compiles code, which silently skips compilation. Another is fighting defaults with elaborate plugin configuration when a different packaging value would have been honest. Rule of thumb: choose the packaging that describes the real product, then adjust only the edges.$body$, $code$<!-- packaging selects the default lifecycle bindings -->
<packaging>pom</packaging>  <!-- aggregator or parent metadata -->
<packaging>jar</packaging>  <!-- default for libraries and applications -->
<packaging>war</packaging>  <!-- web applications -->

mvn help:effective-pom  # prints the merged model Maven actually uses$code$),
    ('maven-pom-anatomy', 3, 'Parent inheritance basics', $body$A parent element lets a project inherit configuration from another POM: groupId, version, dependencyManagement, plugin configuration, and properties flow down to children. Only one parent is allowed, and the parent is resolved like a dependency, using its coordinates plus a relativePath hint for local builds. Inheritance is the backbone of shared conventions in multi-module builds, but it is also a coupling point: changing a parent affects every child immediately. The pitfall is a parent that accumulates unrelated, always-inherited configuration that most children do not need. Keep parent POMs small and intentional, and prefer explicit child configuration or profiles for exceptions.$body$, $code$<parent>
  <groupId>dev.javacraft</groupId>
  <artifactId>platform-parent</artifactId>
  <version>7.2.0</version>
  <relativePath>../pom.xml</relativePath>
</parent>

<artifactId>orders-service</artifactId>$code$),
    ('maven-build-lifecycle-and-phases', 1, 'Three lifecycles and ordered phases', $body$Maven defines three lifecycles: clean, default, and site. The default lifecycle orders the work that matters most: validate, compile, test, package, verify, install, and deploy. Invoking any phase runs every earlier phase in that lifecycle first, which is why mvn verify compiles, tests, and packages before it checks integration results. Hyphenated phases such as pre-integration-test sequence work for plugins but are not meant to be called from the command line; doing so can leave test environments running. The recommended single command for ordinary work is mvn verify. Rule of thumb: name the outcome you need, and let Maven walk the phases in order.$body$, $code$# Invoking a phase runs every earlier phase in the same lifecycle.
mvn validate   # project structure and metadata checks
mvn compile    # compile main sources
mvn test       # run unit tests (after compile)
mvn package    # build the jar or war (after test)
mvn verify     # run integration checks (after package)$code$),
    ('maven-build-lifecycle-and-phases', 2, 'Goals bind to phases', $body$A phase is a stage; a plugin goal is the work. Each goal may be bound to one or more phases, and a phase may have several goals, executed in the order they are declared. The packaging of a project sets the default bindings, and your own plugin declarations can add executions with explicit phase bindings, which is how extra checks join the lifecycle. Goals not bound to any phase can be run directly, as in mvn dependency:tree. The pitfall is assuming a goal runs by default when it does not: nothing runs unless a phase executes it. Rule of thumb: if a check must pass before release, bind it to a phase such as verify rather than documenting a manual command.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-antrun-plugin</artifactId>
  <version>3.2.0</version>
  <executions>
    <execution>
      <id>print-stage</id>
      <phase>validate</phase>
      <goals><goal>run</goal></goals>
    </execution>
  </executions>
</plugin>$code$),
    ('maven-build-lifecycle-and-phases', 3, 'Skip phases and tests safely', $body$Skipping is deliberately limited. -DskipTests compiles test sources but does not execute them; -Dmaven.test.skip=true skips compiling and running them entirely; -DskipITs skips integration tests while still compiling them. These flags exist for short feedback loops, not for releases, because an artifact verified with tests disabled has weaker evidence behind it. The deeper pitfall is skipping to make a red build green; the failure usually returns in production with far less context. In CI, allow skipping only where the same change runs the full suite in another job. Rule of thumb: skip locally to move fast, never skip on the pipeline that produces releasable artifacts.$body$, $code$# Compile tests but do not run them:
mvn package -DskipTests

# Skip compiling and running test code entirely:
mvn package -Dmaven.test.skip=true

# Skip integration tests but still compile them:
mvn verify -DskipITs$code$),
    ('maven-dependency-scopes', 1, 'Scope selects each classpath', $body$Scope tells Maven where a dependency belongs in the build. compile, the default, appears on the compile, test, and runtime classpaths and is inherited by consumers. provided appears on compile and test classpaths but not runtime, because the runtime environment supplies it. runtime appears on test and runtime classpaths but not compile, so code cannot compile against it. test appears only when compiling and running tests. The same jar can therefore be present in one phase and absent in another, and that is intentional. The pitfall is choosing scope by habit: a wrong scope either hides a class your production code needs or leaks a container API into your artifact. Rule of thumb: scope by who provides the dependency at production runtime.$body$, $code$<dependency>
  <groupId>com.acme</groupId>
  <artifactId>reports-core</artifactId>
  <version>3.4.0</version>
  <scope>compile</scope> <!-- default: compile, test, and runtime -->
</dependency>$code$),
    ('maven-dependency-scopes', 2, 'Provided APIs come from the runtime', $body$The provided scope exists for APIs that are guaranteed by the runtime environment: servlet containers, application servers, and test harnesses that inject the implementation. Declaring the API as provided lets your code compile without packaging a second copy that could conflict with the platform version. The sharp edge is drift: if the container on production is older than the API version you compiled against, methods can disappear at runtime even though the build succeeded. Excluding the library from packaging also means an accidental switch to a plain runtime fails immediately instead of adding a duplicate. Rule of thumb: pin provided dependencies to the container version that production actually ships.$body$, $code$<dependency>
  <groupId>jakarta.servlet</groupId>
  <artifactId>jakarta.servlet-api</artifactId>
  <version>6.0.0</version>
  <scope>provided</scope> <!-- the container supplies this at runtime -->
</dependency>$code$),
    ('maven-dependency-scopes', 3, 'Runtime test and import scopes', $body$runtime and test scopes keep artifacts off classpaths where they do not belong. The PostgreSQL JDBC driver is a classic runtime dependency: application code uses JDBC interfaces from the JDK, while the driver is only needed when a connection is created. Test libraries such as JUnit belong to test scope and never leak into published artifacts. The import scope is different in kind: it is valid only on a dependency of type pom inside dependencyManagement, where it pulls in the managed versions of another project without adding anything to the classpath. Rule of thumb: if production code does not compile against it but production needs it, choose runtime; if only tests need it, choose test.$body$, $code$<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <version>42.7.4</version>
  <scope>runtime</scope> <!-- not on the compile classpath -->
</dependency>
<dependency>
  <groupId>org.junit.jupiter</groupId>
  <artifactId>junit-jupiter</artifactId>
  <version>5.11.4</version>
  <scope>test</scope> <!-- never leaks into production artifacts -->
</dependency>$code$),
    ('maven-transitive-dependencies-and-exclusions', 1, 'Nearest definition wins mediation', $body$When several versions of the same artifact appear in the dependency graph, Maven resolves the conflict with nearest-wins mediation: the version closest to your project wins, measured in tree depth. If two candidates sit at the same depth, the one declared first wins. Declaring a dependency directly always makes your chosen version nearest, which is the reliable way to override a transitive version. The pitfall is reasoning from the POM you wrote instead of from the resolved tree, because an upgrade inside one library can silently change another library version. Rule of thumb: when a version matters, declare the artifact explicitly in your own POM and keep the override visible.$body$, $code$<dependency>
  <groupId>com.acme</groupId>
  <artifactId>chat-client</artifactId>
  <version>2.1.0</version>
</dependency>
<!-- chat-client pulls com.acme:json-core 1.4 indirectly;
     declaring json-core directly makes 3.0 the nearest definition. -->$code$),
    ('maven-transitive-dependencies-and-exclusions', 2, 'Exclusions cut unwanted branches', $body$An exclusion removes a transitive dependency from a single dependency declaration, specified by groupId and artifactId. It is the right tool when a library drags in something you never want on the classpath or when two frameworks fight over the same classes. But exclusions are blunt: they prune one branch and can break the library that needed the removed jar. Prefer upgrading or aligning the version when the conflict is pure version selection, and reach for exclusions when the transitive is genuinely unwanted. Each exclusion should carry a reason in review. Rule of thumb: one exclusion per known problem, never a blanket cleanup of a tree you have not read.$body$, $code$<dependency>
  <groupId>com.acme</groupId>
  <artifactId>chat-client</artifactId>
  <version>2.1.0</version>
  <exclusions>
    <exclusion>
      <groupId>commons-logging</groupId>
      <artifactId>commons-logging</artifactId>
    </exclusion>
  </exclusions>
</dependency>$code$),
    ('maven-transitive-dependencies-and-exclusions', 3, 'Read the dependency tree', $body$mvn dependency:tree prints the resolved graph and shows which paths supplied each artifact. Filter with -Dincludes=groupId:artifactId to focus on one coordinate, and add -Dverbose to see nodes omitted because of conflicts or duplicates. The tree reveals where a surprising version entered, which is usually faster than guessing. After pruning, run dependency:analyze to find code that uses undeclared dependencies and declarations that no code uses. The pitfall is trusting dependency:analyze blindly: it can misread reflection, service loaders, and annotation-only usage. Rule of thumb: treat the tree as evidence, confirm intent in code, and record deliberate overrides and exclusions in the POM.$body$, $code$# Show the resolved tree and where conflicts were dropped:
mvn dependency:tree
# Focus on one coordinate:
mvn dependency:tree -Dincludes=commons-logging:commons-logging
# Include omitted-for-conflict nodes:
mvn dependency:tree -Dverbose
# Find used-undeclared and declared-unused dependencies:
mvn dependency:analyze$code$),
    ('maven-dependency-management-and-boms', 1, 'Management sets versions not dependencies', $body$dependencyManagement declares versions and scopes that apply when a matching dependency is used later, in the same POM, a child module, or a transitive path; it never adds anything to the classpath by itself. Management beats nearest-wins mediation, and a declaration in the current POM beats one inherited from its parent, which makes the effective version predictable. This is how a parent keeps every module on one version of a library while children declare only groupId and artifactId. The pitfall is duplicating a version both in management and in a dependency element, which hides which value wins. Rule of thumb: one version per artifact in management, none in dependency declarations.$body$, $code$<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.acme</groupId>
      <artifactId>reports-core</artifactId>
      <version>3.4.0</version>
    </dependency>
  </dependencies>
</dependencyManagement>

<!-- Elsewhere, no version is needed: -->
<dependency>
  <groupId>com.acme</groupId>
  <artifactId>reports-core</artifactId>
</dependency>$code$),
    ('maven-dependency-management-and-boms', 2, 'Import a curated BOM', $body$A bill of materials is a POM with packaging pom whose dependencyManagement lists a coherent set of versions. Importing it with type pom and scope import copies those managed versions into your POM, letting a project inherit more than one curated set despite having a single parent. Imports resolve in declaration order: when two imported BOMs manage the same artifact, the first one wins unless your own POM overrides it. The pitfall is importing a BOM and still pinning some members manually, which reintroduces the drift the BOM was meant to remove. Rule of thumb: import the BOM, declare members without versions, and override only with a recorded reason.$body$, $code$<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.junit</groupId>
      <artifactId>junit-bom</artifactId>
      <version>5.11.4</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>$code$),
    ('maven-dependency-management-and-boms', 3, 'Align versions across modules', $body$Across modules, the parent POM is the right place to hold one version per library family, either through dependencyManagement entries or through version properties referenced by them. Children then declare the dependency without a version, so a single edit moves the whole build. This alignment matters most for libraries that must agree with each other, such as Jackson modules or logging bridges. The pitfall is mixing schemes: some modules using properties, others literal versions, and a few relying on transitive choice. Tools expose drift: dependency:tree shows resolved versions, and the enforcer dependencyConvergence rule fails the build when versions cannot be agreed. Rule of thumb: one lineage, one version, declared once.$body$, $code$<!-- parent pom.xml -->
<properties>
  <jackson.version>2.18.2</jackson.version>
</properties>

<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>${jackson.version}</version>
    </dependency>
  </dependencies>
</dependencyManagement>$code$),
    ('maven-plugins-and-executions', 1, 'Plugins declare goals and configuration', $body$A plugin is a packaged set of goals, identified by groupId and artifactId like any artifact; the version suffix selects behavior, so always declare it. A plugin element can carry configuration that applies to every goal in that plugin, and it can be placed in pluginManagement to set the version once for all children while each module adds its own configuration. Unversioned plugins resolve to whatever the Super POM or an ancestor decides, which breaks reproducibility between machines and between Maven releases. The pitfall is letting plugin versions drift while only dependency versions are managed. Rule of thumb: manage every plugin version in a parent, and list only the plugins that actually run.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.14.0</version>
  <configuration>
    <release>21</release>
  </configuration>
</plugin>$code$),
    ('maven-plugins-and-executions', 2, 'Executions bind goals to phases', $body$An execution groups goals with an id, a phase, and its own configuration. The id matters: default executions created by packaging have generated ids, and reusing one accidentally overrides built-in behavior, while a new id adds work alongside it. Declaring phase is what makes an execution part of the build; without it, the plugin goal runs only when invoked directly on the command line. Multiple executions of one plugin are legal; declaring the same plugin element twice is not, and produces warnings in Maven 3 and an error in Maven 4. Rule of thumb: give every custom execution a descriptive id and an explicit phase so its position in the lifecycle is obvious.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-jar-plugin</artifactId>
  <version>3.4.2</version>
  <executions>
    <execution>
      <id>attach-tests</id>
      <goals><goal>test-jar</goal></goals>
    </execution>
  </executions>
</plugin>$code$),
    ('maven-plugins-and-executions', 3, 'Know the common build plugins', $body$A working build usually needs a small set. maven-compiler-plugin compiles with the configured release level; maven-surefire-plugin runs unit tests during test; maven-failsafe-plugin runs integration tests during integration-test and verify; maven-jar-plugin builds the primary artifact; maven-shade-plugin repackages a self-contained jar and is bound to package. Each defaults to a version matched with Maven, but pinning versions is still wise for reproducibility. The pitfall is stacking plugins that duplicate responsibility, such as two shading plugins or overlapping test runners. Rule of thumb: add a plugin only for a need the packaging bindings do not already satisfy, and remove plugins the build no longer exercises.$body$, $code$# compiler  - language level and javac flags (compile)
# surefire  - unit tests (test)
# failsafe  - integration tests (integration-test, verify)
# jar       - primary artifact (package)
# shade     - uber-jar with dependencies (package)
mvn help:describe -Dplugin=org.apache.maven.plugins:maven-shade-plugin -Ddetail$code$),
    ('maven-surefire-and-failsafe', 1, 'Separate unit and integration tests', $body$Surefire and failsafe share a test engine but differ in intent. Surefire runs unit tests during the test phase; if one fails, the build stops there. Failsafe runs integration tests after packaging, during integration-test and verify, and it does not fail the build during integration-test, so teardown phases still execute before verify reports results. Each plugin matches class names by convention: Test*, *Test, and *Tests for surefire; IT*, *IT, and *ITCase for failsafe. Mixing the conventions defeats the split, because tests silently move from one runner to the other. Rule of thumb: unit tests stay fast and isolated; integration tests that need containers, ports, or databases carry an IT name and run under failsafe.$body$, $code$// Run by surefire during the test phase:
class OrderTotalTest { }

// Run by failsafe during integration-test and verify:
class OrderFlowIT { }

// Also matched by failsafe: ITOrderFlow.java, OrderFlowITCase.java$code$),
    ('maven-surefire-and-failsafe', 2, 'Failsafe verifies the packaged artifact', $body$Failsafe exists to test the artifact you actually ship. Its integration-test goal runs after package, then its verify goal checks the recorded results and fails the build if any test failed; that two-step design lets post-integration-test cleanup run even after failures. This is why you should invoke mvn verify instead of calling pre-integration-test, integration-test, or post-integration-test directly: those phases can leave databases or web servers running and produce no failure signal. A typical shape binds both goals in one execution. Rule of thumb: everything that exercises the packaged jar end to end belongs under failsafe, behind verify.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-failsafe-plugin</artifactId>
  <version>3.6.0</version>
  <executions>
    <execution>
      <id>integration-tests</id>
      <goals>
        <goal>integration-test</goal>
        <goal>verify</goal>
      </goals>
    </execution>
  </executions>
</plugin>$code$),
    ('maven-surefire-and-failsafe', 3, 'Filter and skip deliberately', $body$During development, filtering tests beats waiting for the whole suite: -Dtest=OrderTest runs matching unit tests, and -Dit.test=OrderFlowIT runs matching integration tests; both support wildcards, and failsafe fails when a filter matches nothing unless you disable that check. -DskipTests still compiles tests, -Dmaven.test.skip avoids even compiling, and -DskipITs skips only integration execution. The pitfall is class-name drift: a test renamed out of the IT pattern silently stops running in CI, which is worse than a visible failure. Rule of thumb: treat test naming as configuration, review it in pull requests, and let the full suite run unfiltered on the main branch.$body$, $code$# One unit test class:
mvn test -Dtest=OrderTotalTest
# One integration test class:
mvn verify -Dit.test=OrderFlowIT
# Skip integration tests but compile them:
mvn verify -DskipITs
# Skip unit test execution but compile test sources:
mvn package -DskipTests$code$),
    ('maven-multi-module-builds', 1, 'Aggregator and parent are different', $body$Two roles are often confused. An aggregator lists module directories in its modules element and runs the build across all of them. A parent shares configuration through inheritance. Both are usually packaging pom, and often one POM plays both roles, but the responsibilities are independent: a module can aggregate without parenting, and a parent can be consumed by projects outside its directory tree. Making a parent also an aggregator couples unrelated concerns and, in large trees, increases build times because the root drags everything into the reactor. Rule of thumb: use one root POM per repository for both roles, and add a separate parent only when external projects need shared rules.$body$, $code$<!-- aggregator: builds what it lists -->
<modules>
  <module>orders-api</module>
  <module>orders-service</module>
</modules>

<!-- parent: shares configuration through inheritance -->
<parent>
  <groupId>dev.javacraft</groupId>
  <artifactId>orders-parent</artifactId>
  <version>1.0.0</version>
</parent>$code$),
    ('maven-multi-module-builds', 2, 'Reactor orders modules by dependencies', $body$The reactor is the live graph of modules in a build. Maven sorts it topologically, so a module that depends on another builds after it, regardless of the order listed in modules. Inter-module dependencies use the same coordinates as external ones, with the shared project version. When a build is slow, subset it: -pl orders-service -am builds that module plus everything it needs, -pl alone builds only it, and -N builds just the root. The pitfall is diagnosing reactor failures without reading the summary, which names the failed module and the projects skipped afterward. Rule of thumb: let the reactor infer order from dependencies, and use selection flags instead of reordering modules.$body$, $code$<dependency>
  <groupId>dev.javacraft</groupId>
  <artifactId>orders-api</artifactId>
  <version>${project.version}</version>
</dependency>
<!-- The reactor orders modules so orders-api builds before orders-service. -->

mvn -pl orders-service -am package  # the module plus required modules$code$),
    ('maven-multi-module-builds', 3, 'Avoid version drift', $body$Version drift starts when modules repeat a version that the parent already owns. Children should declare the parent and omit groupId and version where both are inherited, and every inter-module reference should use the shared project version rather than a literal. When the version changes, one edit in the root moves the whole reactor; tools such as versions:set with processAllModules rewrite it consistently. The pitfall is a mixed tree where some modules pin old versions and other modules resolve them transitively, producing tests that pass with one classpath and fail with another. Rule of thumb: one version for the whole repository, referenced through properties or inherited values, never typed twice.$body$, $code$<!-- root pom.xml -->
<groupId>dev.javacraft</groupId>
<artifactId>orders-parent</artifactId>
<version>1.0.0</version>
<packaging>pom</packaging>

<!-- child module pom.xml: groupId and version are inherited, not repeated -->
<parent>
  <groupId>dev.javacraft</groupId>
  <artifactId>orders-parent</artifactId>
  <version>1.0.0</version>
</parent>$code$),
    ('maven-profiles-and-properties', 1, 'Properties are the first lever', $body$Properties are named values interpolated throughout the POM, and they are the cheapest customization mechanism: define a default in the properties element, reference it from a plugin or dependency, and override it per invocation with -Dname=value. They keep repeated values in one place, which matters for versions, encoding, and compiler release levels. The pitfall is treating properties as a configuration language: values are strings, resolution order can surprise you, and overusing them makes the effective POM hard to predict. Prefer generic changes through Maven-defined properties such as maven.compiler.release before inventing new ones. Rule of thumb: one property per value that must change in more than one place.$body$, $code$<properties>
  <maven.compiler.release>21</maven.compiler.release>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  <jackson.version>2.18.2</jackson.version>
</properties>

<!-- Override for one build: mvn package -Djackson.version=2.19.0 -->$code$),
    ('maven-profiles-and-properties', 2, 'Profiles adjust the build conditionally', $body$Profiles apply a patch of configuration when activated. Activation can be explicit with -P, or implicit based on the JDK, the operating system, an existing or missing file, or a property value; a profile marked activeByDefault is on unless another profile in the same POM is activated. Settings can also list active profiles. Deactivate one on the command line by prefixing its id with an exclamation mark. The pitfall is invisible conditionality: two developers run the same command and get different builds because their JDKs or files differ. Rule of thumb: treat activation as an input to the build, and print the active profiles in CI logs.$body$, $code$<profiles>
  <profile>
    <id>integration</id>
    <activation>
      <file><exists>docker-compose.yml</exists></file>
    </activation>
    <properties>
      <skipITs>false</skipITs>
    </properties>
  </profile>
</profiles>$code$),
    ('maven-profiles-and-properties', 3, 'Keep profiles few and purposeful', $body$Profile proliferation is a symptom, not a solution. Each profile doubles the number of effective POMs that must work, and because profiles are not inherited as containers, only their resolved effects reach children. Prefer properties for value changes, dependencyManagement for version alignment, and a profile only for structural differences: an extra plugin, a different repository, or platform-specific flags. A healthy repository usually has one profile for integration infrastructure and one for an unavoidable environment difference; the rest of the variation lives in CI variables. Rule of thumb: when the profile count grows past a handful, replace most of them with properties and document the survivors.$body$, $code$mvn help:active-profiles    # which profiles are active and why
mvn help:all-profiles       # every profile the build defines
mvn help:effective-pom      # merged model after profiles apply
mvn package -P integration  # activate explicitly
mvn package -P !integration # deactivate one profile$code$),
    ('maven-settings-and-repositories', 1, 'Settings configure the machine', $body$POMs describe a portable project; settings describe the machine that builds it. User settings live in the .m2 directory under the user home, global settings live under the Maven installation, and both can define the local repository location, mirrors, proxies, and server credentials. Because a POM can be published, repository URLs and credentials written there become public and fragile. The pitfall is copying internal repository declarations from POM to POM so the project only builds inside one network, which breaks contributors and open-source consumers. Rule of thumb: repository location is an environment property; keep it in settings.xml and keep POMs free of network topology.$body$, $code$<!-- ~/.m2/settings.xml: user-level; ${maven.home}/conf/settings.xml: global -->
<settings>
  <localRepository>${user.home}/.m2/repository</localRepository>
</settings>

<!-- Repository locations belong here, not in individual POMs. -->$code$),
    ('maven-settings-and-repositories', 2, 'Mirrors redirect repository requests', $body$A mirror intercepts requests for a repository and sends them to another URL, which is how organizations route Maven Central through an internal repository manager for caching, policy, and auditing. mirrorOf selects what is mirrored: an exact id such as central, everything with *, or everything external with external:*. Since Maven 3.8.1, plain HTTP external repositories are blocked by default through a built-in mirror, so internal mirrors should use HTTPS. Maven picks one mirror per repository, preferring an exact match and otherwise the first match by declaration order. The pitfall is a mirror that silently substitutes different artifacts. Rule of thumb: mirror through a manager that proxies the real repository and records what it served.$body$, $code$<mirrors>
  <mirror>
    <id>internal</id>
    <name>Internal repository manager</name>
    <url>https://repo.example.com/maven2</url>
    <mirrorOf>*</mirrorOf>
  </mirror>
</mirrors>$code$),
    ('maven-settings-and-repositories', 3, 'Credentials stay outside the repository', $body$Credentials belong in settings.xml under servers, keyed by an id that must match the mirrored repository or the repository being deployed to; CI should inject them through environment variables or a secrets store, never through committed files. Maven can also encrypt passwords, storing the encrypted form in settings.xml and a master password separately, which protects casual reading but not a fully compromised workstation. The pitfall is a password or token committed once: rotating it is cheap, but scrubbing history across forks is not. Pair credentials with checksum verification so a compromised download is detectable. Rule of thumb: secrets by reference, scoped narrowly, rotated on any suspicion.$body$, $code$<servers>
  <server>
    <id>internal</id>   <!-- must match the mirror or repository id -->
    <username>build</username>
    <password>${env.REPO_PASSWORD}</password>
  </server>
</servers>

<!-- Encrypt interactively with: mvn --encrypt-password -->$code$),
    ('maven-wrapper-and-version-pinning', 1, 'The wrapper pins Maven', $body$The Maven Wrapper is the recommended way to pin a specific Maven version to a repository. Running mvn wrapper:wrapper with a target version adds the mvnw and mvnw.cmd scripts plus the .mvn/wrapper directory so everyone builds with the same Maven, even when no Maven is installed. Commit the wrapper files with the project and make it the only supported entry point. The pitfall is running a wrapper generated once and never upgraded, so the pinned version ages past support while upgrades become risky. Treat the wrapper as part of the build definition: version bumps are explicit, reviewed changes. Rule of thumb: if a repository contains mvnw, CI should call ./mvnw and never a PATH Maven.$body$, $code$# Adds mvnw, mvnw.cmd, and .mvn/wrapper/maven-wrapper.properties
mvn wrapper:wrapper -Dmaven=3.9.9

./mvnw -v
./mvnw clean verify
./mvnw help:effective-pom$code$),
    ('maven-wrapper-and-version-pinning', 2, 'Change versions in wrapper properties', $body$Wrapper behavior is driven by maven-wrapper.properties. distributionUrl names the exact Maven distribution to download and run, so version changes are edits to that URL rather than local reinstallations. distributionSha256Sum optionally verifies the download against a known hash, which is the supply-chain check worth enabling. The default wrapper type adds only scripts, while the bin and source variants commit a jar or a downloader source file; keep the script default unless policy requires otherwise. An internal mirror can redirect downloads with an environment variable. The pitfall is hand-editing URLs to versions nobody has verified. Rule of thumb: bump the distribution URL deliberately, keep the checksum, and let the first CI run prove the new version.$body$, $code$# .mvn/wrapper/maven-wrapper.properties
# The wrapper downloads and runs exactly this Maven version.
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip
# Optional but recommended: verify the download.
distributionSha256Sum=<sha256 of the distribution zip>$code$),
    ('maven-wrapper-and-version-pinning', 3, 'Consistency across local and CI', $body$Version pinning pays off when every environment honors it. CI pipelines should run ./mvnw with batch and no-transfer-progress flags to keep logs readable, and they should fail when the wrapper was bypassed. Diagnosing wrapper problems is straightforward: verbose mode prints download URLs, and an environment variable points the wrapper at an internal mirror when direct access to the distribution host is blocked. The pitfall is a machine with a newer global Maven that builds successfully but differently, hiding the mismatch until CI rejects it. Rule of thumb: one pinned Maven per repository, upgraded in a dedicated commit with a green pipeline, and documented in the contributor instructions.$body$, $code$# CI uses the same pinned wrapper as developers:
./mvnw -B -ntp clean verify

# Diagnose wrapper downloads or point it at an internal mirror:
MVNW_VERBOSE=true ./mvnw -v
MVNW_REPOURL=https://repo.example.com/maven2 ./mvnw -v$code$),
    ('maven-toolchains', 1, 'Compile with a chosen JDK', $body$Toolchains decouple the JDK that runs Maven from the JDK that compiles and tests the code. The toolchains.xml file describes installed JDKs: each toolchain lists its type, the version and vendor it provides, and the jdkHome path. Maven matches requirements against that descriptor instead of searching the machine, so a build can run on a current JVM while producing artifacts for an older language level on a pinned JDK, independent of whatever JAVA_HOME happens to be. The pitfall is stale or duplicated descriptors drifting from the installed JDKs, which produces confusing lookups. Rule of thumb: one descriptor per supported build JDK, kept in machine setup and reviewed with upgrades.$body$, $code$<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>21</version>
      <vendor>temurin</vendor>
    </provides>
    <configuration>
      <jdkHome>/opt/jdk/21</jdkHome>
    </configuration>
  </toolchain>
</toolchains>$code$),
    ('maven-toolchains', 2, 'Select the toolchain in the POM', $body$Declaring the requirement is a deliberate POM change. The maven-toolchains-plugin binds its toolchain goal to validate, reads toolchain requirements from configuration, and stores the selected toolchain for the session; toolchain-aware plugins such as the compiler and surefire then use it instead of the running JVM. Requirements name a version and optionally a vendor, so teams can demand a specific distribution such as temurin or accept a version range. Toolchains complement, not replace, the compiler release setting: the toolchain chooses which JDK executes, while release pins the bytecode and API surface. The pitfall is requiring a toolchain but omitting the descriptor. Rule of thumb: declare the requirement near the modules that need it, and document the expected toolchains.xml.$body$, $code$<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-toolchains-plugin</artifactId>
  <version>3.3.0</version>
  <executions>
    <execution>
      <goals><goal>toolchain</goal></goals>
    </execution>
  </executions>
  <configuration>
    <toolchains>
      <jdk><version>21</version><vendor>temurin</vendor></jdk>
    </toolchains>
  </configuration></plugin>$code$),
    ('maven-toolchains', 3, 'Consistency and failure modes', $body$Toolchain selection fails loudly when no configured toolchain satisfies the requirement, which is the point: the build stops instead of silently compiling with the default JVM. Alternate descriptor locations help on shared agents: -t points at a user toolchains file and -gt at a global one, so container images can ship descriptors outside the user home. Remember that vendor strings are matched literally, so a typo blocks selection even when a suitable JDK exists, and that version matching follows Maven range syntax. Rule of thumb: keep toolchain descriptors in machine provisioning, verify them at agent startup, and let the build fail rather than fall back to an unpinned JDK.$body$, $code$# Point Maven at an alternate user toolchains file:
mvn -t /opt/toolchains.xml verify

# Or at an alternate global toolchains file:
mvn -gt /etc/maven/toolchains.xml verify

mvn toolchains:help$code$),
    ('maven-reproducible-builds', 1, 'Bit-for-bit identical artifacts', $body$A reproducible build produces bit-for-bit identical artifacts from the same source, environment, and instructions, no matter who runs it. This matters beyond tidiness: verification and supply-chain attestation require that anyone can rebuild a published binary and compare hashes. Maven supports this at the plugin level, with no special Maven version required, by removing sources of nondeterminism such as embedded timestamps and unstable file ordering. The maven-artifact-plugin can compare builds and check the build plan. The pitfall is assuming a second local build proves third-party reproducibility; a local compare is necessary but not sufficient, because environment leaks remain. Rule of thumb: make reproducibility a build property, then verify it in CI before publishing.$body$, $code$# Build once and install the reference artifacts:
mvn clean install

# Rebuild and compare byte for byte against the installed copy:
mvn clean verify artifact:compare
mvn artifact:buildinfo$code$),
    ('maven-reproducible-builds', 2, 'Configure the output timestamp', $body$The central switch is the project.build.outputTimestamp property. Setting it to a fixed ISO-8601 instant tells plugins to record that value in archive entries instead of the current clock, which removes the most common source of differing bytes. Run artifact:check-buildplan to list plugins that need upgrades for full support, then repeat builds and compare. During local iteration, mvn clean install followed by mvn clean verify artifact:compare rebuilds and compares against the installed reference. The pitfall is setting the timestamp once and letting it drift from the actual release commit, which still verifies but misstates provenance. Rule of thumb: update the timestamp as part of the release process so it stays meaningful.$body$, $code$<properties>
  <project.build.outputTimestamp>2025-01-15T00:00:00Z</project.build.outputTimestamp>
</properties>

# List plugins that need upgrades for full support:
mvn artifact:check-buildplan
# Rebuild and compare against the installed reference:
mvn clean verify artifact:compare$code$),
    ('maven-reproducible-builds', 3, 'Know the reproducibility limits', $body$Reproducibility has known boundaries. Version ranges must be avoided because they can resolve differently over time. Archives produced on Windows and Unix can differ because of line endings. Compiled bytecode generally depends on the major JDK version, even when source and target levels are fixed, and some plugins still lack fully deterministic output. The practical response is a pinned toolchain, locked versions, and a CI job that rebuilds and compares before publication; the artifact plugin reports differences for investigation. The pitfall is declaring reproducibility achieved after one green compare. Rule of thumb: verify from a second environment, keep the verification in the release checklist, and fix the plugin, not the hash.$body$, $code$# Avoid version ranges; they resolve differently over time.
# Windows and Unix checkouts can produce different bytes from newlines.
# Bytecode also depends on the major JDK version used to compile.
mvn clean install
mvn clean verify artifact:compare$code$),
    ('maven-release-and-versioning', 1, 'SNAPSHOT hygiene before release', $body$A SNAPSHOT version marks work in progress and is treated as mutable: other builds may resolve it repeatedly and pick up new content under the same coordinates. Releases are immutable and must be reproducible later, so an artifact must never be released from a snapshot build, and a released version must never be overwritten. Teams often check for updates with -U during development and suppress snapshot updates with -nsu when stability matters more than freshness. The pitfall is depending on snapshots from other projects, which makes builds fail whenever those projects publish a broken revision. Rule of thumb: snapshots stay inside the development cycle; releases move up to fixed versions and never change.$body$, $code$<!-- Development builds use snapshot versions; they are mutable. -->
mvn deploy
mvn -U clean verify    # force snapshot update checks
mvn -nsu clean verify  # suppress snapshot updates
mvn dependency:tree    # confirm which snapshot revision resolved$code$),
    ('maven-release-and-versioning', 2, 'Change versions in one pass', $body$The Versions Maven Plugin automates version rewriting. versions:set with a newVersion edits the project version, and with processAllModules it walks the reactor so parents and modules stay aligned, while versions:commit keeps the result and versions:revert restores the backups that are generated by default. Doing this by hand is where drift starts: one missed module is enough to publish a tree whose metadata disagrees with itself. The pitfall is running the goal across a repository that still has uncommitted work; generate the diff, review it, and commit the version change on its own so history stays readable. Rule of thumb: change versions with the tool, never with a text editor, and commit the result in isolation.$body$, $code$# Rewrite every module to the release version:
mvn versions:set -DnewVersion=1.4.0 -DprocessAllModules

# Keep the change or discard it before committing:
mvn versions:commit
mvn versions:revert$code$),
    ('maven-release-and-versioning', 3, 'Automate releases from CI', $body$The Release Plugin automates the mechanics: release:prepare verifies a clean state, updates versions, commits, and tags; release:perform checks out the tag and deploys the artifacts; release:clean removes temporary files, and rollback exists for failed preparation. Parameters make intent explicit: releaseVersion for the release, developmentVersion for the next snapshot cycle, and tagName for the tag. CI can run both goals with a deployment token, which turns releasing into a pipeline with an audit trail instead of a laptop ritual. The pitfall is leaving credentials or a dirty working tree to chance; preparation should fail early when either is wrong. Rule of thumb: release only from an automated, reviewed pipeline.$body$, $code$mvn release:prepare -DreleaseVersion=1.4.0 \
    -DdevelopmentVersion=1.5.0-SNAPSHOT
mvn release:perform
mvn release:clean    # removes temporary files on failure
mvn release:rollback # undo a failed preparation$code$),
    ('maven-enforcer-and-quality-gates', 1, 'Fail fast on environment promises', $body$Enforcer turns documented prerequisites into build checks. Its enforce goal binds to validate, so violations stop the build before compilation begins; rules such as requireJavaVersion, requireMavenVersion, and requireReleaseDeps assert the JDK, Maven, and snapshot-free dependency conditions the project promises. Each rule can run at ERROR, which fails the build, or WARN, which only reports, and failFast stops at the first violation instead of collecting the rest. The pitfall is rules that encode wishes rather than requirements, causing friction without protection. Rule of thumb: enforce only promises the team will act on, keep the rule list short, and let every failure message tell the reader how to fix the environment.$body$, $code$<execution>
  <id>enforce-environment</id>
  <goals><goal>enforce</goal></goals>
  <configuration>
    <rules>
      <requireJavaVersion><version>[21,)</version></requireJavaVersion>
      <requireMavenVersion><version>[3.9,)</version></requireMavenVersion>
    </rules>
  </configuration>
</execution>$code$),
    ('maven-enforcer-and-quality-gates', 2, 'Ban dependencies and enforce convergence', $body$Two rules carry most of the value. bannedDependencies fails when a matching artifact appears anywhere in the resolved graph; patterns use groupId, groupId:artifactId, and optional version segments, support wildcards, and can be narrowed with includes. dependencyConvergence fails when one artifact would be resolved to different versions in the same build, which is exactly the silent classpath surprise that breaks production. banDuplicatePomDependencyVersions catches the same dependency listed twice in one POM. The pitfall is banning a dependency without telling anyone what to use instead. Rule of thumb: every ban names a replacement, and convergence fixes go into dependencyManagement rather than scattered exclusions.$body$, $code$<rules>
  <bannedDependencies>
    <excludes>
      <exclude>commons-logging:commons-logging</exclude>
      <exclude>log4j:log4j</exclude>
    </excludes>
  </bannedDependencies>
  <dependencyConvergence/>
</rules>$code$),
    ('maven-enforcer-and-quality-gates', 3, 'Keep quality gates actionable', $body$Quality gates only work when they are few, fast, and owned. Each enforcer rule should express a policy someone maintains, with a failure message that names the remedy. Useful candidates include requiring plugin versions in a parent pluginManagement, banning snapshot dependencies on release branches, and checking convergence where dependency sets are combined. Because enforce binds to validate, feedback arrives in the first seconds of the build, which keeps fixes cheap. The pitfall is warning-level rules nobody reads or error-level rules that get bypassed with skip flags until they mean nothing. Rule of thumb: add a rule together with a drill that shows it failing, and review the rule list on the same cadence as dependency upgrades.$body$, $code$# Run the gates locally before pushing:
mvn validate

# Inspect a violating tree after a convergence failure:
mvn dependency:tree -Dverbose

# See why a specific version was selected:
mvn dependency:tree -Dincludes=ch.qos.logback:logback-classic$code$)
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
    'maven-quickstart-and-conventions', 'maven-pom-anatomy',
    'maven-build-lifecycle-and-phases', 'maven-dependency-scopes',
    'maven-transitive-dependencies-and-exclusions',
    'maven-dependency-management-and-boms', 'maven-plugins-and-executions',
    'maven-surefire-and-failsafe', 'maven-multi-module-builds',
    'maven-profiles-and-properties', 'maven-settings-and-repositories',
    'maven-wrapper-and-version-pinning', 'maven-toolchains',
    'maven-reproducible-builds', 'maven-release-and-versioning',
    'maven-enforcer-and-quality-gates'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
