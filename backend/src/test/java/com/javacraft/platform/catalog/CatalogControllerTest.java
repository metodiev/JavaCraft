package com.javacraft.platform.catalog;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.mockito.Mockito.when;

import com.javacraft.platform.progress.ProgressController;
import com.javacraft.platform.progress.ProgressRepository;
import com.javacraft.platform.progress.ProgressService;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors;
import org.springframework.test.web.servlet.MockMvc;
import com.javacraft.platform.config.SecurityConfig;
import com.javacraft.platform.identity.SessionTokenService;
import java.util.List;
import java.util.Optional;

@WebMvcTest({CatalogController.class, ProgressController.class})
@Import(SecurityConfig.class)
class CatalogControllerTest {
    private static final UUID LEARNER_ID = UUID.fromString("b1df802c-e087-490d-865f-299f14af7d23");

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CatalogService catalogService;

    @MockBean
    private SessionTokenService sessionTokenService;

    @MockBean
    private ProgressService progressService;

    @Test
    void catalogExposesPublicLearningContentWithoutHiddenTests() throws Exception {
        when(catalogService.getCatalog()).thenReturn(new CatalogService.CatalogResponse(
                List.of(),
                new CatalogService.Challenge(
                        "payment-race-condition",
                        "Fix the Payment Race Condition",
                        "Senior",
                        "Concurrency",
                        "Description",
                        List.of(),
                        "starter",
                        List.of("Concurrency"),
                        true)));

        mockMvc.perform(get("/api/v1/catalog"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.challenge.slug").value("payment-race-condition"))
                .andExpect(jsonPath("$.challenge.hiddenTests").doesNotExist());
    }

    @Test
    void challengeListIncludesPublishedSummaries() throws Exception {
        when(catalogService.listChallenges()).thenReturn(List.of(new CatalogService.ChallengeSummary(
                "junior-temperature-converter",
                "Build a Temperature Converter",
                "Convert temperature values.",
                "Junior",
                "Java Fundamentals")));

        mockMvc.perform(get("/api/v1/challenges"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].level").value("Junior"))
                .andExpect(jsonPath("$[0].category").value("Java Fundamentals"));
    }

    @Test
    void unknownTutorialReturnsNotFound() throws Exception {
        when(catalogService.findTutorial("does-not-exist")).thenReturn(Optional.empty());
        mockMvc.perform(get("/api/v1/tutorials/does-not-exist"))
                .andExpect(status().isNotFound());
    }

    @Test
    void learnerProgressRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/me/progress"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void authenticatedLearnerCanUpdateProgressWithCsrfProtection() throws Exception {
        var expected = new ProgressService.LearnerProgress(
                "Java foundations",
                1,
                3,
                33,
                List.of(new ProgressRepository.TutorialProgress(
                        "collections", ProgressRepository.ProgressStatus.COMPLETED)),
                List.of());
        when(progressService.updateTutorial(
                        LEARNER_ID,
                        "collections",
                        ProgressRepository.ProgressStatus.COMPLETED))
                .thenReturn(expected);

        mockMvc.perform(put("/api/v1/me/tutorials/collections/progress")
                        .with(SecurityMockMvcRequestPostProcessors.user(LEARNER_ID.toString()))
                        .with(SecurityMockMvcRequestPostProcessors.csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"COMPLETED\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tutorials[0].status").value("COMPLETED"));
    }

    @Test
    void progressUpdateRejectsMissingCsrfToken() throws Exception {
        mockMvc.perform(put("/api/v1/me/tutorials/collections/progress")
                        .with(SecurityMockMvcRequestPostProcessors.user(LEARNER_ID.toString()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"COMPLETED\"}"))
                .andExpect(status().isForbidden());
    }
}
