package com.javacraft.platform.challenges;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.stream.Stream;
import javax.tools.ToolProvider;
import org.junit.jupiter.api.Test;

/** Every runnable challenge must pass with its reference solution and fail with its starter. */
class ChallengeContentTest {
    private static final Path CONTENT = Path.of("src/main/resources/challenge-content");
    private static final Path SOLUTIONS = Path.of("src/test/resources/challenge-solutions");

    @Test
    void everyChallengeHasAWorkingReferenceSolutionAndAFailingStarter() throws Exception {
        List<Path> challenges;
        try (Stream<Path> dirs = Files.list(CONTENT)) {
            challenges = dirs.filter(Files::isDirectory).sorted().toList();
        }
        assertFalse(challenges.isEmpty());
        for (Path challenge : challenges) {
            String slug = challenge.getFileName().toString();
            Path tests = challenge.resolve("PublicTests.java");
            assertTrue(Files.exists(tests), slug + " is missing PublicTests.java");
            assertFalse(Files.readAllLines(challenge.resolve("requirements.txt")).isEmpty(), slug);

            int[] solution = run(slug, SOLUTIONS.resolve(slug).resolve("Main.java"), tests);
            assertEquals(solution[1], solution[0], slug + " reference solution must pass every public test");
            int[] starter = run(slug, challenge.resolve("Main.java"), tests);
            assertTrue(starter[0] < starter[1], slug + " starter must fail at least one public test");
        }
    }

    private static int[] run(String slug, Path source, Path tests) throws Exception {
        Path out = Files.createTempDirectory("challenge-" + slug);
        var compiler = ToolProvider.getSystemJavaCompiler();
        int status = compiler.run(null, null, null, "-proc:none", "-d", out.toString(),
                source.toString(), tests.toString());
        assertEquals(0, status, slug + " must compile: " + source);
        try (var loader = new URLClassLoader(new URL[] {out.toUri().toURL()}, ClassLoader.getPlatformClassLoader())) {
            @SuppressWarnings("unchecked")
            var cases = (Map<String, Callable<Boolean>>) loader.loadClass("PublicTests").getMethod("tests").invoke(null);
            int passed = 0;
            for (var entry : cases.entrySet()) {
                boolean[] ok = new boolean[1];
                Thread thread = new Thread(() -> {
                    try {
                        ok[0] = Boolean.TRUE.equals(entry.getValue().call());
                    } catch (Throwable ignored) {
                        ok[0] = false;
                    }
                });
                thread.setDaemon(true);
                thread.start();
                thread.join(3000);
                if (!thread.isAlive() && ok[0]) {
                    passed++;
                }
            }
            return new int[] {passed, cases.size()};
        }
    }
}
