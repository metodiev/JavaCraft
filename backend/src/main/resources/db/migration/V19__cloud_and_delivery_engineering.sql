-- V19 — Cloud and delivery engineering.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('twelve-factor-spring-apps', 'Twelve-Factor Spring Boot Services', 'Map each twelve-factor principle onto a Spring Boot service and see which factors teams break most often.', 'Junior', 24, true, 1),
    ('environment-parity', 'Environment Parity for Spring Services', 'Reduce configuration and behavior drift across local, staging, and production without pretending every difference can be removed.', 'Junior', 26, true, 1),
    ('ci-cd-github-actions-java', 'CI/CD Pipelines with GitHub Actions', 'Build a GitHub Actions pipeline for a Java service with caching, a JDK matrix, artifacts, and protected environments.', 'Mid', 32, true, 1),
    ('ci-cd-quality-gates', 'Quality Gates in Java Pipelines', 'Make pipelines fail fast with tests, coverage thresholds, static analysis, dependency scanning, and branch protection.', 'Mid', 30, true, 1),
    ('blue-green-deployments', 'Blue-Green Deployments', 'Release a new version by switching traffic between two full environments while keeping the database compatible with both.', 'Mid', 30, true, 1),
    ('canary-deployments', 'Canary Deployments and Automated Rollback', 'Shift traffic gradually to a new version and let metric gates trigger automatic rollback when health degrades.', 'Senior', 38, true, 1),
    ('feature-flags-in-practice', 'Feature Flags in Practice', 'Manage feature flags through their whole lifecycle instead of leaving stale toggles in the codebase forever.', 'Mid', 28, true, 1),
    ('infrastructure-as-code-terraform', 'Infrastructure as Code with Terraform', 'Describe cloud infrastructure as versioned Terraform code and keep state, modules, and plan reviews under control.', 'Senior', 38, true, 1),
    ('aws-managed-services-java', 'Running Spring Boot on AWS Managed Services', 'Use managed database, cache, queue, and secret services on AWS from a Spring Boot service with scoped IAM roles.', 'Mid', 34, true, 1),
    ('azure-managed-services-java', 'Running Spring Boot on Azure Managed Services', 'Use the Azure managed primitives for database, cache, queue, and secrets from a Spring Boot service with passwordless identity.', 'Senior', 36, true, 1),
    ('gcp-managed-services-java', 'Running Spring Boot on Google Cloud Managed Services', 'Use the Google Cloud managed primitives for database, cache, queue, and secrets from a Spring Boot service.', 'Senior', 36, true, 1),
    ('secrets-management-in-the-cloud', 'Secrets Management in the Cloud', 'Prefer a secret store over plain environment variables and rotate credentials without coordinating a redeploy of every consumer.', 'Mid', 30, true, 1),
    ('autoscaling-strategies', 'Autoscaling Strategies for Java Services', 'Choose scaling signals that track demand, warm up new instances, and scale in without losing in-flight work.', 'Mid', 34, true, 1),
    ('multi-environment-configuration', 'Multi-Environment Configuration Management', 'Keep profiles and externalized configuration predictable, with per-environment overrides that stay visible and reviewable.', 'Mid', 28, true, 1),
    ('cost-aware-architecture', 'Cost-Aware Architecture', 'Treat cost as a design constraint through right-sizing, storage lifecycle, egress awareness, and idle-environment hygiene.', 'Mid', 32, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('twelve-factor-spring-apps', 1, 'Map factors onto Spring Boot defaults', $body$The twelve factors describe a portable service: one codebase, explicit dependencies, configuration in the environment, backing services as attached resources, build and release kept separate from run, stateless processes, port binding, process-based concurrency, disposability, parity between environments, logs as event streams, and admin tasks as one-off runs. Spring Boot supplies defaults that support nearly all of them: executable jars, externalized configuration, an embedded server, health endpoints, and structured logging. The engineering work is deciding where the defaults are not enough and where the team quietly breaks them. Use the factors as a review checklist for each new service rather than a certification ritual.$body$, $code$# Configuration comes from the environment, not the jar
spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}$code$),
    ('twelve-factor-spring-apps', 2, 'Factors teams break most often', $body$Config, disposability, logs, and dev and prod parity are the factors teams break most. Typical shortcuts: committing environment values into profiles, keeping sessions in memory and enabling sticky routing, writing log files inside containers, and letting staging drift so far from production that a green deploy proves little. Admin processes drift too when outages get fixed with hand-run scripts instead of migrations and scheduled jobs held in version control. Each shortcut looks cheap until autoscaling, failover, or credential rotation exposes it; then the fix costs far more than the shortcut saved. Audit these four factors first in any service review.$body$, $code$# Logs belong on stdout, where the platform collects them
logging:
  file:
    name: ""
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} %-5level %logger{36} %msg%n"$code$),
    ('twelve-factor-spring-apps', 3, 'Keep processes disposable', $body$A disposable process starts quickly, serves traffic, and can be replaced or terminated without losing unique state. In a Spring service that means keeping session data, cached state that must survive, and scheduled-work coordination outside the process, and letting the platform drain in-flight requests before termination. Enable graceful shutdown and size the platform grace period so the two agree; a short platform timeout that kills a slow shutdown is a common production failure. Treat local disk as a cache that can vanish. If restarting a service needs a human checklist, it is not disposable yet.$body$, $code$# Graceful shutdown must match the platform grace period
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s$code$),
    ('environment-parity', 1, 'Make every difference intentional', $body$Parity means every difference between environments is deliberate and documented, not invisible. Production will always differ in capacity, data volume, and credential scope; that is expected. What should not differ is the runtime, container image, dependency versions, configuration keys, and deployment mechanism. Teams lose time when local development quietly diverges: a different JVM, a patched library, or an extra manual step that production automation never performs. Write the allowed differences into a short parity contract and revisit it whenever an incident traces back to environment behavior. Treat unexplained difference as a defect.$body$, $code$# Allowed environment differences, reviewed like code
parity:
  intentional:
    - replica count
    - dataset size
  forbidden:
    - JVM version
    - library versions$code$),
    ('environment-parity', 2, 'Build once, deploy the same artifact', $body$The strongest parity lever is promoting one immutable artifact. CI builds a container image or jar once, tags it with a commit-derived identifier, and every environment from local development to production runs the same bytes. Configuration values are injected at deploy time, never baked per environment. A common pitfall is rebuilding during release: the artifact already tested is not the artifact shipped, so test evidence does not transfer. Another is local development running a hand-built jar while the pipeline runs a leaner image with different flags. Pin runtime base images and dependency versions so promotion stays honest.$body$, $code$# Build the artifact once in CI
docker build -t registry.example.com/orders:$GIT_SHA .
docker push registry.example.com/orders:$GIT_SHA
# Promote by digest; never rebuild for staging
kubectl set image deployment/orders \
  app=registry.example.com/orders@sha256:0123abcd$code$),
    ('environment-parity', 3, 'Respect the limits of data parity', $body$Data is where parity is genuinely impossible. Production holds volume, distribution, history, and sensitive records that no lower environment can copy safely; copying production data also creates privacy and compliance exposure. Some bugs therefore appear only at scale: query plans, lock contention, cache hit rates, memory pressure. Compensate with anonymized datasets whose shape resembles production, load tests against production-like capacity, and observability that compares behavior across environments instead of assuming equivalence. The pitfall is treating a green staging run as proof of production capacity. Standardize behavior, not data.$body$, $code$# Load an anonymized, production-shaped dataset
pg_restore --no-owner -d "$STAGING_DB_URL" fixtures/orders-anonymized.dump
# Refresh statistics so plans resemble production
psql "$STAGING_DB_URL" -c "ANALYZE;"
# Compare plans before trusting staging timings
psql "$STAGING_DB_URL" -c "EXPLAIN ANALYZE SELECT * FROM orders LIMIT 50;"$code$),
    ('ci-cd-github-actions-java', 1, 'Structure the pipeline in stages', $body$A Java pipeline needs stages: compile, unit test, integration test, package, publish artifact, and deploy. On GitHub Actions, separate jobs keep concerns isolated and let slow stages run only when earlier gates pass; matrix builds test supported JDK versions in parallel. Cache the dependency directory with a stable key so Maven or Gradle downloads survive across runs. Upload the built jar or image as an artifact so the deploy job promotes the exact bytes that passed tests. The pitfall is one giant job that installs, tests, publishes, and deploys with no visibility into which stage failed.$body$, $code$on:
  pull_request:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21
          cache: maven$code$),
    ('ci-cd-github-actions-java', 2, 'Matrix jobs across supported JDKs', $body$A matrix runs the same test job on several JDK versions and, where relevant, operating systems. Configure the strategy to fail fast only if you want quick feedback over full coverage; otherwise let all combinations finish so one version failure does not hide others. Name jobs with the matrix values to make failures readable. The trade-off is runner cost and wall-clock time: testing every combination on every commit is wasteful. A common compromise runs the full matrix on the main branch and the minimum supported JDK on pull requests.$body$, $code$strategy:
  fail-fast: false
  matrix:
    java: [ '21', '25' ]
runs-on: ubuntu-latest
steps:
  - uses: actions/setup-java@v4
    with:
      distribution: temurin
      java-version: ${{ matrix.java }}
      cache: maven$code$),
    ('ci-cd-github-actions-java', 3, 'Artifacts, environments, and promotion', $body$Artifacts are the handoff between build and deploy: upload the jar or image once, then reference it from the deploy job. Protected GitHub environments add required reviewers, scoped secrets, and environment-specific variables so production deploys are deliberate. Prefer short-lived identity federation over long-lived cloud keys stored as secrets. The main trade-off is pipeline complexity versus traceability: a promoted artifact plus environment approvals gives an auditable chain from commit to running version. Keep deploy jobs thin, and make rollback a redeploy of the previous artifact rather than a manual hotfix.$body$, $code$deploy:
  needs: build
  runs-on: ubuntu-latest
  environment: production
  permissions:
    id-token: write
    contents: read
  steps:
    - uses: actions/download-artifact@v4
      with:
        name: service-jar
    - run: ./scripts/deploy.sh$code$),
    ('ci-cd-quality-gates', 1, 'Fail fast on cheap checks', $body$Order checks by cost and certainty: compilation first, then fast unit tests, then slower integration tests, static analysis, and security scans. Fail the pipeline on the first broken gate so developers get feedback in minutes, not after a long build. Keep a strict separation between checks that must pass for merge and informational checks that only report. The pitfall is a gate that fails intermittently: flaky tests and time-bound scans erode trust, and teams start bypassing the pipeline. Treat instability in a gate as a defect with an owner, not background noise.$body$, $code$jobs:
  fast-checks:
    runs-on: ubuntu-latest
    steps:
      - run: ./mvnw -B -ntp test
  integration-tests:
    needs: fast-checks
    runs-on: ubuntu-latest
    steps:
      - run: ./mvnw -B -ntp verify -Pintegration$code$),
    ('ci-cd-quality-gates', 2, 'Set meaningful coverage thresholds', $body$Coverage is a proxy, not a goal. A single project-wide percentage rewards writing tests for trivial code and hides untested risk; per-package thresholds or coverage on changed lines are more useful. Enforce the threshold in the build with a tool such as JaCoCo so it cannot be silently skipped, and make deliberate exclusions visible in review. The trade-off is pressure to test implementation details to satisfy a number. Set a floor that reflects current reality, ratchet it upward slowly, and never let a numeric gate replace review of what the tests actually assert.$body$, $code$- name: Verify with coverage
  run: ./mvnw -B -ntp verify
- name: Publish coverage report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: jacoco-report
    path: target/site/jacoco$code$),
    ('ci-cd-quality-gates', 3, 'Scan code and dependencies', $body$Static analysis and dependency scanning find classes of problems tests do not: unsafe patterns, dead code, and known vulnerable library versions. Run them on every pull request for fast feedback, and schedule a deeper scan of the main branch, since new vulnerability data arrives after code stops changing. CodeQL, SpotBugs, and dependency audit tools integrate with GitHub Actions; findings should create tracked work rather than drown reviewers. The pitfall is turning scans into blocking gates at maximum severity without triage, which pushes teams to disable them. Start advisory, then ratchet the gate as the backlog clears.$body$, $code$permissions:
  security-events: write
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: java-kotlin
      - uses: github/codeql-action/analyze@v3$code$),
    ('blue-green-deployments', 1, 'Run two environments, switch traffic', $body$Blue-green keeps two production-like environments. One serves live traffic while the other receives the new release; when the new version passes its checks, a router, load balancer, or DNS switch flips traffic to it. The old environment stays intact, so rollback is another switch, not a rebuild. The main constraints are database compatibility and cost: both versions must read and write the same schema during overlap, so schema changes follow expand-and-contract. Running double capacity is expensive, so plan decommissioning and keep the idle side warm but lean. Verify the switch is fast enough for your recovery objective.$body$, $code$# Flip the load balancer to the green target group
aws elbv2 modify-listener --listener-arn "$LISTENER" \
  --default-actions Type=forward,TargetGroupArn="$GREEN_TG"
# Roll back by switching back to blue
aws elbv2 modify-listener --listener-arn "$LISTENER" \
  --default-actions Type=forward,TargetGroupArn="$BLUE_TG"$code$),
    ('blue-green-deployments', 2, 'Keep the database compatible', $body$The database is the hard part of blue-green. During cutover both versions are live, so every schema change must work for old and new code simultaneously: add nullable columns and new tables first, backfill, then switch reads and writes, and only remove old structures later. Destructive or blocking migrations, such as dropping a column or rewriting a large table, cannot ride along with the release. Treat the migration as its own deployable unit with its own verification, and test it against a production-shaped copy. If a migration cannot be made compatible, blue-green is the wrong release pattern.$body$, $code$-- Compatible with old and new application versions
ALTER TABLE orders ADD COLUMN channel VARCHAR(32);
-- Backfill in batches, outside the deploy window
UPDATE orders SET channel = 'web'
WHERE channel IS NULL AND id <= 100000;
-- Drop the old column only in a later release$code$),
    ('blue-green-deployments', 3, 'Control cost and cleanup', $body$Double capacity is a temporary cost, not a steady state. Decide up front how long the old environment stays available for rollback, and schedule its teardown with the same automation that created it. Watch for forgotten resources: idle load balancers, duplicated managed databases, and warm pools that keep billing after the release is settled. A cheaper variant keeps only the new version fully sized and the old one scaled down but quickly recoverable, at the price of a slower rollback. The rule is simple: every blue-green release has an owner-approved end date for the standby environment.$body$, $code$# Keep the standby small but deployable
kubectl scale deployment/orders-blue --replicas=1
# After the rollback window, tear it down with the same pipeline
kubectl delete -f k8s/orders-blue.yaml
# Check that nothing keeps billing
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=release,Values=orders-2026-10$code$),
    ('canary-deployments', 1, 'Shift traffic in controlled steps', $body$A canary sends a small share of traffic to the new version, watches health signals, and increases the share in steps until it holds everything. The pattern limits blast radius, but only if the canary receives enough traffic for metrics to be meaningful and if the two versions can share the same database and cache schema. Decide the step sizes, dwell time at each step, and the exact metrics that gate promotion before the release starts. The pitfall is a canary that routes only friendly traffic or that nobody watches. Traffic shifting is the mechanism; analysis is what makes it safe.$body$, $code$# Argo Rollouts canary steps
strategy:
  canary:
    steps:
      - setWeight: 5
      - pause: { duration: 10m }
      - setWeight: 25
      - pause: { duration: 10m }
      - setWeight: 100$code$),
    ('canary-deployments', 2, 'Define objective gate metrics', $body$Gates must be measurable and tied to user experience: error rate, latency percentiles, saturation, and business counters such as successful checkouts. Compare the canary against the stable version over the same window rather than against a fixed absolute value, since traffic mixes vary. Set thresholds with enough margin to avoid noise-triggered rollbacks, and require a minimum sample before judging. A pitfall is gating on a metric with low volume, where a handful of failures looks catastrophic. Choose gates you already trust from dashboards and alerts rather than inventing new ones during a release.$body$, $code$# Canary must hold error ratio under one percent
sum(rate(http_requests_total{version="canary",status=~"5.."}[5m]))
  /
sum(rate(http_requests_total{version="canary"}[5m])) < 0.01
# And keep p95 latency inside the SLO budget
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket{version="canary"}[5m])) by (le)) < 0.3$code$),
    ('canary-deployments', 3, 'Automate rollback criteria', $body$Rollback must be automatic when a gate fails, not a debate during an incident. Wire the analysis step to stop the rollout, shift weight back to the stable version, and alert the release owner with the failed metric attached. Automated rollback also needs a clean state story: in-flight requests drained, schema compatible with the previous version, and no irreversible side effects such as one-way data migrations or emailed messages. The pitfall is a rollback that tests never exercised; rehearse it in a lower environment. A rollout without automatic rollback will eventually be rolled forward under pressure.$body$, $code$# Rollouts aborts automatically when analysis fails
kubectl argo rollouts get rollout orders --watch
# Manual abort during rehearsal
kubectl argo rollouts abort orders
# Return to the stable version
kubectl argo rollouts undo orders$code$),
    ('feature-flags-in-practice', 1, 'Classify flags before adding them', $body$Not every toggle is the same. Release flags hide unfinished work behind trunk-based development; operational flags disable risky behavior during incidents; permission flags target specific users or plans; experiment flags split traffic for measurement. Each type has a different lifetime and owner. Release and experiment flags should be temporary, while operational and permission flags may live for years as deliberate configuration. Classify a flag when it is created, record its intended removal date, and review the inventory regularly. The pitfall is treating all toggles as permanent because nobody defined what done means.$body$, $code$# A flag definition carries type, owner, and expiry
orders-checkout-v2:
  type: release
  owner: payments-team
  expires: 2026-12-01
  default: false
  description: Checkout rewrite rollout$code$),
    ('feature-flags-in-practice', 2, 'Target carefully and fail closed', $body$Targeting rules decide who sees a flagged behavior: user identifiers, tenant, region, percentage rollouts, or internal accounts. Bind rules to stable attributes, since changing a rule mid-rollout reshuffles cohorts and confuses measurements. Evaluate flags on the server for anything security-relevant; client-side evaluation leaks rule logic and can be manipulated. Decide explicitly what happens when the flag service is unreachable: for a risky new path, safer to fall back to the old behavior than to guess. The pitfall is percentage targeting without sticky assignment, which gives users a different experience on every request.$body$, $code$boolean checkoutV2(String userId) {
    return client.getBooleanValue(
        "orders-checkout-v2",
        false,
        new MutableContext(userId));
}$code$),
    ('feature-flags-in-practice', 3, 'Pay down flag debt', $body$Every flag adds branches, tests, and mental load. Once a release flag reaches full rollout, remove the flag and the old code path instead of leaving both forever; stale flags are a leading source of confusing behavior and dead code. Track flags in a small inventory with owner, type, and removal date, and fail a check when a temporary flag passes its expiry. When removing, delete the flag configuration, the old branch, and its tests in one change. The rule of thumb is blunt: temporary flags are created with a removal plan, and the plan is executed.$body$, $code$# Find flags past their removal date
today=$(date +%F)
awk -v today="$today" \
  '/expires:/ { if ($2 < today) print "STALE: " FILENAME " " $2 }' \
  flags/*.yaml$code$),
    ('infrastructure-as-code-terraform', 1, 'Model resources and review plans', $body$Terraform turns cloud infrastructure into versioned code: providers talk to APIs, resources declare desired state, and plan shows the difference before anything changes. For Java teams this covers the platform around the service: database, cache, queue, networking, and secret containers. The critical discipline is reviewing every plan, because a small edit can imply replacement of a database or a public route. Keep environments in separate state files or workspaces so a staging apply cannot reach production. The pitfall is letting humans apply unreviewed plans; automate plan on pull requests and apply only from the main branch.$body$, $code$resource "aws_db_instance" "orders" {
  identifier        = "orders-${var.environment}"
  engine            = "postgres"
  instance_class    = var.db_instance_class
  allocated_storage = 50
  multi_az          = var.environment == "prod"
  storage_encrypted = true
  tags = {
    service = "orders"
    env     = var.environment
  }
}$code$),
    ('infrastructure-as-code-terraform', 2, 'Treat state as production data', $body$Terraform state maps declared resources to real infrastructure and often contains sensitive values, so it belongs in a remote backend with encryption, access control, and locking, never in a repository or a laptop. Locking prevents two applies from racing and corrupting the mapping; access control prevents one team from reading another environment state. Import existing resources rather than deleting and recreating them, and never edit state by hand. The pitfall is a shared state bucket with no separation: one misdirected apply can destroy resources belonging to another service. Separate state per service and per environment.$body$, $code$terraform {
  backend "s3" {
    bucket         = "acme-terraform-state"
    key            = "orders/prod/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}$code$),
    ('infrastructure-as-code-terraform', 3, 'Modules, versions, and drift', $body$Modules package repeated infrastructure so teams stop copying resource blocks: a database module with inputs for class, storage, and environment, and outputs for connection endpoints. Pin provider and module versions so an upgrade is a reviewed change, not a surprise during an unrelated apply. Drift happens when someone changes infrastructure outside Terraform; detect it with a scheduled plan and reconcile it deliberately, since an automatic apply can erase an urgent but undocumented fix. The pitfall is unbounded module nesting that hides what actually gets created. Prefer a few shallow modules with clear inputs over a deep framework.$body$, $code$module "orders_db" {
  source = "./modules/postgres"

  environment    = var.environment
  instance_class = var.db_class
  backup_days    = 14
}

output "orders_db_endpoint" {
  value = module.orders_db.endpoint
}$code$),
    ('aws-managed-services-java', 1, 'Pick managed primitives for each need', $body$A typical Spring service needs a relational database, a cache, a queue for asynchronous work, an object store for files, and a secret store. On AWS the usual managed choices are RDS for PostgreSQL, ElastiCache for Redis, SQS for queues, S3 for objects, and Secrets Manager for credentials. Managed services trade control for reduced operational work: backups, patching, and failover become configuration. The pitfall is assuming managed means zero operations; capacity, connection limits, and failover still need design. Use standard protocols so the service can run against local substitutes in development and against managed services in production.$body$, $code$spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  data:
    redis:
      host: ${REDIS_HOST}
      port: 6379$code$),
    ('aws-managed-services-java', 2, 'Connect with scoped IAM roles', $body$Workloads should receive credentials through IAM roles attached to the compute environment, not long-lived access keys in configuration. Each service gets its own role with a narrow policy: read and write only the queues, buckets, and secrets it actually uses, scoped by resource naming. In Kubernetes, identity federation maps a service account to a role without storing keys; on ECS or Lambda the task role plays the same part. The pitfall is one shared role for every service, which turns any compromised service into full account compromise. Rotate and review policies as part of normal change management.$body$, $code${
  "Effect": "Allow",
  "Action": ["sqs:SendMessage", "sqs:ReceiveMessage"],
  "Resource": "arn:aws:sqs:eu-central-1:123456789012:orders-events"
}$code$),
    ('aws-managed-services-java', 3, 'Design around managed-service behavior', $body$Managed services have failure and performance characteristics you must design for. SQS standard queues deliver at least once and may duplicate, so handlers must be idempotent; visibility timeouts and dead-letter queues bound retries. ElastiCache failover briefly drops connections, so clients need retry and connection validation. RDS failover repoints the writer DNS record and drops open connections, which means pools must recover, and read replicas lag. The pitfall is treating managed services as transparent replacements for local ones. Confirm ordering, duplication, latency, and connection semantics for each primitive, then encode those expectations in integration tests.$body$, $code$@SqsListener("orders-events")
void handle(OrderEvent event) {
    if (!seen.add(event.id())) {
        return;
    }
    orderService.apply(event);
}$code$),
    ('azure-managed-services-java', 1, 'Map needs to Azure primitives', $body$The Azure equivalents of the common managed building blocks are Azure Database for PostgreSQL Flexible Server, Azure Cache for Redis, Azure Service Bus for queues and topics, Blob Storage for objects, and Key Vault for secrets. Service Bus offers sessions and dead-lettering for ordered or retried work, which maps well to Java messaging patterns. Spring Cloud Azure integrates these services with Spring conventions, including passwordless authentication. The pitfall is choosing services by name similarity rather than by delivery semantics: at-least-once, ordering, and retention differ between offerings. Verify semantics against the workload before committing.$body$, $code$spring:
  datasource:
    url: jdbc:postgresql://${PG_HOST}:5432/orders
  data:
    redis:
      host: ${REDIS_HOST}
  cloud:
    azure:
      keyvault:
        secret:
          property-source-enabled: true$code$),
    ('azure-managed-services-java', 2, 'Authenticate without stored secrets', $body$Azure managed identities let a workload obtain tokens for PostgreSQL, Key Vault, and Service Bus without passwords or keys in configuration. Assign the identity to the compute resource, grant it least-privilege roles on each target, and let the Spring integration acquire and refresh tokens. This removes the rotation treadmill and shrinks the blast radius of configuration leaks. The pitfall is granting a broad role such as Contributor because the narrow role was unknown. Start from data-plane roles scoped to the specific resource, test with the identity in a lower environment, and keep a break-glass procedure documented separately.$body$, $code$spring:
  datasource:
    url: jdbc:postgresql://${PG_HOST}:5432/orders
    azure:
      passwordless-enabled: true
  cloud:
    azure:
      credential:
        managed-identity-enabled: true$code$),
    ('azure-managed-services-java', 3, 'Plan for platform limits and failover', $body$Azure managed services impose connection limits, throttling behavior, and maintenance windows that affect Java clients. Flexible Server can fail over, which briefly interrupts connections; Redis can be patched or scaled; Service Bus throttles under burst. Design pools with validation and bounded retries with jitter, use dead-letter queues for poison messages, and make handlers idempotent because the default receive mode is at least once. The pitfall is retrying platform throttling aggressively, which extends the outage. Treat throttling as a backpressure signal: slow producers, and keep timeouts shorter than the caller budget.$body$, $code$void sendWithBackoff(ServiceBusSender client, ServiceBusMessage message)
        throws InterruptedException {
    long delay = 200;
    for (int attempt = 1; attempt <= 5; attempt++) {
        try {
            client.sendMessage(message);
            return;
        } catch (ServiceBusException e) {
            Thread.sleep(delay + ThreadLocalRandom.current().nextLong(delay));
            delay *= 2;
        }
    }
    throw new IllegalStateException("retries exhausted");
}$code$),
    ('gcp-managed-services-java', 1, 'Map needs to Google Cloud primitives', $body$On Google Cloud the analogous managed building blocks are Cloud SQL for PostgreSQL, Memorystore for Redis, Pub/Sub for messaging, Cloud Storage for objects, and Secret Manager for secrets. Pub/Sub decouples producers from subscribers with at-least-once delivery, push or pull subscriptions, and dead-letter topics for repeatedly failing messages. Spring Cloud GCP wraps these services with familiar Spring abstractions. The pitfall is mapping message semantics loosely: ordering keys, retention, and acknowledgement deadlines behave differently from other queues, and consumers must be idempotent. Match the primitive to the workload semantics you need, not to the closest brand name.$body$, $code$spring:
  cloud:
    gcp:
      project-id: ${GCP_PROJECT}
      sql:
        database-name: orders
        instance-connection-name: ${CLOUD_SQL_CONNECTION}
      pubsub:
        enabled: true$code$),
    ('gcp-managed-services-java', 2, 'Use workload identity federation', $body$Google Cloud workload identity federation lets a Kubernetes service account, or a key-free flow on other platforms, impersonate a Google service account with short-lived tokens. Configure the service account with narrow IAM roles: Secret Manager secret accessor for one secret, Pub/Sub publisher for one topic, Cloud SQL client for the instance. This removes downloaded JSON keys, which are the most commonly leaked cloud credential. The pitfall is binding a default compute service account with editor-level access because it already exists. Create one identity per service and grant roles explicitly, then test that the service fails when the role is absent.$body$, $code$gcloud secrets add-iam-policy-binding orders-db-password \
  --member="serviceAccount:orders@project.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
gcloud pubsub topics add-iam-policy-binding orders-events \
  --member="serviceAccount:orders@project.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"$code$),
    ('gcp-managed-services-java', 3, 'Autoscale managed capacity predictably', $body$Managed does not mean infinite. Cloud SQL has connection ceilings per tier, Memorystore has memory limits and failover gaps, and Pub/Sub has throughput you must provision for high-volume topics. Size instances and connection pools to the same number: a hundred application replicas cannot each hold a large pool against a small database. Use min instances or warm pools for latency-sensitive services so cold starts and JIT warmup do not hit the first requests. The pitfall is scaling the application tier while the managed tier stays fixed, which converts a traffic spike into timeout errors. Capacity plans belong with the deployment.$body$, $code$apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: orders
spec:
  minReplicas: 3
  maxReplicas: 30$code$),
    ('secrets-management-in-the-cloud', 1, 'Move secrets out of plain variables', $body$Environment variables are the minimum bar, not a destination: they leak through crash dumps, child processes, and diagnostic endpoints, and a value in a deployment manifest is visible to anyone who can read the manifest. A secret store adds access control, audit trails, versioning, and rotation hooks. Applications should read secrets through an SDK or an injected file, cache them briefly, and never log them. The pitfall is a store used as a plain key-value dump with one broad policy, which recreates the original problem with extra steps. Scope each secret to the identities that legitimately consume it.$body$, $code$# Kubernetes mounts the secret as files
spring:
  config:
    import: "optional:configtree:/mnt/secrets/"
  datasource:
    password: ${db-password}$code$),
    ('secrets-management-in-the-cloud', 2, 'Rotate credentials without redeploying', $body$Rotation should be routine, not an incident trigger. Prefer credentials the platform can rotate automatically, such as managed identities and tokens, or database passwords rotated by the secret store with overlapping validity so old connections finish. Applications must reload rotated values instead of caching them forever; a short refresh interval or a restart signal is usually enough. Test rotation in a lower environment on a schedule, because rotation paths rot when unused. The pitfall is rotation that requires a coordinated redeploy of every consumer; that coupling turns a routine security task into an outage risk.$body$, $code$# Rotate with an overlap window so old connections drain
aws secretsmanager rotate-secret \
  --secret-id orders/db \
  --rotation-lambda-arn "$ROTATOR"
# Verify the new version is readable before closing the window
aws secretsmanager get-secret-value --secret-id orders/db \
  --version-stage AWSCURRENT | jq -r .Name$code$),
    ('secrets-management-in-the-cloud', 3, 'Give developers a safe local path', $body$If local development requires production credentials, people will copy production credentials. Provide a sanctioned local path: a personal or shared development secret with limited scope, a local emulator, or short-lived credentials issued by the platform and expiring quickly. Keep such secrets out of repositories with pre-commit scanning and keep them out of CI logs by masking. The pitfall is documentation that says never but tooling that makes it necessary. Make the safe option also the easiest option, and the unsafe shortcut loses its audience. Review leaked-credential alerts quickly; a committed key can be scraped within minutes.$body$, $code$# Local development reads a dev-scoped secret
aws secretsmanager get-secret-value --secret-id orders/db-dev \
  --query SecretString --output text > .env.local
echo ".env.local" >> .gitignore
# Pre-commit scanning keeps secrets out of history
gitleaks detect --no-banner$code$),
    ('autoscaling-strategies', 1, 'Choose signals that track demand', $body$CPU utilization is easy but imperfect: services waiting on databases or downstream calls show low CPU while requests queue. Better signals track demand directly: requests in flight, request rate, latency against an SLO, or queue depth for workers. Queue depth is the natural signal for asynchronous consumers, while concurrency-based scaling fits HTTP services with external latency. Whatever signal you choose, validate it during a load test: scaling decisions that only appear correct in production are guesses. The pitfall is a metric with lazy averaging that reacts minutes after the spike, which is exactly when capacity mattered.$body$, $code$apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: orders-worker
spec:
  scaleTargetRef:
    name: orders-worker
  triggers:
    - type: aws-sqs-queue
      metadata:
        queueLength: "20"$code$),
    ('autoscaling-strategies', 2, 'Warm up before serving traffic', $body$New instances start cold: the JVM interprets bytecode until hot loops compile, connection pools open lazily, and caches are empty. If a freshly started instance receives full traffic immediately, latency spikes and health checks may fail, causing more churn. Mitigate with readiness gates that wait for pool warmup and a warm-up endpoint, minimum instance counts, and gradual traffic ramp-in. Measure startup and warm-up time as an operational metric and keep it inside the scaling budget. The pitfall is scaling out during an incident only to have new instances amplify the outage by timing out.$body$, $code$readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 20
  periodSeconds: 5
  failureThreshold: 3$code$),
    ('autoscaling-strategies', 3, 'Scale in without losing work', $body$Scaling in is riskier than scaling out because it terminates running work. Consumers must finish in-flight messages or return them to the queue; long-running jobs need checkpointing or a job queue with visibility timeouts; scheduled tasks need leader election so only one instance runs them. Use termination grace periods, pre-stop hooks, and connection draining, and scale in gradually. For stateful or singleton work, keep the safest floor: one instance that does not participate in scale-in. The pitfall is treating consumers as stateless when they hold a message that will be redelivered only after a timeout.$body$, $code$spec:
  terminationGracePeriodSeconds: 60
  containers:
    - name: orders
      lifecycle:
        preStop:
          exec:
            command: ["sh", "-c", "sleep 15"]$code$),
    ('multi-environment-configuration', 1, 'Externalize values, keep keys stable', $body$Configuration should differ by value, not by structure. Keep the same property keys in every environment so a missing or renamed key is a visible failure rather than a silent default. Spring profiles select environment-specific documents, but values themselves should come from the deployment platform: environment variables, mounted config files, or a config server. Build the artifact once and inject values at deploy time. The pitfall is logic hidden in profiles, where behavior changes between environments in ways tests never cover. Reserve profiles for wiring differences; make behavior configurable through explicit keys.$body$, $code$# Same keys everywhere; values injected per environment
spring:
  application:
    name: orders
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}
  config:
    import: "optional:configserver:${CONFIG_SERVER_URL:}"$code$),
    ('multi-environment-configuration', 2, 'Layer per-environment overrides', $body$A clean layering order is: defaults in the artifact, environment values from the platform, and a small set of secrets from the secret store. Later sources override earlier ones, so document the precedence and keep the number of layers small. Prefer explicit overrides over copied config files, which drift as keys are added. For a Kubernetes deployment, ConfigMaps and Secrets cover most needs without a config server. The pitfall is two sources defining the same key differently; when behavior surprises you, nobody knows which layer won. One key, one source.$body$, $code$apiVersion: v1
kind: ConfigMap
metadata:
  name: orders-config
data:
  LOG_LEVEL: INFO
  DB_POOL_SIZE: "10"
---
envFrom:
  - configMapRef:
      name: orders-config$code$),
    ('multi-environment-configuration', 3, 'Detect drift before it bites', $body$Environment drift is configuration that changed without review: a hotfix applied to production only, a staging key never documented, a default that differs between regions. Detect it by comparing effective configuration across environments, failing startup when a required key is missing, and capturing the resolved configuration in logs or a diagnostic endpoint per deployment. Treat configuration as code: changes go through review and are versioned with the release they belong to. The pitfall is trusting documentation over the running system; the effective values are the truth. Periodically diff them, and reconcile deliberately.$body$, $code$@ConfigurationProperties("orders")
public record OrdersProperties(String queueUrl, int poolSize) {
    public OrdersProperties {
        Objects.requireNonNull(queueUrl, "orders.queue-url must be set");
        if (poolSize < 1 || poolSize > 50) {
            throw new IllegalArgumentException("poolSize out of range");
        }
    }
}$code$),
    ('cost-aware-architecture', 1, 'Right-size before optimizing architecture', $body$Most cloud bills start with over-provisioning: instances chosen for a peak that rarely occurs, replicas that never scale down, and storage growing without review. Right-sizing uses actual utilization data over weeks, not a single busy afternoon, and prefers many moderate instances over few oversized ones that fail expensively. Set budgets and alerts per environment so cost changes are visible early. The pitfall is optimizing the bill by cutting capacity below the safety margin, which trades a predictable cost for an unpredictable outage. Performance headroom is a feature; waste is not.$body$, $code$# Look at weeks of utilization, not one busy afternoon
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 --metric-name CPUUtilization \
  --extended-statistics p95 --period 86400 \
  --start-time 2026-09-01T00:00:00Z \
  --end-time 2026-10-01T00:00:00Z$code$),
    ('cost-aware-architecture', 2, 'Use storage lifecycle policies', $body$Object storage is cheap per gigabyte, but cost accumulates through versions, incomplete multipart uploads, and old logs kept forever. Lifecycle rules move rarely accessed data to colder classes, expire temporary objects, and abort incomplete uploads. Databases and search indexes need the same thinking: retain what regulation and debugging require, archive the rest, and verify that deletion actually happens. The trade-off is retrieval cost and latency: colder storage is cheaper to keep and more expensive to read. Classify data by access pattern first, then attach a lifecycle policy to each class.$body$, $code${
  "Rules": [
    {
      "Status": "Enabled",
      "Filter": { "Prefix": "logs/" },
      "Transitions": [{ "Days": 30, "StorageClass": "STANDARD_IA" }],
      "Expiration": { "Days": 365 }
    }
  ]
}$code$),
    ('cost-aware-architecture', 3, 'Account for egress and idle', $body$Two cost sources surprise teams: data egress and environments nobody uses. Cross-region traffic, NAT gateways, and internet-bound responses are easy to design without noticing until the bill arrives; keep chatty services in one region, cache responses, and compress payloads. Idle environments, such as preview stacks and staging databases, bill around the clock for occasional use; schedule them off outside working hours where the workflow allows. The pitfall is attributing cost only to compute. Tag resources by service and environment, review the largest line items monthly, and make cost visible in the same dashboards as latency.$body$, $code$# Tag resources so cost can be attributed
aws ec2 create-tags \
  --resources "$INSTANCE_ID" \
  --tags Key=service,Value=orders Key=env,Value=staging
# Stop idle non-production compute outside working hours
aws ec2 stop-instances --instance-ids "$INSTANCE_ID"$code$)
) AS s(slug, sort_order, title, body, starter_code)
JOIN tutorial t ON t.slug = s.slug
WHERE NOT EXISTS (
    SELECT 1
    FROM tutorial_section existing
    WHERE existing.tutorial_id = t.id AND existing.sort_order = s.sort_order
);

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id, t.id,
       COALESCE((SELECT MAX(existing.sort_order)
                 FROM learning_path_tutorial existing
                 WHERE existing.learning_path_id = lp.id), 0)
       + ROW_NUMBER() OVER (PARTITION BY lp.id ORDER BY t.slug)
FROM learning_path lp
JOIN tutorial t ON t.level = CASE lp.slug
    WHEN 'junior-java-developer' THEN 'Junior'
    WHEN 'mid-java-engineer' THEN 'Mid'
    WHEN 'senior-java-engineer' THEN 'Senior'
    WHEN 'lead-java-engineer' THEN 'Lead'
    WHEN 'principal-java-engineer' THEN 'Principal'
END
WHERE t.slug IN (
    'twelve-factor-spring-apps', 'environment-parity', 'ci-cd-github-actions-java',
    'ci-cd-quality-gates', 'blue-green-deployments', 'canary-deployments',
    'feature-flags-in-practice', 'infrastructure-as-code-terraform',
    'aws-managed-services-java', 'azure-managed-services-java',
    'gcp-managed-services-java', 'secrets-management-in-the-cloud',
    'autoscaling-strategies', 'multi-environment-configuration',
    'cost-aware-architecture'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
