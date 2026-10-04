package com.javacraft.platform.identity;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {
    private final AuthRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final SessionTokenService sessions;

    public AuthService(
            AuthRepository repository,
            PasswordEncoder passwordEncoder,
            SessionTokenService sessions) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
        this.sessions = sessions;
    }

    @Transactional
    public Session register(String email, String password, String displayName) {
        String normalizedEmail = normalizeEmail(email);
        Learner learner;
        try {
            learner = repository.createLearner(
                    normalizedEmail,
                    passwordEncoder.encode(password),
                    displayName.trim());
        } catch (DuplicateKeyException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An account with this email already exists");
        }
        return new Session(learner, sessions.issueFor(learner));
    }

    public Session login(String email, String password) {
        String normalizedEmail = normalizeEmail(email);
        AuthRepository.Credentials credentials = repository.findCredentialsByEmail(normalizedEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));
        if (!passwordEncoder.matches(password, credentials.passwordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
        }
        return new Session(credentials.learner(), sessions.issueFor(credentials.learner()));
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(java.util.Locale.ROOT);
    }

    public record Session(Learner learner, String token) {}
}
