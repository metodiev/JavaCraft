CREATE TABLE execution_worker_heartbeat (
    worker_name VARCHAR(120) PRIMARY KEY,
    last_seen_at TIMESTAMPTZ NOT NULL
);

INSERT INTO challenge_test (challenge_id, visibility, source_bundle, sort_order)
SELECT c.id,
       'PUBLIC',
       convert_to(
           E'single|1|1\nsingle|2|1\nconcurrent|32|1\n',
           'UTF8'),
       1
FROM challenge c
WHERE c.slug = 'payment-race-condition'
  AND NOT EXISTS (
      SELECT 1
      FROM challenge_test existing
      WHERE existing.challenge_id = c.id
        AND existing.visibility = 'PUBLIC'
  );
