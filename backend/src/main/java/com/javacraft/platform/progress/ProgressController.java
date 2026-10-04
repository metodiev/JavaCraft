package com.javacraft.platform.progress;

import com.javacraft.platform.progress.ProgressRepository.ProgressStatus;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me")
public class ProgressController {
    private final ProgressService progress;

    public ProgressController(ProgressService progress) {
        this.progress = progress;
    }

    @GetMapping("/progress")
    public ProgressService.LearnerProgress progress(Authentication authentication) {
        return progress.getProgress(UUID.fromString(authentication.getName()));
    }

    @PutMapping("/tutorials/{slug}/progress")
    public ProgressService.LearnerProgress updateTutorial(
            Authentication authentication,
            @PathVariable String slug,
            @Valid @RequestBody UpdateTutorialProgress request) {
        return progress.updateTutorial(
                UUID.fromString(authentication.getName()),
                slug,
                request.status());
    }

    public record UpdateTutorialProgress(@NotNull ProgressStatus status) {}
}
