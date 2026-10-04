package com.javacraft.platform.progress;

import com.javacraft.platform.progress.ProgressRepository.ProgressStatus;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ProgressService {
    private final ProgressRepository repository;

    public ProgressService(ProgressRepository repository) {
        this.repository = repository;
    }

    public LearnerProgress getProgress(UUID userId) {
        ProgressRepository.PathProgress path = repository.findPathProgress(userId);
        return new LearnerProgress(
                path.title(),
                path.completedCount(),
                path.totalCount(),
                path.percent(),
                repository.findTutorialProgress(userId),
                repository.findSkillProgress(userId));
    }

    @Transactional
    public LearnerProgress updateTutorial(UUID userId, String slug, ProgressStatus status) {
        if (status == ProgressStatus.NOT_STARTED) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Progress can be set to IN_PROGRESS or COMPLETED");
        }
        if (!repository.updateTutorialProgress(userId, slug, status)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tutorial not found in this learning path");
        }
        return getProgress(userId);
    }

    public record LearnerProgress(
            String currentTrack,
            int completedTutorials,
            int totalTutorials,
            int progressPercent,
            List<ProgressRepository.TutorialProgress> tutorials,
            List<ProgressRepository.SkillProgress> skills) {}
}
