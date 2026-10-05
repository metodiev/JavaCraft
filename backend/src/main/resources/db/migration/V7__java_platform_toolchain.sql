-- V7 - Java platform, JDK, and toolchain tutorials.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('jdk-vs-jre-vs-jvm', 'JDK, JRE, and JVM Compared', 'Explain what the JVM, the runtime, and the development kit each provide and why the distinction still matters.', 'Junior', 18, true, 1),
    ('installing-a-jdk', 'Installing a JDK on macOS, Linux, and Windows', 'Install a JDK with the native package manager or a version manager and verify the exact version your shell resolves.', 'Junior', 32, true, 1),
    ('jdk-distributions-compared', 'Comparing JDK Distributions and Licenses', 'Compare the major OpenJDK distributions by licensing, support windows, platform coverage, and extra tooling.', 'Junior', 24, true, 1),
    ('java-release-cadence', 'The Java Release Cadence Explained', 'Understand the six-month feature train, the two-year LTS rhythm, and how preview and incubator features ship.', 'Junior', 20, true, 1),
    ('choosing-a-java-version', 'Choosing the Right Java Version', 'Pick a Java release deliberately and express that choice through toolchains, release flags, and bytecode targets.', 'Junior', 26, true, 1),
    ('java-home-and-path', 'Configuring JAVA_HOME and PATH', 'Wire JAVA_HOME and PATH so every tool resolves the same JDK on developer machines and build agents.', 'Junior', 28, true, 1),
    ('jdk-command-line-tools', 'A Tour of the JDK Command Line Tools', 'Survey the JDK command line tools and decide which one answers the question in front of you.', 'Junior', 34, true, 1),
    ('jshell-quick-experiments', 'Quick Experiments with jshell', 'Use the interactive Java REPL to explore APIs and keep experiments without a full build cycle.', 'Junior', 18, true, 1),
    ('classpath-vs-modulepath', 'Class Path versus Module Path', 'See how classes and modules are located at compile and run time and how to diagnose resolution failures.', 'Junior', 30, true, 1),
    ('java-module-system-basics', 'Java Module System Basics', 'Write module descriptors, apply strong encapsulation, and move an application to the module path in stages.', 'Junior', 36, true, 1),
    ('packaging-java-applications', 'Packaging Java Applications for Release', 'Choose between fat JARs, linked runtime images, and native installers when distributing a service or tool.', 'Mid', 38, true, 1),
    ('jvm-architecture-internals', 'Inside JVM Architecture and Execution', 'Follow a class through loading, linking, and initialization and see how HotSpot compiles code over time.', 'Mid', 40, true, 1),
    ('garbage-collection-basics', 'Garbage Collection Fundamentals', 'Understand default G1 behavior, when ZGC is a better fit, and how to read garbage collection logs.', 'Mid', 34, true, 1),
    ('jvm-diagnostics-toolbox', 'The JVM Diagnostics Toolbox', 'Reach for the right JDK diagnostic tool during an incident and collect evidence without making things worse.', 'Mid', 36, true, 1),
    ('debugging-java-in-the-ide', 'Debugging Java Applications in the IDE', 'Debug efficiently with conditions, logpoints, remote attachment, and container-safe debug configuration.', 'Mid', 30, true, 1),
    ('migrating-between-java-lts', 'Migrating Between Java LTS Releases', 'Plan and stage an LTS upgrade from 17 through 21 and 25 with explicit gates and a working rollback path.', 'Mid', 42, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('jdk-vs-jre-vs-jvm', 1, 'Separate the runtime from the tooling', $body$The JVM is the execution engine that loads compiled bytecode and runs it. A Java runtime image adds the core class libraries and supporting files an application needs at run time, while the JDK is the full development kit: a runtime image plus the compilers and tools such as javac, jar, javadoc, and jshell. Development machines and build agents need the whole kit, and production machines need a runtime. Shipping a complete JDK to a server also ships a compiler that an intruder could abuse, and it bloats the image. Rule of thumb: know which role each machine plays, deploy the smallest runtime that can execute the application, and keep development tooling out of production containers.$body$, $code$// JDK versus runtime, seen from the command line.
public class ToolProbe {
    public static void main(String[] args) {
        System.out.println(Runtime.version());
    }
}
// javac ToolProbe.java   -> needs a JDK
// java ToolProbe         -> needs only a compatible runtime
// javadoc and jar are JDK tools as well.$code$),
    ('jdk-vs-jre-vs-jvm', 2, 'Why modern JDKs dropped the JRE', $body$Before JDK 11, installers often placed a separate JRE directory beside the JDK on Windows and macOS. The module system made that duplication unnecessary, because a JDK can be trimmed into a purpose-built runtime with jlink that contains only the modules an application actually uses. Oracle stopped offering a standalone JRE in JDK 11, and other distributions followed the same direction. The practical consequence is that production no longer points at a shared JRE installation: you run the JDK itself or link a smaller image, and you rebuild that image for security updates. Many CI images and Java-based tools now assume a full JDK is present. Rule of thumb: treat the runtime image as a build artifact rather than something preinstalled on the host.$body$, $code$# Assemble a runtime that contains only what the app needs.
jlink --add-modules java.base,java.logging \
      --output build/runtime \
      --strip-debug --no-header-files --no-man-pages
ls build/runtime/bin
build/runtime/bin/java -version
# The image is a build artifact: rebuild it for every security update.$code$),
    ('jdk-vs-jre-vs-jvm', 3, 'Building versus running needs', $body$A build pipeline compiles sources with javac, resolves dependencies, and produces artifacts. A runtime pipeline starts the JVM and executes those artifacts. Keeping the roles separate clarifies which environment needs which tooling: build agents need a JDK that matches the target platform, while runtime hosts need only a compatible runtime. Mixing the roles creates drift, because a container may quietly rely on the JDK that was present during the build instead of a pinned runtime. Record the exact distribution and version used for both roles, and assert them in CI so a raised version cannot slip through unnoticed. Rule of thumb: pin the toolchain for builds and pin the runtime for deployments, then verify both.$body$, $code$# Build stage: a full JDK compiles the sources.
javac --release 21 -d out src/Main.java
javap -v out/Main.class | grep major

# Runtime stage: only a compatible runtime is required.
java -cp out Main
java -version$code$),
    ('installing-a-jdk', 1, 'Choose an installation method', $body$Every platform offers several installation paths: a version manager that downloads and installs a distribution for you, or a package from the distribution vendor. On macOS, Homebrew casks and SDKMAN! both work well, and SDKMAN! is popular on Linux because it manages several release lines side by side and switches them per shell. On Linux, apt or dnf can install a vendor package, while SDKMAN! remains the easiest way to move between versions. On Windows, winget and Chocolatey install vendor packages, with manual MSI, EXE, or ZIP options as fallbacks. Mixing managers produces duplicate installations, confusing PATH order, and updates that fight each other. Rule of thumb: choose one method per machine, install from the official vendor channel, and stay with it.$body$, $code$# SDKMAN! manages several release lines from one shell.
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-tem
sdk install java 25-tem
sdk list java$code$),
    ('installing-a-jdk', 2, 'Package managers on each platform', $body$Homebrew installs macOS casks like applications and keeps its own copies, so brewed tools find the right JDK reliably. Linux package managers integrate with system updates but often lag the newest release lines, and a distribution package may land in a path the shell does not read first. Windows package managers integrate with the system PATH and registry, which matters for automatic IDE detection and for tools that expect JAVA_HOME. Package availability differs by distribution, so check that the vendor publishes a repository for your platform before standardizing on it. Rule of thumb: use the native package manager for the primary JDK, and add a version manager only when several release lines must coexist on one machine.$body$, $code$brew install --cask temurin@21              # macOS
sudo apt install temurin-21-jdk             # Debian and Ubuntu
sudo dnf install temurin-21-jdk             # Fedora and RHEL
winget install EclipseAdoptium.Temurin.21.JDK   # Windows
java -version$code$),
    ('installing-a-jdk', 3, 'Verify and pin the version', $body$After installing, confirm that the shell resolves the tools you expect before trusting the setup. Run java -version and javac -version and compare both the feature version and the vendor field, because two vendors can ship the same feature version with different builds. A common trap is a stale JAVA_HOME entry or an earlier PATH component silently winning, so java can report a different build than the one just installed. For reproducible builds, pin the exact version in a project file or a CI image, and upgrade deliberately instead of accepting whatever the manager considers current. Rule of thumb: verify twice, once in an interactive shell and once in the environment your build actually uses.$body$, $code$sdk use java 21-tem
java -version        # check the feature version and vendor
javac -version       # must report the same release
which -a java        # look for an older entry earlier on PATH
echo "$JAVA_HOME"    # must point at the pinned installation$code$),
    ('jdk-distributions-compared', 1, 'The main OpenJDK builds', $body$Temurin is the Eclipse Adoptium build of OpenJDK and a neutral default for many teams. Amazon Corretto is a validated build with long support windows on AWS and elsewhere. Azul Zulu covers many platforms and release lines, and Azul also ships commercial products with additional capabilities. GraalVM is a separate JDK distribution that adds native-image compilation and advanced optimizing runtime options. Microsoft Build of OpenJDK targets Azure and Windows environments. All of them derive from the OpenJDK sources and pass the same conformance testing, so application bytecode behaves the same on each. The real differences are support terms, update cadence, platform coverage, and extra tooling.$body$, $code$// Distinguish distributions at runtime.
Runtime.Version v = Runtime.version();
System.out.println("version: " + v);
System.out.println("vendor: " + System.getProperty("java.vendor"));
System.out.println("vm: " + System.getProperty("java.vm.name"));$code$),
    ('jdk-distributions-compared', 2, 'Licensing and support terms', $body$OpenJDK sources are available under the GPL with the Classpath Exception, so builds made from those sources are free to use. Vendors add their own terms on top: some publish free binaries under permissive licenses, while commercial support plans add guaranteed update windows, security fixes, and escalation paths. Oracle JDK updates for older release lines have moved to paid terms, and depending on them at no cost is risky for organizations. Read the license as part of the technical evaluation rather than afterward. Rule of thumb: choose a distribution whose license you can explain to a legal reviewer in one sentence, and match its support lifetime to the lifetime you plan for the service.$body$, $code$java -version
# openjdk version "21.0.x" LTS
# OpenJDK Runtime Environment Temurin-21.0.x (build 21.0.x+9-LTS)
# OpenJDK 64-Bit Server VM Temurin-21.0.x (build 21.0.x+9-LTS)
# The vendor and the LTS marker appear in the banner.$code$),
    ('jdk-distributions-compared', 3, 'How to choose a distribution', $body$Start from the deployment target, because managed platforms often provide a validated vendor build already. Then compare platform coverage, update frequency, and whether the vendor publishes checksums, machine-readable release metadata, and container images. Container teams usually care about image size and a predictable tag policy, while desktop teams care about installers and IDE integration. Verify any performance claim on your own workload, since general benchmarks rarely transfer to real services. Finally, write the decision down so future teams do not repeat the evaluation. Rule of thumb: standardize on one distribution per organization unless a platform forces an exception.$body$, $code$# Download the archive together with the vendor checksum file.
shasum -a 256 -c OpenJDK21U-jdk_x64_mac_hotspot_21.0.x.pkg.sha256.txt
# On Linux use: sha256sum -c <file>.sha256.txt
java -version
which java$code$),
    ('java-release-cadence', 1, 'Six month feature releases', $body$Since Java 9, the JDK project has shipped a feature release every March and September on a strict time-based schedule. Each release contains whatever was ready; a feature that misses the train waits for the next one. Most vendors support non-LTS releases only until the following release appears, so these lines suit teams that want early access to language and library improvements and can update often. Running the newest non-LTS in production means planning an upgrade roughly every six months. Rule of thumb: pick the cadence your team can actually sustain, because a release line that nobody updates quickly becomes an unpatched liability.$body$, $code$Runtime.Version v = Runtime.version();
System.out.println(v.feature());   // 21 for a JDK 21 runtime
System.out.println(v.toString());  // 21.0.x+9-LTS
// Runtime.version() was added in Java 9.
// Feature releases ship in March and September.$code$),
    ('java-release-cadence', 2, 'The two year LTS rhythm', $body$The LTS release lines follow a two-year rhythm, and several remain in wide use at once. Each LTS receives updates for years, which makes it the default choice for platforms and libraries that need stable support. Oracle publishes premier support windows with extended support beyond them, and other vendors publish their own policies, sometimes longer. When you adopt an LTS, plan its successor at least a year before support ends, because migrations that start under deadline pressure fail more often. Rule of thumb: keep production on an LTS, and schedule the next LTS upgrade as recurring work rather than a one-off project.$body$, $code$java -version
# openjdk version "25.0.x" 2025-09-16 LTS
# Prefer an LTS line in toolchain configuration.
sdk install java 25-tem
sdk default java 25-tem$code$),
    ('java-release-cadence', 3, 'Preview and incubator features', $body$Preview features are fully implemented but impermanent: they are disabled by default and require explicit flags at both compile time and run time. Code that uses a preview feature may not compile on the next release, because the design can still change. Incubator modules work in a similar spirit but ship under separate module names that must be added explicitly. This model lets teams try new APIs without freezing them into the platform. The trap is shipping preview usage inside a library that other teams depend on. Rule of thumb: use preview features for evaluation and prototypes, and wait for finalization before depending on them in released libraries.$body$, $code$javac --release 25 --enable-preview Main.java
java --enable-preview Main
# Both flags are required: preview code is rejected at compile
# time or at run time when --enable-preview is missing.
# Preview designs may change in the next release.$code$),
    ('choosing-a-java-version', 1, 'Start from an LTS line', $body$Choosing a version is a support decision more than a feature decision. Pick the newest LTS that your dependencies support, and confirm every framework, agent, and driver you run is tested on it. Libraries compiled for older releases usually run unchanged on newer ones, but libraries that reach into JDK internals can break when encapsulation tightens. Keep the chosen version in one obvious place so the toolchain file, container base image, and CI configuration agree. Rule of thumb: one LTS for production, one newer line for experiments, and a named owner responsible for moving between them.$body$, $code$plugins { id "java" }
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}
// Builds use a JDK 21 toolchain even on newer machines.$code$),
    ('choosing-a-java-version', 2, 'Bytecode version compatibility rules', $body$Class files carry a major version, and a JVM refuses to load files newer than itself. Compiling with a newer JDK and running on an older runtime therefore fails with UnsupportedClassVersionError even when the source uses no new syntax. Compatibility in the other direction holds: a newer JVM runs class files produced by older compilers, within the limits set by removed APIs. Because the runtime must be at least as new as the class file, plan upgrades so the JVM moves before the compiler. Rule of thumb: for each deployable artifact, compile for the oldest runtime you support and run it on the newest one you can.$body$, $code$javac --release 17 -d out src/Main.java  # class file major 61
java -cp out Main                          # requires JDK 17 or newer
javap -v out/Main.class | grep "major"     # inspect the class version
# Running major 61 on JDK 11 fails with UnsupportedClassVersionError.
# Move the runtime first, then the compiler.$code$),
    ('choosing-a-java-version', 3, 'Prefer release over source and target', $body$The --release flag tells javac to compile against the API signatures of a named platform version while producing the matching class file version. Using -source and -target alone can still link against libraries from the running JDK, so an accidental call to a newer API may compile and then fail at run time. Prefer --release wherever the build tool supports it, and set it once for the whole build instead of per module. If a build also needs a different bootclasspath, that is a sign to revisit the toolchain setup. Rule of thumb: when you must state a target version, state it through --release.$body$, $code$// Risk: -source and -target alone may link newer JDK APIs.
javac -source 21 -target 21 -d out $(find src -name "*.java")
java -cp out com.example.Main

// Preferred: --release pins the language level and platform API.
javac --release 21 -d out $(find src -name "*.java")
java -cp out com.example.Main$code$),
    ('java-home-and-path', 1, 'What JAVA_HOME and PATH mean', $body$PATH is the list of directories the shell searches for executable commands, so it decides which java and javac run when you type them. JAVA_HOME names a single JDK installation directory, and build tools, launchers, and scripts read it when they need that installation deliberately. The two can disagree: PATH may resolve to one release while JAVA_HOME points at another, and different tools prefer different answers. That mismatch is a common source of builds that pass on a laptop and fail in CI. Rule of thumb: keep both pointing at the same installation, and change them together when you switch versions.$body$, $code$export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export PATH="$JAVA_HOME/bin:$PATH"
which java          # must resolve under JAVA_HOME/bin
java -version
echo "$JAVA_HOME"$code$),
    ('java-home-and-path', 2, 'Switch versions per project', $body$Version managers let each project choose its release without editing global shell files. SDKMAN! can write a .sdkmanrc file and apply it in the current shell, jenv reads a .java-version file from the directory tree, and asdf binds versions through its own tool file. IDEs keep their own JDK settings, so a terminal may use one release while the editor compiles with another. Keep the chosen version in a file the team commits, and make CI read the same file. Rule of thumb: the project declares the version, the machine adapts, and nobody relies on whatever happens to be the default.$body$, $code$sdk env init      # write .sdkmanrc from the current version
cat .sdkmanrc
sdk env          # apply the file in this shell
jenv local 21    # writes .java-version for this directory
java -version$code$),
    ('java-home-and-path', 3, 'Pin versions in IDEs and CI', $body$IDE settings and CI images are separate configurations with their own quiet defaults. An IDE may bundle a JDK and use it for a project unless told otherwise, and a CI runner may expose several installations at once. Make both explicit: set the project language level and SDK in the IDE, and install exactly one intended JDK in the pipeline image, exposing it through JAVA_HOME. Then print java -version during the build so the log proves which toolchain ran. Rule of thumb: if the build log does not state the JDK version, the pin is not real.$body$, $code$steps:
  - uses: actions/setup-java@v4
    with:
      distribution: temurin
      java-version: "21"
  - run: java -version$code$),
    ('jdk-command-line-tools', 1, 'Compile, run, and package', $body$javac compiles source into class files, java launches a class, a JAR, or a module, and jar creates and inspects archives. These three cover the daily inner loop and stay useful even when a build tool wraps them, because their error messages are the ones you must interpret. Use the source-file mode of java for single-file experiments, and inspect a JAR with jar --list before debugging a missing resource or entry point. On modern JDKs, jar can also record module metadata inside the artifact. Rule of thumb: learn the underlying commands well enough to explain what your build tool does for you.$body$, $code$javac -d out $(find src -name "*.java")
jar --create --file app.jar --main-class com.example.Main -C out .
java -jar app.jar
jar --list --file app.jar
java Main.java      # source-file mode for a single-file program$code$),
    ('jdk-command-line-tools', 2, 'Document, inspect, and analyze', $body$javadoc generates reference documentation from source comments, and its doclint checks can fail the build on malformed tags, which keeps public API documentation trustworthy. javap disassembles class files and shows signatures, constants, and bytecode, which is invaluable when a version mismatch or bridge method confuses you. jdeps reports package and module dependencies and can flag use of JDK internal APIs before encapsulation breaks them. None of these tools change the artifact; they answer questions about it. Rule of thumb: reach for javap when the compiler disagrees with your mental model, and run jdeps before a module migration.$body$, $code$javap -c -p out/com/example/Main.class | head -20
jdeps --multi-release 21 --summary app.jar
javadoc -d docs -Xdoclint:all src/main/java/com/example/*.java
# javap answers what the class file contains.
# jdeps answers which modules and packages are used.$code$),
    ('jdk-command-line-tools', 3, 'Link, package, and experiment', $body$jlink assembles a custom runtime image from modules, producing a directory that can replace a full JDK on a server. jpackage builds platform installers that embed such a runtime so end users get a native experience. jshell offers an interactive prompt for trying an expression or an API without creating a project. These tools matter late in the lifecycle: they shrink images, simplify installation, and shorten feedback loops. Their limitations are practical: jlink needs a modular application or an explicit set of root modules, and jpackage must run on the target operating system. Rule of thumb: use jshell for questions and jlink or jpackage for distribution.$body$, $code$jlink --add-modules java.base,java.sql --output runtime --strip-debug
jpackage --type app-image --input out --main-jar app.jar --name demo
jshell
# jshell> "hello".toUpperCase()
# $1 ==> "HELLO"$code$),
    ('jshell-quick-experiments', 1, 'Evaluate expressions at the prompt', $body$jshell reads statements, evaluates them immediately, and prints results. Types declared in earlier snippets remain visible to later ones, so you can build up an experiment interactively instead of writing a whole file. It is the fastest way to check what a method returns, confirm a date conversion, or test a regular expression. The prompt also accepts commands that inspect and manage state, such as listing variables or saving the session to a file. Start with verbose feedback while learning, then switch to a normal mode once the extra detail becomes noise. Rule of thumb: if a question fits in one line, answer it in jshell before writing code.$body$, $code$jshell
jshell> var total = IntStream.rangeClosed(1, 10).sum();
total ==> 55
jshell> Math.sqrt(total)
$2 ==> 7.416198487095663
jshell> /exit$code$),
    ('jshell-quick-experiments', 2, 'Explore APIs before committing', $body$With jshell you can inspect a class, list its methods, and try calls without a build cycle. That shortens the loop when you are unsure about a signature or fallback behavior, and it keeps throwaway experiments out of the codebase. Because snippets run in one long-lived session, static state persists between entries, which is convenient for exploration but can mislead: a later result may depend on earlier mutations. Restart the session when results stop matching expectations. Rule of thumb: use jshell to learn an API, then write a real test for any behavior your code relies on.$body$, $code$jshell> List.of("a", "b").stream().map(String::toUpperCase).toList()
$1 ==> [A, B]
jshell> String.join("-", List.of("a", "b"))
$2 ==> a-b
jshell> /vars$code$),
    ('jshell-quick-experiments', 3, 'Save and replay sessions', $body$Work that starts in jshell often deserves to be kept. Save a session to a file, then reload it later or run it as a script to confirm the behavior reproduces. Snippets can also be loaded from a file at startup, which is useful for exercising a helper method in isolation. This makes jshell a bridge between an ad hoc experiment and a small program without a full project setup. Remember that jshell compiles with the running JDK, so it cannot tell you how code behaves on an older runtime. Rule of thumb: promote anything you keep reusing into a test or a real source file.$body$, $code$/save probe.jsh
/list
/exit
jshell probe.jsh
# Replays the saved snippets in a new session.$code$),
    ('classpath-vs-modulepath', 1, 'How the class path is searched', $body$The class path is an ordered list of directories, JAR files, and wildcard entries. At run time the application class loader searches entries in order and stops at the first match, so a stale copy earlier in the list silently shadows the intended one. At compile time javac uses the class path to resolve types, and the default is the current directory when nothing else is set. Prefer an explicit -cp or --class-path value over the CLASSPATH environment variable, because environment state is invisible in build scripts. Rule of thumb: when a class is missing or a wrong version loads, print the effective class path before changing anything.$body$, $code$java -cp "lib/app.jar:lib/*" com.example.Main
javac -cp "lib/*" -d out src/com/example/Main.java
# On Windows the separator is a semicolon:
java -cp "lib/app.jar;lib/*" com.example.Main
echo "$CLASSPATH"   # avoid relying on this variable$code$),
    ('classpath-vs-modulepath', 2, 'How module resolution differs', $body$The module path is not a flat search list. Each entry is a module artifact or a directory of modules, and resolution starts from a root set and follows requires edges until it reaches a fixed point. Because module names must be unique, a duplicate becomes an error instead of a silent shadow. On the class path, code in unnamed modules reads everything; on the module path, readability is explicit and a missing module fails resolution before the main method runs. Non-modular JARs placed on the module path become automatic modules with derived names and broad readability. Rule of thumb: use the module path where descriptors exist, and keep dependencies you cannot modularize on the class path deliberately.$body$, $code$javac -p mods -d out src/com.example.app/module-info.java
java -p mods -m com.example.app/com.example.app.Main
java -p mods --list-modules | grep example
# -p is short for --module-path.
# -m is short for --module.$code$),
    ('classpath-vs-modulepath', 3, 'Diagnose resolution failures', $body$Class path problems surface as ClassNotFoundException or NoClassDefFoundError at the moment a type is first needed, sometimes long after startup. Module path problems usually surface immediately as an error naming the missing module or package, because resolution happens before execution. In both cases the fix starts with evidence: list the actual entries, confirm the artifact contains the class with jar --list, and check for duplicate versions in a dependency report. Adding entries until something works is how class paths become unmaintainable. Rule of thumb: identify the missing element first, then add exactly one entry and run again.$body$, $code$java -cp "lib/*" com.example.Main
# Error: Could not find or load main class com.example.Main
jar --list --file lib/app.jar | grep com/example/Main.class
# If the class is absent, the artifact is wrong, not the class path.
# If it appears twice, find the duplicate dependency.$code$),
    ('java-module-system-basics', 1, 'Declare a module descriptor', $body$A module is a set of packages with a descriptor in module-info.java at the source root. The descriptor names the module, states which modules it requires, and chooses which of its own packages other modules may use. Module names usually follow a reverse domain convention and must be unique across the module graph. Inside a module, code reads only the modules it requires directly or transitively, so a missing requirement fails compilation with a clear message instead of surfacing later at run time. Rule of thumb: require what you use, export only what consumers need, and keep the descriptor short enough to review.$body$, $code$module com.example.app {
    requires java.logging;
    requires transitive com.example.core;
    exports com.example.app.api;
}$code$),
    ('java-module-system-basics', 2, 'Strong encapsulation and reflection', $body$Exports control compile-time and ordinary run-time access, but deep reflection into non-exported packages is also denied by default on the module path. Frameworks that reflect over application classes usually need opens, which grants reflective access to a package without granting ordinary access. This is why an application that worked on the class path can fail after moving to the module path even though its own code did not change. Add opens for the specific packages a framework must reach instead of opening everything. Rule of thumb: treat every open directive as a documented integration point with a named owner.$body$, $code$module com.example.app {
    requires java.sql;
    requires com.fasterxml.jackson.databind;
    opens com.example.app.dto to com.fasterxml.jackson.databind;
    exports com.example.app.api;
}$code$),
    ('java-module-system-basics', 3, 'Migrate to modules incrementally', $body$Most applications can move to the module path in stages. First compile with a release flag and upgrade libraries to versions that at least carry usable automatic module names. Next run from the module path with everything treated as automatic modules, which already enforces uniqueness and resolution. Then add a descriptor once dependencies resolve cleanly, and finally tighten access by replacing broad opens with pure exports. Keeping some dependencies on the class path is a valid end state, not a failure. Rule of thumb: migrate the application module first, then dependencies that publish descriptors, one at a time.$body$, $code$# Stage 1: run without a descriptor, treating JARs as automatic modules.
java -p mods:lib -m com.example.app

# Stage 2: inspect dependencies before writing module-info.
jdeps --module-path lib --generate-module-info . app.jar

# Stage 3: add a descriptor once resolution is clean.
java -p mods:lib -m com.example.app$code$),
    ('packaging-java-applications', 1, 'Fat JAR trade-offs', $body$A shaded or fat JAR merges application classes and dependency classes into one archive. It is simple to ship and run with java -jar, which makes it popular for services and command-line tools. The costs appear later: duplicate entries from two dependencies, service files that must be merged instead of overwritten, signed JARs whose signatures break when repackaged, and an archive that carries code no path reaches. Shading also hides dependency versions unless the build emits a report. Rule of thumb: use fat JARs when deployment simplicity dominates, and configure resource merging and conflict reporting explicitly.$body$, $code$<plugin>
  <artifactId>maven-shade-plugin</artifactId>
  <configuration>
    <transformers>
      <transformer implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
    </transformers>
  </configuration>
</plugin>$code$),
    ('packaging-java-applications', 2, 'Custom runtime images with jlink', $body$jlink builds a runtime image containing the JDK modules your application needs. The result is a directory with its own bin/java and only the modules in the dependency closure, often far smaller than a full JDK. Requirements matter: the application should be modular, or at least expressible as a root module set, and its dependencies must resolve as modular or automatic modules. Because each image is a build artifact, teams must rebuild it for every security update instead of patching a shared runtime. Rule of thumb: use jlink where image size and attack surface matter and the module graph can stay clean.$body$, $code$jlink --add-modules com.example.app \
      --module-path mods \
      --output build/runtime \
      --strip-debug --no-header-files --no-man-pages
build/runtime/bin/java -m com.example.app$code$),
    ('packaging-java-applications', 3, 'Native installers with jpackage', $body$jpackage wraps an application and a runtime image into a platform installer such as dmg, msi, deb, or rpm, plus a portable app-image directory. It can link the runtime itself, so end users install no separate Java. The constraints are practical: packaging runs on the target operating system and may depend on that platform tooling, so a multi-platform release needs one build runner per platform. Updates also become the responsibility of the application, since there is no shared runtime to patch centrally. Rule of thumb: choose jpackage for desktop distribution to non-technical users, and keep server deployments on container images or fat JARs.$body$, $code$jpackage --type dmg \
         --input out \
         --main-jar app.jar \
         --main-class com.example.Main \
         --name Demo \
         --runtime-image build/runtime$code$),
    ('jvm-architecture-internals', 1, 'Class loading and linking', $body$The JVM loads classes lazily through a hierarchy of loaders: the bootstrap loader, the platform loader, and the system loader that handles the class path and module path. Loading locates the bytes, linking verifies and prepares them, and initialization runs static initializers exactly once per class. Verification is what lets the JVM trust bytecode it did not compile. Because loading happens on first use, a missing dependency can surface only when a rarely executed branch runs, which is why integration tests must exercise those paths. Rule of thumb: keep static initializers cheap and free of external calls, since they run while a thread holds the class initialization lock.$body$, $code$public class LoaderProbe {
    public static void main(String[] args) {
        ClassLoader app = LoaderProbe.class.getClassLoader();
        System.out.println(app);
        System.out.println(app.getParent());
        System.out.println(String.class.getClassLoader()); // null: bootstrap
    }
}$code$),
    ('jvm-architecture-internals', 2, 'Runtime data areas', $body$Each JVM thread owns a program counter and a stack of frames that hold local variables and operand values. The heap is shared and holds all objects, and the metaspace holds class metadata outside the heap. Stack frames are created per method invocation and released on return, so deep recursion or very large frames overflow the stack rather than the heap. The heap is where allocation pressure accumulates, and its size together with the collector determines pause behavior. Rule of thumb: when diagnosing memory, separate the question of what lives on the heap from the question of how much stack concurrent threads require.$body$, $code$java -Xms512m -Xmx2g -Xss512k -XX:MaxMetaspaceSize=256m -jar app.jar
# -Xms and -Xmx bound the heap.
# -Xss sets each thread stack size.
# MaxMetaspaceSize bounds class metadata outside the heap.
java -XX:+PrintFlagsFinal -version | grep -i maxheap$code$),
    ('jvm-architecture-internals', 3, 'JIT compilation tiers', $body$HotSpot starts by interpreting bytecode, then compiles frequently executed methods, first with the C1 compiler and later with the C2 compiler using profile data. C1 produces code quickly with modest optimization, while C2 optimizes aggressively and can deoptimize when an assumption is invalidated, returning execution to the interpreter until recompilation. This tiered design explains why throughput improves after warmup and why benchmarks that ignore warmup mislead readers. Chasing warmup with manual micro-tuning often makes code quality worse rather than better. Rule of thumb: measure after steady state, and let the compiler observe enough iterations before drawing conclusions.$body$, $code$java -XX:+PrintCompilation -jar app.jar | head
# Tier 3: C1 compiled with profiling.
# Tier 4: C2 optimized.
# Made not entrant: deoptimized, possibly recompiled later.
# PrintCompilation writes one line per compilation event.$code$),
    ('garbage-collection-basics', 1, 'G1 as the default collector', $body$G1 has been the default collector since Java 9. It divides the heap into regions, collects young regions frequently, and occasionally collects old regions, aiming to meet a pause-time target rather than maximize raw throughput. Defaults adapt to the machine, which is convenient but not tuned for any specific service. Two settings matter most in practice: a maximum heap that matches the container limit, and a pause target that reflects the latency the service promises. Pressing the pause target too low forces smaller collections and adds overhead. Rule of thumb: size the heap from measured live data, set the pause goal from a latency budget, and leave the rest alone.$body$, $code$java -XX:+UseG1GC \
     -Xms1g -Xmx1g \
     -XX:MaxGCPauseMillis=200 \
     -Xlog:gc*:file=gc.log:time,uptime,tags \
     -jar app.jar$code$),
    ('garbage-collection-basics', 2, 'ZGC for low latency', $body$ZGC performs most of its work concurrently with application threads, so pause times stay very low regardless of heap size. It suits large heaps and services with strict tail-latency requirements, at the cost of some throughput and memory overhead. Since JDK 23, the generational mode is the default for ZGC, and the non-generational mode is deprecated for removal. ZGC is not a substitute for fixing an allocation problem: a service that allocates continuously under load will spend CPU on collection no matter which collector runs. Rule of thumb: move to ZGC for latency problems proven by measurement, and compare throughput under the same load before and after.$body$, $code$java -XX:+UseZGC -Xms4g -Xmx4g -Xlog:gc:file=zgc.log -jar app.jar
# Generational ZGC is the default ZGC mode since JDK 23.
# Non-generational ZGC is deprecated for removal.
java -XX:+UseZGC -XX:-ZGenerational -jar app.jar   # deprecated legacy mode
java -version$code$),
    ('garbage-collection-basics', 3, 'Read GC logs before tuning', $body$GC logs answer concrete questions: how often collections run, how long they pause, how much memory they reclaim, and whether the heap fills with live objects. Logging is cheap enough to leave enabled with file rotation, and it is essential evidence during an incident. Check the allocation rate first, because a high rate explains frequent young collections without any tuning problem. Then check whether old collections recover memory: if the heap returns to nearly the same size each time, the service holds live data and needs more memory or less retention. Rule of thumb: change one flag at a time and verify with logs.$body$, $code$java -Xlog:gc*:file=gc.log:time,uptime,level,tags -jar app.jar
grep -E "Pause Young|Pause Full" gc.log | tail -20
# Compare pause durations and reclaimed memory across collections.
# A heap that returns to the same size after every collection
# suggests retained live data rather than a tuning problem.$code$),
    ('jvm-diagnostics-toolbox', 1, 'Start with jcmd and jstat', $body$jcmd is the first stop because it lists every Java process the user can attach to and offers commands such as VM.info, Thread.print, and GC.heap_info through one tool. jstat samples counters, including heap usage and collection counts, at a chosen interval, which shows whether the JVM is under memory pressure right now. Both attach to a running process without a restart and are safe to run at low frequency in production. Confirm the process identity and version before trusting the numbers, especially in containers where many JVMs share a host. Rule of thumb: establish live state with jcmd and jstat before collecting anything heavier.$body$, $code$jcmd
jcmd 12345 VM.info
jcmd 12345 GC.heap_info
jstat -gcutil 12345 1000 5
# Samples five times at one-second intervals.$code$),
    ('jvm-diagnostics-toolbox', 2, 'Thread dumps and heap dumps', $body$jstack captures every thread state and stack, which is what you need when a service is slow, stuck, or unresponsive, and repeating the capture a few times shows whether threads make progress. jmap produces a heap dump, a binary snapshot for offline analysis, and it can be expensive: writing the file degrades or pauses a large process. Take thread dumps liberally and heap dumps deliberately, ideally after a collection so the file is smaller and more useful. Both tools work through the same attach mechanism as jcmd. Rule of thumb: stack traces first, heap dump only when memory ownership is the actual question.$body$, $code$jstack -l 12345 > threads.txt
jcmd 12345 Thread.print -l > threads2.txt
jcmd 12345 GC.heap_dump heap.hprof
# Compare repeated thread dumps for progress.
# Write heap dumps to a filesystem with room to spare.$code$),
    ('jvm-diagnostics-toolbox', 3, 'Continuous evidence with JFR', $body$Java Flight Recorder records events from the JVM, the application, and the operating system with overhead low enough for production use. A recording captured at the moment of an incident preserves allocation samples, lock contention, class loading, and exception counts that command-line tools cannot reconstruct afterward. jcmd can start, dump, and stop recordings without a restart, and the resulting binary file can be analyzed with profiling tooling. Treat a short recording as the default attachment to any performance investigation. Rule of thumb: keep a rolling recording profile available so the window before an incident is not lost.$body$, $code$jcmd 12345 JFR.start name=incident settings=profile duration=5m
jcmd 12345 JFR.dump name=incident filename=incident.jfr
jcmd 12345 JFR.stop name=incident
# settings=profile trades a little overhead for more detail.
# The recording survives the incident for offline analysis.$code$),
    ('debugging-java-in-the-ide', 1, 'Breakpoints that stay affordable', $body$Breakpoints stop execution and reveal the stack, locals, and object state at that moment. The skill is placement: a breakpoint in a hot method can halt millions of times and make debugging slower than reading code. Conditional breakpoints filter by an expression so execution stops only for interesting input, and logpoints print a message without stopping at all. A suspend policy that stops only the current thread instead of the whole VM keeps other requests flowing while you inspect. Rule of thumb: start with a logpoint or a condition, and escalate to an unconditional breakpoint only on a narrow path you understand.$body$, $code$for (Order order : orders) {
    // Breakpoint condition: order.total() > 10000
    process(order);
}
// Logpoint text: processing {order.id()} total {order.total()}
// Condition and logpoint expressions run in the paused frame.$code$),
    ('debugging-java-in-the-ide', 2, 'Attaching to a remote JVM', $body$Remote debugging uses the Java Debug Wire Protocol. The target JVM starts with an agent option that names the dt_socket transport, and the IDE connects as a client to the configured host and port. Bind to localhost or a private interface when debugging locally, and never expose a debug port on a public network, because a debugger can execute arbitrary code in the target process. The suspend setting decides whether the JVM waits for a debugger at startup or runs until a breakpoint is hit. Rule of thumb: treat a debug port as privileged access, tunnel it, and close it when the investigation ends.$body$, $code$java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=127.0.0.1:5005 \
     -jar app.jar
# server=y makes the JVM listen; the IDE connects as a client.
# suspend=n starts immediately; suspend=y waits for the debugger.
# Keep this address on loopback or a private interface.$code$),
    ('debugging-java-in-the-ide', 3, 'Debugging inside containers', $body$Containers add two complications: the IDE cannot reach the JVM unless a port is published, and the process may run in a slim image without the tools you expect. Run the JVM with the debug agent listening on a container interface and publish a single port to the host loopback only. If the image lacks a shell or diagnostics, use that debug port for the IDE rather than installing extra tools into production images. Keep the debug configuration in a separate, explicitly non-default profile so it cannot be enabled by accident. Rule of thumb: debug access is temporary infrastructure, reviewed and removed like any other privileged setting.$body$, $code$docker run -p 127.0.0.1:5005:5005 \
  -e JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
  myapp:debug
# address=*:5005 lets the JVM accept connections inside the container.
# JAVA_TOOL_OPTIONS is picked up by the launcher automatically.$code$),
    ('migrating-between-java-lts', 1, 'Plan the target and gates', $body$Upgrading between LTS lines is a project with gates: compile cleanly, pass tests, run in a staging environment, then shift traffic gradually. Each gate needs an owner and an exit criterion, and the first gate is compilation with the new toolchain using the same release flag the build already uses. Include everything that touches the JVM: build agents, base images, monitoring agents, and developer machines. A plan that names only the application underestimates the work. Rule of thumb: treat the toolchain, the build, and the runtime as one unit, because partial upgrades cause the most confusing failures.$body$, $code$# Move the toolchain first, then the source level.
javac --release 21 -d out $(find src/main/java -name "*.java")
./gradlew clean test --no-daemon
java -version
# The build log should state the JDK that produced it.$code$),
    ('migrating-between-java-lts', 2, 'Handle removals and encapsulation', $body$Compatibility is mostly preserved across LTS lines, but removed APIs and tighter encapsulation break code that depended on internal behavior. Strong encapsulation of JDK internals has been the default since Java 17, and the option that relaxed it was removed, so libraries doing deep reflection need explicit opens or a newer version that supports modules. Removed tooling and APIs surface as missing classes at build time or startup. Review the migration guide for the target release before editing application code, and scan the dependency tree for libraries that still use internals. Rule of thumb: read the removal list first, then recompile, instead of discovering removals at run time.$body$, $code$jdeps --jdk-internals --multi-release 21 --class-path "lib/*" app.jar
# Lists classes that reach into JDK internals.
java --add-opens java.base/java.lang=ALL-UNNAMED -jar app.jar
# Prefer a library version that no longer needs internals.
# --add-opens is a temporary bridge, not a destination.$code$),
    ('migrating-between-java-lts', 3, 'Roll out gradually', $body$A migration lands when the new runtime carries production traffic, not when the build turns green. Canary a small share of instances, compare error rates and latency against the previous version, then expand. Keep the old toolchain and image available until the new one has survived a full deployment cycle, because the cheapest rollback is the one you did not delete. Track follow-up work such as enabling new language features separately, since it is a distinct change with its own risk. Rule of thumb: change the runtime first, change the source code later, and keep those two changes in different pull requests.$body$, $code$int feature = Runtime.version().feature();
if (feature < 21) {
    throw new IllegalStateException("runtime too old: " + feature);
}
// Temporary guard while old and new instances overlap.$code$)
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
    'jdk-vs-jre-vs-jvm', 'installing-a-jdk', 'jdk-distributions-compared',
    'java-release-cadence', 'choosing-a-java-version', 'java-home-and-path',
    'jdk-command-line-tools', 'jshell-quick-experiments', 'classpath-vs-modulepath',
    'java-module-system-basics', 'packaging-java-applications', 'jvm-architecture-internals',
    'garbage-collection-basics', 'jvm-diagnostics-toolbox', 'debugging-java-in-the-ide',
    'migrating-between-java-lts'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
