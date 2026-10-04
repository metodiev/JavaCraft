package com.javacraft.platform.execution;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@org.springframework.context.annotation.Profile("execution-worker")
@ConditionalOnProperty(name = "app.execution.worker-enabled", havingValue = "true")
public class ExecutionWorker {
    private static final Logger logger = LoggerFactory.getLogger(ExecutionWorker.class);
    private static final String WORKER_NAME = "javacraft-gvisor-worker";
    private final ExecutionWorkerRepository repository;
    private final DockerSandbox sandbox;
    private volatile boolean ready;

    public ExecutionWorker(ExecutionWorkerRepository repository, DockerSandbox sandbox) {
        this.repository = repository;
        this.sandbox = sandbox;
    }

    @jakarta.annotation.PostConstruct
    void verifySandbox() {
        sandbox.verifyRuntime();
        repository.recoverInterruptedRuns();
        ready = true;
        logger.info("Execution worker verified Docker runtime runsc and the sandbox image");
        heartbeat();
    }

    @Scheduled(fixedDelayString = "${app.execution.poll-delay-ms:1000}")
    public void poll() {
        if (!ready) {
            return;
        }
        repository.heartbeat(WORKER_NAME);
        repository.claimNext().ifPresent(this::run);
    }

    @Scheduled(fixedDelayString = "${app.execution.cleanup-delay-ms:30000}", initialDelay = 30000)
    public void cleanupStoppedSandboxes() {
        if (ready) {
            sandbox.cleanupStoppedContainers();
        }
    }

    private void run(ExecutionWorkerRepository.ExecutionJob job) {
        long startedAt = System.nanoTime();
        try {
            if (!"payment-race-condition".equals(job.challengeSlug())) {
                throw new IllegalStateException("No sandbox test adapter exists for this challenge");
            }
            String testPlan = repository.publicTestPlan(job.challengeId())
                    .orElseThrow(() -> new IllegalStateException("Public challenge tests are not configured"));
            var result = sandbox.execute(job.source(), testPlan);
            repository.complete(
                    job.id(),
                    result.state(),
                    result.durationMs(),
                    result.passed(),
                    result.total(),
                    result.summary(),
                    result.outputTruncated());
        } catch (RuntimeException ex) {
            logger.error("Execution {} failed in the trusted worker", job.id(), ex);
            repository.complete(
                    job.id(),
                    "INFRASTRUCTURE_ERROR",
                    java.util.concurrent.TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startedAt),
                    null,
                    null,
                    "The isolated execution service could not complete this run.",
                    false);
        }
    }

    private void heartbeat() {
        repository.heartbeat(WORKER_NAME);
    }
}
