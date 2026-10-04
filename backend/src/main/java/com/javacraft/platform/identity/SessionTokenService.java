package com.javacraft.platform.identity;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class SessionTokenService {
    private static final int TOKEN_BYTES = 32;
    private final SecureRandom secureRandom = new SecureRandom();
    private final AuthRepository repository;

    public SessionTokenService(AuthRepository repository) {
        this.repository = repository;
    }

    public String issueFor(Learner learner) {
        byte[] randomBytes = new byte[TOKEN_BYTES];
        secureRandom.nextBytes(randomBytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        repository.createSession(learner.id(), hash(token));
        return token;
    }

    public Optional<Learner> findLearner(String token) {
        if (token == null || token.isBlank()) {
            return Optional.empty();
        }
        return repository.findLearnerBySessionTokenHash(hash(token));
    }

    public void revoke(String token) {
        if (token != null && !token.isBlank()) {
            repository.revokeSession(hash(token));
        }
    }

    private byte[] hash(String token) {
        try {
            return MessageDigest.getInstance("SHA-256")
                    .digest(token.getBytes(StandardCharsets.US_ASCII));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is required by the Java runtime", ex);
        }
    }
}
