package com.javacraft.platform.execution;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class ExecutionServiceTest {
    @Mock
    private ExecutionRepository repository;

    @Test
    void queuesAValidatedRunWhenAnIsolatedWorkerIsAvailable() {
        UUID learnerId = UUID.randomUUID();
        UUID executionId = UUID.randomUUID();
        var expected = new ExecutionRepository.ExecutionView(
                executionId, "QUEUED", null, null, null, null, false);
        when(repository.isRunnable("payment-race-condition")).thenReturn(true);
        when(repository.findExistingExecution(learnerId, "0123456789abcdef")).thenReturn(Optional.empty());
        when(repository.hasAvailableWorker()).thenReturn(true);
        when(repository.withinSubmissionLimits(learnerId)).thenReturn(true);
        when(repository.create(learnerId, "payment-race-condition", "class PaymentService {}", "0123456789abcdef"))
                .thenReturn(executionId);
        when(repository.findById(executionId, learnerId)).thenReturn(Optional.of(expected));

        var result = new ExecutionService(repository).submit(
                learnerId, "payment-race-condition", "class PaymentService {}", "0123456789abcdef");

        assertEquals("QUEUED", result.state());
        verify(repository).create(
                learnerId, "payment-race-condition", "class PaymentService {}", "0123456789abcdef");
    }

    @Test
    void refusesRunsWhenTheIsolatedWorkerIsUnavailable() {
        UUID learnerId = UUID.randomUUID();
        when(repository.isRunnable("payment-race-condition")).thenReturn(true);
        when(repository.findExistingExecution(learnerId, "0123456789abcdef")).thenReturn(Optional.empty());
        when(repository.hasAvailableWorker()).thenReturn(false);

        var failure = assertThrows(
                ResponseStatusException.class,
                () -> new ExecutionService(repository).submit(
                        learnerId, "payment-race-condition", "class PaymentService {}", "0123456789abcdef"));

        assertEquals(503, failure.getStatusCode().value());
        verify(repository, never()).create(
                learnerId, "payment-race-condition", "class PaymentService {}", "0123456789abcdef");
    }

    @Test
    void refusesExecutionForChallengesWithoutPublicTests() {
        var failure = assertThrows(
                ResponseStatusException.class,
                () -> new ExecutionService(repository).submit(
                        UUID.randomUUID(), "junior-word-frequency", "class Main {}", "0123456789abcdef"));

        assertEquals(501, failure.getStatusCode().value());
        verify(repository, never()).hasAvailableWorker();
    }

    @Test
    void rejectsSourceAboveTheSubmissionLimit() {
        UUID learnerId = UUID.randomUUID();
        String source = "x".repeat(32_769);
        when(repository.isRunnable("payment-race-condition")).thenReturn(true);

        var failure = assertThrows(
                ResponseStatusException.class,
                () -> new ExecutionService(repository).submit(
                        learnerId, "payment-race-condition", source, "0123456789abcdef"));

        assertEquals(413, failure.getStatusCode().value());
        verify(repository, never()).hasAvailableWorker();
    }
}
