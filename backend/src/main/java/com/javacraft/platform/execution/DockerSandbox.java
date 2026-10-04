package com.javacraft.platform.execution;

import com.github.dockerjava.api.DockerClient;
import com.github.dockerjava.api.async.ResultCallback;
import com.github.dockerjava.api.command.WaitContainerResultCallback;
import com.github.dockerjava.api.model.Capability;
import com.github.dockerjava.api.model.Frame;
import com.github.dockerjava.api.model.LogConfig;
import com.github.dockerjava.api.model.WaitResponse;
import com.github.dockerjava.core.DefaultDockerClientConfig;
import com.github.dockerjava.core.DockerClientBuilder;
import com.github.dockerjava.httpclient5.ApacheDockerHttpClient;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("execution-worker")
public class DockerSandbox implements AutoCloseable {
    private static final int MAX_LOG_BYTES = 16 * 1024;
    private static final Pattern RESULT = Pattern.compile("JAVACRAFT_RESULT (\\d+) (\\d+)");
    private final DockerClient docker;
    private final String sandboxImage;
    private String immutableImageId;

    public DockerSandbox(
            @Value("${app.execution.docker-host:unix:///var/run/docker.sock}") String dockerHost,
            @Value("${app.execution.sandbox-image:javacraft-sandbox:0.1.0}") String sandboxImage) {
        var config = DefaultDockerClientConfig.createDefaultConfigBuilder()
                .withDockerHost(dockerHost)
                .build();
        var httpClient = new ApacheDockerHttpClient.Builder()
                .dockerHost(config.getDockerHost())
                .connectionTimeout(Duration.ofSeconds(5))
                .responseTimeout(Duration.ofSeconds(15))
                .maxConnections(8)
                .build();
        this.docker = DockerClientBuilder.getInstance(config)
                .withDockerHttpClient(httpClient)
                .build();
        this.sandboxImage = sandboxImage;
    }

    public void verifyRuntime() {
        var runtimes = docker.infoCmd().exec().getRuntimes();
        if (runtimes == null || !runtimes.containsKey("runsc")) {
            throw new IllegalStateException("Docker runtime 'runsc' is required; refusing to use another runtime");
        }
        immutableImageId = docker.inspectImageCmd(sandboxImage).exec().getId();
        if (immutableImageId == null || immutableImageId.isBlank()) {
            throw new IllegalStateException("The pinned Java sandbox image is unavailable");
        }
        verifyContainerIsolation();
        cleanupStoppedContainers();
    }

    private void verifyContainerIsolation() {
        String containerId = null;
        try {
            var created = docker.createContainerCmd(immutableImageId)
                    .withCmd(
                            "java",
                            "-XX:ActiveProcessorCount=2",
                            "-XX:+UseSerialGC",
                            "-cp",
                            "/opt/sandbox/classes",
                            "SandboxProbe")
                    .withUser("10001:10001")
                    .withHostConfig(hostConfig())
                    .withAttachStdout(true)
                    .withAttachStderr(true)
                    .withTty(false)
                    .withLabels(Map.of("com.javacraft.execution", "true", "com.javacraft.probe", "true"))
                    .exec();
            containerId = created.getId();
            var host = docker.inspectContainerCmd(containerId).exec().getHostConfig();
            if (!"runsc".equals(host.getRuntime())
                    || !"none".equals(host.getNetworkMode())
                    || !Boolean.TRUE.equals(host.getReadonlyRootfs())
                    || !Long.valueOf(256L * 1024 * 1024).equals(host.getMemory())
                    || !Long.valueOf(64).equals(host.getPidsLimit())) {
                throw new IllegalStateException("Docker did not apply the required gVisor sandbox limits");
            }
            docker.startContainerCmd(containerId).exec();
            AtomicLong exitCode = new AtomicLong(-1);
            var wait = docker.waitContainerCmd(containerId)
                    .exec(new WaitContainerResultCallback() {
                        @Override
                        public void onNext(WaitResponse response) {
                            exitCode.set(response.getStatusCode());
                            super.onNext(response);
                        }
                    });
            if (!wait.awaitCompletion(10, TimeUnit.SECONDS) || exitCode.get() != 0) {
                throw new IllegalStateException("gVisor isolation probe did not complete successfully");
            }
            String output = readLogs(containerId).text();
            if (!output.contains("SANDBOX_PROBE_OK")) {
                throw new IllegalStateException("gVisor filesystem or network isolation probe failed");
            }
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("gVisor isolation probe was interrupted", ex);
        } finally {
            if (containerId != null) {
                docker.removeContainerCmd(containerId).withForce(true).withRemoveVolumes(true).exec();
            }
        }
    }

    public void cleanupStoppedContainers() {
        docker.listContainersCmd()
                .withShowAll(true)
                .withLabelFilter(Map.of("com.javacraft.execution", "true"))
                .exec()
                .stream()
                .filter(container -> container.getState().equalsIgnoreCase("exited"))
                .forEach(container -> docker.removeContainerCmd(container.getId()).withForce(true).exec());
    }

