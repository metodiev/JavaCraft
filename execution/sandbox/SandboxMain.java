import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import javax.tools.ToolProvider;

public final class SandboxMain {
    private static final Path WORKSPACE = Path.of("/workspace");

    private SandboxMain() {}

    public static void main(String[] args) throws Exception {
        String source = decodeRequired("JAVACRAFT_SOURCE_B64");
        String tests = decodeRequired("JAVACRAFT_PUBLIC_TESTS_B64");
        String fileName = System.getenv().getOrDefault("JAVACRAFT_SOURCE_FILE", "PaymentService.java");
        if (!fileName.matches("[A-Za-z][A-Za-z0-9]*\\.java")) {
            throw new IllegalArgumentException("Invalid source file name");
        }
        if (tests.contains("class PublicTests")) {
            runHarness(fileName, source, tests);
            return;
        }
        Path sourceFile = WORKSPACE.resolve(fileName);
        Path classes = WORKSPACE.resolve("classes");
        Files.createDirectories(classes);
        Files.writeString(sourceFile, source, StandardCharsets.UTF_8);

        var compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Java compiler is unavailable");
        }
        int compileResult = compiler.run(
                null,
                System.out,
                System.err,
                "-proc:none",
                "-d",
                classes.toString(),
                sourceFile.toString());
        if (compileResult != 0) {
            System.out.println("JAVACRAFT_RESULT 0 0");
            System.exit(1);
        }

        List<TestCase> cases = parseTests(tests);
        int passed = 0;
        for (TestCase test : cases) {
            if (runTest(test, classes)) {
                passed++;
            }
        }
        System.out.println("JAVACRAFT_RESULT " + passed + " " + cases.size());
        if (passed != cases.size()) {
            System.exit(1);
        }
    }

    private static void runHarness(String fileName, String source, String tests) throws Exception {
        Path classes = WORKSPACE.resolve("classes");
        Files.createDirectories(classes);
        Path sourceFile = WORKSPACE.resolve(fileName);
        Path testFile = WORKSPACE.resolve("PublicTests.java");
        Files.writeString(sourceFile, source, StandardCharsets.UTF_8);
        Files.writeString(testFile, tests, StandardCharsets.UTF_8);
        var compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Java compiler is unavailable");
        }
        int compileResult = compiler.run(null, System.out, System.err, "-proc:none", "-d", classes.toString(),
                sourceFile.toString(), testFile.toString());
        if (compileResult != 0) {
            System.out.println("JAVACRAFT_RESULT 0 0");
            System.out.flush();
            Runtime.getRuntime().halt(1);
        }
        var loader = new java.net.URLClassLoader(new java.net.URL[] {classes.toUri().toURL()},
                ClassLoader.getPlatformClassLoader());
        @SuppressWarnings("unchecked")
        var cases = (java.util.Map<String, java.util.concurrent.Callable<Boolean>>) loader.loadClass("PublicTests")
                .getMethod("tests").invoke(null);
        long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(8);
        int passed = 0;
        for (var entry : cases.entrySet()) {
            long remaining = deadline - System.nanoTime();
            if (runCase(entry.getValue(), Math.min(remaining, TimeUnit.SECONDS.toNanos(2)))) {
                passed++;
            } else {
                System.out.println("FAIL " + entry.getKey());
            }
        }
        System.out.println("JAVACRAFT_RESULT " + passed + " " + cases.size());
        System.out.flush();
        Runtime.getRuntime().halt(passed == cases.size() ? 0 : 1);
    }

    private static boolean runCase(java.util.concurrent.Callable<Boolean> test, long timeoutNanos) {
        if (timeoutNanos <= 0) {
            return false;
        }
        var outcome = new java.util.concurrent.atomic.AtomicReference<Boolean>(false);
        Thread thread = new Thread(() -> {
            try {
                outcome.set(Boolean.TRUE.equals(test.call()));
            } catch (Throwable ex) {
                outcome.set(false);
            }
        }, "javacraft-test");
        thread.setDaemon(true);
        thread.start();
        try {
            thread.join(TimeUnit.NANOSECONDS.toMillis(timeoutNanos));
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            return false;
        }
        return !thread.isAlive() && outcome.get();
    }

    private static boolean runTest(TestCase test, Path classes) throws Exception {
        var loader = new java.net.URLClassLoader(
                new java.net.URL[] {classes.toUri().toURL()},
                ClassLoader.getPlatformClassLoader());
        try {
            Class<?> serviceType = loader.loadClass("PaymentService");
            var constructor = serviceType.getDeclaredConstructor();
            constructor.setAccessible(true);
            var method = serviceType.getDeclaredMethod("processPayment");
            method.setAccessible(true);
            Object service = constructor.newInstance();
            if (test.concurrentCalls() == 1) {
                int successes = 0;
                for (int i = 0; i < test.callCount(); i++) {
                    if (Boolean.TRUE.equals(method.invoke(service))) {
                        successes++;
                    }
                }
                return successes == test.expectedSuccesses();
            }
            return runConcurrent(service, method, test);
        } catch (ReflectiveOperationException ex) {
            return false;
        } finally {
            loader.close();
        }
    }

    private static boolean runConcurrent(Object service, java.lang.reflect.Method method, TestCase test)
            throws Exception {
        int workerCount = Math.min(test.callCount(), 16);
        var executor = Executors.newFixedThreadPool(workerCount);
        var ready = new CountDownLatch(workerCount);
        var start = new CountDownLatch(1);
        var successes = new AtomicInteger();
        List<java.util.concurrent.Future<?>> calls = new ArrayList<>();
        try {
            for (int index = 0; index < test.callCount(); index++) {
                calls.add(executor.submit(() -> {
                    ready.countDown();
                    if (!start.await(2, TimeUnit.SECONDS)) {
                        throw new IllegalStateException("Concurrent test did not start");
                    }
                    if (Boolean.TRUE.equals(method.invoke(service))) {
                        successes.incrementAndGet();
                    }
                    return null;
                }));
            }
            if (!ready.await(2, TimeUnit.SECONDS)) {
                return false;
            }
            start.countDown();
            for (var call : calls) {
                try {
                    call.get(2, TimeUnit.SECONDS);
                } catch (java.util.concurrent.ExecutionException ex) {
                    return false;
                }
            }
            return successes.get() == test.expectedSuccesses();
        } finally {
            executor.shutdownNow();
        }
    }

    private static List<TestCase> parseTests(String plan) {
        List<TestCase> cases = new ArrayList<>();
        for (String line : plan.split("\\R")) {
            if (line.isBlank()) {
                continue;
            }
            String[] parts = line.split("\\|", -1);
            if (parts.length != 3) {
                throw new IllegalArgumentException("Malformed public test plan");
            }
            int count = Integer.parseInt(parts[1]);
            int successes = Integer.parseInt(parts[2]);
            if (!List.of("single", "concurrent").contains(parts[0])
                    || count < 1
                    || count > 64
                    || successes < 0
                    || successes > count) {
                throw new IllegalArgumentException("Invalid public test plan");
            }
            cases.add(new TestCase(count, successes, parts[0].equals("concurrent") ? count : 1));
        }
        if (cases.isEmpty()) {
            throw new IllegalArgumentException("No public tests configured");
        }
        return List.copyOf(cases);
    }

    private static String decodeRequired(String name) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Missing required sandbox input");
        }
        return new String(Base64.getDecoder().decode(value), StandardCharsets.UTF_8);
    }

    private record TestCase(int callCount, int expectedSuccesses, int concurrentCalls) {}
}
