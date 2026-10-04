package com.javacraft.platform.execution;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.validation.annotation.Validated;

@RestController
@Validated
@RequestMapping("/api/v1")
public class ExecutionController {
    private final ExecutionService executions;

    public ExecutionController(ExecutionService executions) {
        this.executions = executions;
    }

    @PostMapping("/challenges/{slug}/runs")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ExecutionRepository.ExecutionView submit(
            Authentication authentication,
            @PathVariable @Pattern(regexp = "[a-z0-9-]{1,120}") String slug,
            @Valid @RequestBody RunRequest request,
            @RequestHeader("Idempotency-Key") @Pattern(regexp = "[a-zA-Z0-9-]{16,128}") String idempotencyKey) {
        return executions.submit(
                UUID.fromString(authentication.getName()), slug, request.source(), idempotencyKey);
    }

    @GetMapping("/executions/{executionId}")
    public ExecutionRepository.ExecutionView get(
            Authentication authentication, @PathVariable UUID executionId) {
        return executions.get(executionId, UUID.fromString(authentication.getName()));
    }

    public record RunRequest(@NotBlank @Size(max = 32_768) String source) {}
}
