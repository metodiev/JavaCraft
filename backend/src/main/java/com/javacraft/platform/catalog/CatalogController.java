package com.javacraft.platform.catalog;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1")
public class CatalogController {
    private static final Challenge CHALLENGE = new Challenge(
            "payment-race-condition",
            "Fix the Payment Race Condition",
            "Senior",
            "Concurrency",
            "Two concurrent requests can both pass the existence check and process the same payment. Make the operation atomic without changing the public API.",
            List.of(
                    "A payment must only be processed once.",
                    "Concurrent requests must be safe.",
                    "Preserve existing API behavior and add appropriate tests."),
            """
            import java.util.concurrent.atomic.AtomicBoolean;

            public class PaymentService {
                private final AtomicBoolean processed = new AtomicBoolean(false);

                public boolean processPayment() {
                    // TODO: make processing idempotent under concurrent requests
                    return !processed.get();
                }
            }
            """,
            List.of("Concurrency", "Testing", "Transactions"));

    private static final List<TutorialSummary> TUTORIALS = List.of(
            new TutorialSummary(
                    "collections",
                    "Java Collections",
                    "Choose and use the right data structure, and understand the trade-offs.",
                    24,
                    "in_progress"),
            new TutorialSummary(
                    "exception-design",
                    "Designing Exceptions",
                    "Model failure clearly without hiding useful diagnostic context.",
                    18,
                    "available"),
            new TutorialSummary(
                    "testing-boundaries",
                    "Testing System Boundaries",
                    "Write focused unit and integration tests for production services.",
                    32,
                    "locked"));

    @GetMapping("/catalog")
    public CatalogResponse catalog() {
        return new CatalogResponse(
                "Junior Java Developer",
                "Mid-Level Java Developer",
                68,
                List.of(
                        new SkillProgress("Java Fundamentals", 82),
                        new SkillProgress("Object-oriented design", 64),
                        new SkillProgress("Collections", 58),
                        new SkillProgress("Concurrency", 22)),
                TUTORIALS,
                CHALLENGE);
    }

    @GetMapping("/tutorials")
    public List<TutorialSummary> tutorials() {
        return TUTORIALS;
    }

    @GetMapping("/tutorials/{slug}")
    public Tutorial tutorial(@PathVariable String slug) {
        TutorialSummary summary = TUTORIALS.stream()
                .filter(item -> item.slug().equals(slug))
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        List<TutorialSection> sections = switch (slug) {
            case "collections" -> List.of(new TutorialSection(
                    "HashMap internals",
                    "HashMap stores key-value entries in buckets. A key's hash selects a bucket; equality resolves collisions. Average lookup is constant time when hashes are well distributed, but mutable keys and poor hash functions break those assumptions.",
                    """
                    Map<String, Integer> scores = new HashMap<>();
                    scores.put("Alice", 100);
                    scores.put("Bob", 80);
                    """));
            case "exception-design" -> List.of(new TutorialSection(
                    "Make failure explicit",
                    "Use exception types to distinguish invalid input from operational failures. Preserve the cause when translating an exception at a boundary, and handle only failures the caller can meaningfully recover from.",
                    """
                    try {
                        paymentService.capture(payment);
                    } catch (PaymentGatewayException ex) {
                        throw new CheckoutException("Payment could not be completed", ex);
                    }
                    """));
            case "testing-boundaries" -> List.of(new TutorialSection(
                    "Test the contract at the boundary",
                    "Unit tests are fast for domain rules, while integration tests verify serialization, persistence, and framework wiring. Prefer assertions on externally observable behavior over implementation details.",
                    """
                    @Test
                    void rejectsAnUnknownPayment() {
                        assertThrows(PaymentNotFoundException.class,
                            () -> service.capture("missing-id"));
                    }
                    """));
            default -> throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        };
        return new Tutorial(
                summary.slug(),
                summary.title(),
                summary.description(),
                summary.durationMinutes(),
                summary.status(),
                sections);
    }

    @GetMapping("/challenges/{slug}")
    public Challenge challenge(@PathVariable String slug) {
        if (!CHALLENGE.slug().equals(slug)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        return CHALLENGE;
    }

    public record CatalogResponse(
            String currentLevel,
            String nextLevel,
            int progressPercent,
            List<SkillProgress> skills,
            List<TutorialSummary> tutorials,
            Challenge challenge) {}

    public record SkillProgress(String name, int percent) {}

    public record TutorialSummary(
            String slug,
            String title,
            String description,
            int durationMinutes,
            String status) {}

    public record Tutorial(
            String slug,
            String title,
            String description,
            int durationMinutes,
            String status,
            List<TutorialSection> sections) {}

    public record TutorialSection(String title, String body, String exampleCode) {}

    public record Challenge(
            String slug,
            String title,
            String level,
            String category,
            String description,
            List<String> requirements,
            String starterCode,
            List<String> skills) {}
}
