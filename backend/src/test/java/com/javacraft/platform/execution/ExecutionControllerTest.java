package com.javacraft.platform.execution;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.javacraft.platform.config.SecurityConfig;
import com.javacraft.platform.identity.SessionTokenService;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(ExecutionController.class)
@Import(SecurityConfig.class)
class ExecutionControllerTest {
    private static final UUID LEARNER_ID = UUID.fromString("b1df802c-e087-490d-865f-299f14af7d23");
    private static final UUID EXECUTION_ID = UUID.fromString("a4df802c-e087-490d-865f-299f14af7d23");

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ExecutionService executions;

    @MockBean
    private SessionTokenService sessionTokenService;

    @Test
    void authenticatedLearnerCanQueueChallengeRun() throws Exception {
        when(executions.submit(
                        LEARNER_ID,
                        "payment-race-condition",
                        "public class PaymentService {}",
                        "0123456789abcdef"))
                .thenReturn(new ExecutionRepository.ExecutionView(
                        EXECUTION_ID, "QUEUED", null, null, null, null, false));

        mockMvc.perform(post("/api/v1/challenges/payment-race-condition/runs")
                        .with(SecurityMockMvcRequestPostProcessors.user(LEARNER_ID.toString()))
                        .with(SecurityMockMvcRequestPostProcessors.csrf())
                        .header("Idempotency-Key", "0123456789abcdef")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"source\":\"public class PaymentService {}\"}"))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.id").value(EXECUTION_ID.toString()))
                .andExpect(jsonPath("$.state").value("QUEUED"));
    }

    @Test
    void challengeRunRequiresAuthentication() throws Exception {
        mockMvc.perform(post("/api/v1/challenges/payment-race-condition/runs")
                        .with(SecurityMockMvcRequestPostProcessors.csrf())
                        .header("Idempotency-Key", "0123456789abcdef")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"source\":\"public class PaymentService {}\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void executionStatusRequiresOwnership() throws Exception {
        when(executions.get(EXECUTION_ID, LEARNER_ID))
                .thenThrow(new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "Execution not found"));

        mockMvc.perform(get("/api/v1/executions/" + EXECUTION_ID)
                        .with(SecurityMockMvcRequestPostProcessors.user(LEARNER_ID.toString())))
                .andExpect(status().isNotFound());
    }
}
