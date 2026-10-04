package com.javacraft.platform.execution;

import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ExecutionService {
    private final ExecutionRepository repository;

    public ExecutionService(ExecutionRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public ExecutionRepository.ExecutionView submit(
            UUID learnerId, String slug, String source, String idempotencyKey) {
        if (!repository.isRunnable(slug)) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_IMPLEMENTED, "Java execution is not yet available for this challenge");
        }
        if (source.getBytes(java.nio.charset.StandardCharsets.UTF_8).length > 32_768) {
            throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE, "Challenge source exceeds 32 KiB");
        }
        var existing = repository.findExistingExecution(learnerId, idempotencyKey);
        if (existing.isPresent()) {
            return owned(existing.get(), learnerId);
        }
        if (!repository.hasAvailableWorker()) {
            throw new ResponseStatusException(
                    HttpStatus.SERVICE_UNAVAILABLE, "The isolated execution worker is unavailable");
        }
        if (!repository.withinSubmissionLimits(learnerId)) {
            throw new ResponseStatusException(
                    HttpStatus.TOO_MANY_REQUESTS, "The queue is busy or a submission limit was reached");
        }
        UUID executionId;
        try {
            executionId = repository.create(learnerId, slug, source, idempotencyKey);
        } catch (org.springframework.dao.EmptyResultDataAccessException ex) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Challenge not found");
        }
        return owned(executionId, learnerId);
    }

    public ExecutionRepository.ExecutionView get(UUID executionId, UUID learnerId) {
        return owned(executionId, learnerId);
    }

    private ExecutionRepository.ExecutionView owned(UUID executionId, UUID learnerId) {
        return repository.findById(executionId, learnerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Execution not found"));
    }
}
