# JavaCraft architecture

## Product boundary

JavaCraft teaches engineering judgment, not just Java syntax. A learning activity is
structured content plus an exercise, observable test feedback, a submission, and an
explanation of the engineering concepts demonstrated. Progress is awarded for evidence
of skill, not for reading or clicking through material.

The product is split into independently deployable frontend, platform API, and execution
worker boundaries. The platform API owns identity, content, submissions, progression,
and orchestration. It must never compile or execute learner code in its own process.

## System topology

```text
Browser
  └─ React + TypeScript (React Router, TanStack Query, Monaco, Tailwind)
       └─ HTTPS REST / SSE
            └─ Spring Boot platform API
                 ├─ PostgreSQL (authoritative product data; Flyway migrations)
                 ├─ Redis (optional cache, rate limits, short-lived job state)
                 └─ execution queue
                      └─ isolated execution control plane
                           └─ disposable Java 21 sandbox worker
                                └─ bounded, redacted result → API → browser
```

### Responsibilities

| Component | Owns | Must not do |
| --- | --- | --- |
| Web app | Navigation, editor, user feedback, API state | Trust client-side scores or test outcomes |
| Platform API | Identity/authorization, catalog, progress, submissions, job orchestration | Run or compile submitted code |
| PostgreSQL | Durable users, content, progress, execution metadata | Store plaintext credentials or hidden-test source in client-readable content |
| Execution control plane | Queue, worker lifecycle, gVisor container lifecycle, result normalization | Expose the Docker socket to the API or learner code; fall back to `runc` |
| Sandbox worker | Compile/test one immutable public-test job and return bounded results | Reach the internet, other jobs, host files, Docker socket, or internal services |

## Repository structure

```text
backend/
  src/main/java/com/javacraft/platform/
    config/       cross-cutting Spring configuration
    catalog/      tutorial/challenge read models and endpoints
    identity/     registration, sessions, roles (milestone 2)
    progress/     skill evidence and progression (milestone 2+)
    execution/    queued challenge runs and gVisor worker orchestration
  src/main/resources/db/migration/ normalized PostgreSQL schema
docs/                            architecture and API contracts
frontend/src/
  app/             router and query client
  components/      reusable shell and UI
  features/        dashboard, learning path, tutorials, challenge workspace
  lib/             typed API client
execution/sandbox/                 public-test image run only with Docker runtime runsc
```

The API is organized by product capability, with transport DTOs at the boundary and
domain/application logic behind it. Avoid a single controller/service that accumulates
unrelated product behavior.

## Data model

The relational model is normalized around stable entities and join tables. User skill
and progress rows are derived from assessed evidence and keep provenance to submissions.
Challenge tests have an explicit visibility flag; hidden test definitions never appear
in public catalog responses. See
`backend/src/main/resources/db/migration/V1__initial_schema.sql`.

Important invariants:

- Passwords are stored only as a strong one-way hash; session credentials are opaque,
  revocable, and stored hashed.
- A submission references a specific challenge version and starter revision.
- Execution state is durable and transitions monotonically (`QUEUED → RUNNING → terminal`).
- Public and hidden test outcomes are stored separately. A learner receives counts and
  sanitized failure identifiers, never hidden test names, source, or assertion messages.
- Skill evidence points to a scored submission/review; tutorial completion alone does
  not grant an engineering level.

## API conventions

- Base path: `/api/v1`; JSON DTOs are versioned independently from database entities.
- Validate request shape and size at ingress; return RFC 7807-style problem details.
- Use pagination for potentially unbounded histories and stable opaque IDs for jobs.
- Authenticate private routes; enforce ownership on every submission/execution lookup.
- Use SSE only for authorized, short-lived execution status/output events. REST remains
  the source of truth for job state.

The API exposes public database-backed catalog reads, learner registration/login/logout,
current-learner lookup, durable tutorial progress, and ownership-checked challenge-run
records. New runs are accepted only while the gVisor worker heartbeat is current.

## Execution and sandbox security

Execution is a separate service and trust boundary. Treat every source file, build file,
annotation processor, test, dependency, generated class, and process as hostile.