    public RunResult execute(String source, String publicTests) {
        if (immutableImageId == null) {
            throw new IllegalStateException("Sandbox runtime has not passed its startup check");
        }
        String containerId = null;
        long start = System.nanoTime();
        try {
            var created = docker.createContainerCmd(immutableImageId)
                    .withEnv(
                            "JAVACRAFT_SOURCE_B64=" + ExecutionWorkerRepository.encode(source),
                            "JAVACRAFT_PUBLIC_TESTS_B64=" + ExecutionWorkerRepository.encode(publicTests))
                    .withUser("10001:10001")
                    .withHostConfig(hostConfig())
                    .withAttachStdout(true)
                    .withAttachStderr(true)
                    .withTty(false)
                    .withLabels(Map.of("com.javacraft.execution", "true"))
                    .exec();
            containerId = created.getId();
            docker.startContainerCmd(containerId).exec();

            AtomicLong exitCode = new AtomicLong(-1);
            var wait = docker.waitContainerCmd(containerId)
                    .exec(new WaitContainerResultCallback() {
                        @Override
                        public void onNext(WaitResponse response) {
                            exitCode.set(response.getStatusCode());
                            super.onNext(response);
                        }
                    });
            boolean finished = wait.awaitCompletion(12, TimeUnit.SECONDS);
            if (!finished) {
                docker.killContainerCmd(containerId).exec();
                return RunResult.timeout(elapsed(start));
            }

            BoundedLog log = readLogs(containerId);
            String output = log.text();
            Matcher result = RESULT.matcher(output);
            int passed = 0;
            int total = 0;
            while (result.find()) {
                passed = Integer.parseInt(result.group(1));
                total = Integer.parseInt(result.group(2));
            }
            if (total == 0) {
                String summary = output.contains("error")
                        ? "Compilation failed:\n" + safeOutput(output)
                        : "The public test runner did not produce a result.";
                return new RunResult(
                        exitCode.get() == 137 ? "RESOURCE_LIMITED" : "FAILED",
                        elapsed(start),
                        null,
                        null,
                        summary,
                        log.truncated());
            }
            boolean allPassed = exitCode.get() == 0 && passed == total;
            String summary = allPassed
                    ? "All public tests passed."
                    : passed + " of " + total + " public tests passed."
                            + (output.isBlank() ? "" : "\n" + safeOutput(output));
            return new RunResult(
                    allPassed ? "PASSED" : (exitCode.get() == 137 ? "RESOURCE_LIMITED" : "FAILED"),
                    elapsed(start),
                    passed,
                    total,
                    summary,
                    log.truncated());
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Sandbox execution was interrupted", ex);
        } finally {
            if (containerId != null) {
                docker.removeContainerCmd(containerId).withForce(true).withRemoveVolumes(true).exec();
            }
        }
    }

    private long elapsed(long start) {
        return TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - start);
    }

    private com.github.dockerjava.api.model.HostConfig hostConfig() {
        return com.github.dockerjava.api.model.HostConfig.newHostConfig()
                .withRuntime("runsc")
                .withNetworkMode("none")
                .withMemory(256L * 1024 * 1024)
                .withMemorySwap(256L * 1024 * 1024)
                .withNanoCPUs(1_000_000_000L)
                .withPidsLimit(64L)
                .withUlimits(List.of(
                        new com.github.dockerjava.api.model.Ulimit("fsize", 16L * 1024 * 1024, 16L * 1024 * 1024),
                        new com.github.dockerjava.api.model.Ulimit("nofile", 128, 128),
                        new com.github.dockerjava.api.model.Ulimit("core", 0, 0)))
                .withReadonlyRootfs(true)
                .withTmpFs(Map.of(
                        "/workspace", "rw,noexec,nosuid,nodev,size=32m,uid=10001,gid=10001",
                        "/tmp", "rw,noexec,nosuid,nodev,size=8m,uid=10001,gid=10001"))
                .withSecurityOpts(List.of("no-new-privileges:true"))
                .withCapDrop(Capability.ALL)
                .withLogConfig(new LogConfig(
                        LogConfig.LoggingType.JSON_FILE,
                        Map.of("max-size", "32k", "max-file", "1")));
    }

    private BoundedLog readLogs(String containerId) throws InterruptedException {
        BoundedLog log = new BoundedLog(MAX_LOG_BYTES);
        docker.logContainerCmd(containerId)
                .withStdOut(true)
                .withStdErr(true)
                .withFollowStream(false)
                .exec(new ResultCallback.Adapter<Frame>() {
                    @Override
                    public void onNext(Frame frame) {
                        log.append(frame.getPayload());
                    }
                })
                .awaitCompletion(5, TimeUnit.SECONDS);
        return log;
    }

    private String safeOutput(String output) {
        String sanitized = output.replaceAll("\\u001B\\[[;\\d]*m", "")
                .replaceAll("[\\p{Cntrl}&&[^\\n\\t]]", "");
        return sanitized.substring(0, Math.min(sanitized.length(), 2_000));
    }

    @Override
    public void close() throws java.io.IOException {
        docker.close();
    }

    public record RunResult(
            String state,
            long durationMs,
            Integer passed,
            Integer total,
            String summary,
            boolean outputTruncated) {
        static RunResult timeout(long durationMs) {
            return new RunResult(
                    "TIMED_OUT", durationMs, null, null, "Execution exceeded the 12-second time limit.", false);
        }
    }

    private static final class BoundedLog {
        private final int limit;
        private final java.io.ByteArrayOutputStream output = new java.io.ByteArrayOutputStream();
        private boolean truncated;

        private BoundedLog(int limit) {
            this.limit = limit;
        }

        private void append(byte[] bytes) {
            int remaining = limit - output.size();
            if (remaining <= 0) {
                truncated = true;
                return;
            }
            int length = Math.min(remaining, bytes.length);
            output.write(bytes, 0, length);
            truncated |= length < bytes.length;
        }

        private String text() {
            return output.toString(StandardCharsets.UTF_8);
        }

        private boolean truncated() {
            return truncated;
        }
    }
}
