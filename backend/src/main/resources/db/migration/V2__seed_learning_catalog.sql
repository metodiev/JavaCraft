INSERT INTO app_role (name) VALUES ('ROLE_USER');

INSERT INTO learning_path (slug, title, description, sort_order, published)
VALUES (
    'junior-java-developer',
    'Junior Java Developer',
    'Build Java fundamentals and learn to write code other engineers can trust.',
    1,
    true
);

INSERT INTO skill (slug, name, description) VALUES
    ('java-fundamentals', 'Java Fundamentals', 'Language syntax, types, and runtime basics.'),
    ('object-oriented-design', 'Object-oriented design', 'Encapsulation, composition, and maintainable object models.'),
    ('collections', 'Collections', 'Select and use Java collections with a clear understanding of their trade-offs.'),
    ('exceptions', 'Exception design', 'Represent and handle failure without losing diagnostic context.'),
    ('testing', 'Testing', 'Verify behavior at unit and system boundaries.'),
    ('concurrency', 'Concurrency', 'Build correct behavior when operations overlap.');

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('collections', 'Java Collections', 'Choose and use the right data structure, and understand the trade-offs.', 'Junior', 24, true, 1),
    ('exception-design', 'Designing Exceptions', 'Model failure clearly without hiding useful diagnostic context.', 'Junior', 18, true, 1),
    ('testing-boundaries', 'Testing System Boundaries', 'Write focused unit and integration tests for production services.', 'Junior', 32, true, 1);

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT id, 'HashMap internals',
       'HashMap stores key-value entries in buckets. A key''s hash selects a bucket; equality resolves collisions. Average lookup is constant time when hashes are well distributed, but mutable keys and poor hash functions break those assumptions.',
       E'Map<String, Integer> scores = new HashMap<>();\nscores.put("Alice", 100);\nscores.put("Bob", 80);\n',
       1
FROM tutorial WHERE slug = 'collections';

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT id, 'Make failure explicit',
       'Use exception types to distinguish invalid input from operational failures. Preserve the cause when translating an exception at a boundary, and handle only failures the caller can meaningfully recover from.',
       E'try {\n    paymentService.capture(payment);\n} catch (PaymentGatewayException ex) {\n    throw new CheckoutException("Payment could not be completed", ex);\n}\n',
       1
FROM tutorial WHERE slug = 'exception-design';

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT id, 'Test the contract at the boundary',
       'Unit tests are fast for domain rules, while integration tests verify serialization, persistence, and framework wiring. Prefer assertions on externally observable behavior over implementation details.',
       E'@Test\nvoid rejectsAnUnknownPayment() {\n    assertThrows(PaymentNotFoundException.class,\n        () -> service.capture("missing-id"));\n}\n',
       1
FROM tutorial WHERE slug = 'testing-boundaries';

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id, tutorial.id, t.sort_order
FROM learning_path lp
CROSS JOIN (
    VALUES ('collections', 1), ('exception-design', 2), ('testing-boundaries', 3)
) AS t(slug, sort_order)
JOIN tutorial ON tutorial.slug = t.slug
WHERE lp.slug = 'junior-java-developer';

INSERT INTO challenge (
    slug, title, description, level, difficulty, category, starter_repository, published
)
VALUES (
    'payment-race-condition',
    'Fix the Payment Race Condition',
    'Two concurrent requests can both pass the existence check and process the same payment. Make the operation atomic without changing the public API.',
    'Senior',
    'Senior',
    'Concurrency',
    jsonb_build_object(
        'PaymentService.java',
        E'import java.util.concurrent.atomic.AtomicBoolean;\n\npublic class PaymentService {\n    private final AtomicBoolean processed = new AtomicBoolean(false);\n\n    public boolean processPayment() {\n        // TODO: make processing idempotent under concurrent requests\n        return !processed.get();\n    }\n}\n'
    ),
    true
);

INSERT INTO challenge_skill (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenge c
CROSS JOIN (VALUES ('concurrency'), ('testing')) AS wanted(slug)
JOIN skill s ON s.slug = wanted.slug
WHERE c.slug = 'payment-race-condition';

CREATE TABLE challenge_requirement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenge(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    sort_order INTEGER NOT NULL,
    UNIQUE (challenge_id, sort_order)
);

INSERT INTO challenge_requirement (challenge_id, description, sort_order)
SELECT c.id, requirement.description, requirement.sort_order
FROM challenge c
CROSS JOIN (
    VALUES
        ('A payment must only be processed once.', 1),
        ('Concurrent requests must be safe.', 2),
        ('Preserve existing API behavior and add appropriate tests.', 3)
) AS requirement(description, sort_order)
WHERE c.slug = 'payment-race-condition';
