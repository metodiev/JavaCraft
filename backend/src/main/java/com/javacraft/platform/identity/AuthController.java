package com.javacraft.platform.identity;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.security.core.Authentication;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    private final AuthService authService;
    private final SessionTokenService sessions;
    private final AuthRepository repository;
    private final boolean secureCookie;

    public AuthController(
            AuthService authService,
            SessionTokenService sessions,
            AuthRepository repository,
            @Value("${app.cookie.secure:false}") boolean secureCookie) {
        this.authService = authService;
        this.sessions = sessions;
        this.repository = repository;
        this.secureCookie = secureCookie;
    }

    @GetMapping("/csrf")
    public CsrfResponse csrf(CsrfToken token) {
        return new CsrfResponse(token.getToken());
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public LearnerResponse register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletResponse response) {
        AuthService.Session session = authService.register(
                request.email(), request.password(), request.displayName());
        setSessionCookie(response, session.token());
        return LearnerResponse.from(session.learner());
    }

    @PostMapping("/login")
    public LearnerResponse login(
            @Valid @RequestBody LoginRequest request,
            HttpServletResponse response) {
        AuthService.Session session = authService.login(request.email(), request.password());
        setSessionCookie(response, session.token());
        return LearnerResponse.from(session.learner());
    }

    @GetMapping("/me")
    public LearnerResponse me(Authentication authentication) {
        Learner learner = repository.findLearnerById(java.util.UUID.fromString(authentication.getName()))
                .orElseThrow(() -> new IllegalStateException("Authenticated learner no longer exists"));
        return LearnerResponse.from(learner);
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(HttpServletRequest request, HttpServletResponse response) {
        sessions.revoke(sessionCookie(request));
        ResponseCookie cookie = ResponseCookie.from(SessionAuthenticationFilter.COOKIE_NAME, "")
                .httpOnly(true)
                .secure(secureCookie)
                .sameSite("Lax")
                .path("/")
                .maxAge(0)
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    private void setSessionCookie(HttpServletResponse response, String token) {
        ResponseCookie cookie = ResponseCookie.from(SessionAuthenticationFilter.COOKIE_NAME, token)
                .httpOnly(true)
                .secure(secureCookie)
                .sameSite("Lax")
                .path("/")
                .maxAge(java.time.Duration.ofDays(30))
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    private String sessionCookie(HttpServletRequest request) {
        if (request.getCookies() == null) {
            return null;
        }
        for (var cookie : request.getCookies()) {
            if (SessionAuthenticationFilter.COOKIE_NAME.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    public record CsrfResponse(String token) {}

    public record LearnerResponse(java.util.UUID id, String email, String displayName) {
        static LearnerResponse from(Learner learner) {
            return new LearnerResponse(learner.id(), learner.email(), learner.displayName());
        }
    }

    public record RegisterRequest(
            @NotBlank @Email @Size(max = 254) String email,
            @NotBlank @Size(min = 12, max = 128) String password,
            @NotBlank @Size(max = 80) String displayName) {}

    public record LoginRequest(
            @NotBlank @Email @Size(max = 254) String email,
            @NotBlank @Size(max = 128) String password) {}
}
