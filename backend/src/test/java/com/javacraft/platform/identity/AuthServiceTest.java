package com.javacraft.platform.identity;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {
    @Mock
    private AuthRepository repository;

    @Mock
    private SessionTokenService sessions;

    @Test
    void registrationNormalizesEmailAndStoresOnlyAPasswordHash() {
        var passwordEncoder = new BCryptPasswordEncoder(4);
        var learner = new Learner(UUID.randomUUID(), "learner@example.com", "Learner");
        when(repository.createLearner(
                        org.mockito.ArgumentMatchers.eq("learner@example.com"),
                        org.mockito.ArgumentMatchers.anyString(),
                        org.mockito.ArgumentMatchers.eq("Learner")))
                .thenAnswer(invocation -> {
                    String hash = invocation.getArgument(1);
                    assertNotEquals("LearnerPassword123", hash);
                    assertTrue(passwordEncoder.matches("LearnerPassword123", hash));
                    return learner;
                });
        when(sessions.issueFor(learner)).thenReturn("opaque-session");

        AuthService service = new AuthService(repository, passwordEncoder, sessions);
        AuthService.Session result = service.register(
                " Learner@Example.com ",
                "LearnerPassword123",
                "  Learner  ");

        assertEquals("learner@example.com", result.learner().email());
        assertEquals("opaque-session", result.token());
        verify(sessions).issueFor(learner);
    }
}