For public execution, workers must run on a dedicated Linux host with a hardened runtime
(gVisor `runsc` in this slice), not on developer machines or hosts with valuable data.
The trusted execution manager is the only component with the Docker daemon socket; use a
rootless Docker daemon on a disposable host where possible. The API and sandbox have no
socket mount. A normal Docker `runc` container shares the host kernel and is not by itself
a sufficient boundary for a public arbitrary-code service.

Each job receives an ephemeral workspace and container with:

- non-root UID, dropped capabilities, `no-new-privileges`, seccomp/AppArmor policy;
- read-only base filesystem, bounded writable tmpfs/workspace, no host mounts or devices;
- no network namespace connectivity or DNS; dependencies come only from a pinned,
  reviewed, pre-populated artifact cache;
- cgroup CPU, memory, PID, file-size, and wall-clock limits enforced outside the job;
- bounded stdout/stderr capture, per-learner submission limits, and forced container
  termination at the job deadline;
- one disposable `runsc` container per job; the sandbox image is resolved to an immutable
  image ID when the worker starts.

This slice executes only public tests, for every challenge that has a PUBLIC test row. No
hidden test payload is sent to the sandbox, and hidden-test grading remains disabled. Each
runnable challenge ships a `PublicTests` class returning named boolean checks; the sandbox
compiles it with the learner's file, runs each check with a timeout, and reports
`JAVACRAFT_RESULT passed total`. Because learner code shares the JVM with this harness, a
public-test result can be spoofed by the learner; it is practice feedback, never a grade.
Expand the execution harness only with tests that preserve the test/code separation and
secrecy requirements.

The execution Compose profile fails closed unless the Docker daemon reports the `runsc`
runtime and the sandbox image is present. `scripts/start.sh` and `scripts/start.ps1`
(Windows PowerShell 5.1+) enable the worker automatically on hosts where a gVisor sandbox
can be provided (installing `runsc` inside the Colima VM, registering it with the VM's
Docker daemon, and re-applying that registration whenever the VM has discarded it), keep
it off elsewhere, and honor `ENABLE_EXECUTION_WORKER=true|false` as an explicit override.
Never replace gVisor with `runc`, compiler execution in the API, or browser-side evaluation
of user code.

## Authentication and authorization

The current identity slice uses Spring Security, BCrypt password hashes, and opaque
random session cookies. Only the SHA-256 digest of each session token is persisted;
sessions can be revoked and expire after 30 days. The browser uses an HttpOnly,
SameSite=Lax session cookie and sends a CSRF token header for state-changing requests.
Set `APP_COOKIE_SECURE=true` behind HTTPS in deployed environments. Admin authoring,
hidden-test grading, and broader abuse controls remain later work.

## Frontend structure

React Router defines product routes; TanStack Query owns server state and invalidation;
Zustand is reserved for ephemeral editor/workspace state. Monaco is configured for Java
editing, while API results (not editor-local assumptions) determine test and submission
status. Keep content, editor, test output, hints, and submission history as separate
feature components so the challenge workspace remains navigable and testable.

## MVP milestones and exit criteria

1. **Foundation (current):** Compose starts frontend, API, and PostgreSQL; catalog UI/API
   are reachable; schema/API architecture is documented; no arbitrary code runs.
2. **Identity and durable learning:** registration/login, protected profile, database
   catalog, learning path, progress, and submission-history APIs with integration tests.
3. **Sandboxed execution:** the isolated worker runs public challenge tests on gVisor with
   bounded resources and polling. Hidden-test grading, worker-runtime verification on the
   dedicated Linux deployment, and broader language/challenge support remain gated.
4. **Engineering feedback:** scoring, evidence-backed skills, review/hints, and progression.
5. **Authoring and operations:** admin content workflows, observability, CI/security
   scanning, backups, and production deployment manifests.

## Observability and reliability

Propagate request and execution correlation IDs. Emit structured logs without source
code, credentials, or test contents. Instrument API latency, queue age, worker startup,
compile/test duration, timeout/resource-limit counts, and sanitized completion rates.
Expose health/readiness separately; use OpenTelemetry traces/metrics and Prometheus
scraping. Apply queue backpressure and idempotency keys to submission creation.
