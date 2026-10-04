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
| Execution control plane | Queue, worker lifecycle, limits, result normalization | Share application secrets or unrestricted host access with a worker |
| Sandbox worker | Compile/test one immutable job and return bounded results | Reach the internet, other jobs, host files, Docker socket, or internal services |

## Repository structure

```text
backend/
  src/main/java/com/javacraft/platform/
    config/       cross-cutting Spring configuration
    catalog/      tutorial/challenge read models and endpoints
    identity/     registration, sessions, roles (milestone 2)
    progress/     skill evidence and progression (milestone 2+)
    submission/   submission lifecycle and execution orchestration (milestone 3)
  src/main/resources/db/migration/ normalized PostgreSQL schema
docs/                            architecture and API contracts
frontend/src/
  app/             router and query client
  components/      reusable shell and UI
  features/        dashboard, learning path, tutorials, challenge workspace
  lib/             typed API client
execution/                         planned isolated worker/control plane (milestone 3)
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

The currently implemented first slice exposes public catalog reads only. The complete
initial contract, including planned identity, submission, and execution operations, is
in `docs/openapi.yaml`; operations marked planned are not implemented by the scaffold.

## Execution and sandbox security

Execution is a separate service and trust boundary. Treat every source file, build file,
annotation processor, test, dependency, generated class, and process as hostile.

For production, workers must run on a dedicated node/VM pool with a hardened runtime
(prefer gVisor or Kata Containers, or an equivalent kernel boundary), not on API nodes.
The worker manager uses a narrowly scoped control-plane API; no worker or API container
gets the host Docker socket. A normal Docker container shares the host kernel and is not
by itself a sufficient boundary for a public arbitrary-code service.

Each job receives an ephemeral workspace and container with:

- non-root UID, dropped capabilities, `no-new-privileges`, seccomp/AppArmor policy;
- read-only base filesystem, bounded writable tmpfs/workspace, no host mounts or devices;
- no network namespace connectivity or DNS; dependencies come only from a pinned,
  reviewed, pre-populated artifact cache;
- cgroup CPU, memory, PID, file-size, and wall-clock limits enforced outside the job;
- bounded stdout/stderr capture, rate-limited event delivery, and forced process-tree kill;
- one job per disposable worker; cleanup and image digest verification on completion.

Hidden tests are retrieved by the worker only after job authorization and injected from
trusted storage. The submitted project cannot read their source through the UI/API; test
reports are reduced to pass counts and non-sensitive classifications before persistence.
Do not claim hidden-test secrecy against arbitrary code sharing the same OS process and
filesystem: use process/container separation and a hardened runtime, and keep test source
outside user-writable mounts.

Local development must use an isolated disposable worker/runtime as well. Until that
worker is implemented and threat-model tested, execution remains disabled. Never replace
it with `Runtime.exec`, `ProcessBuilder`, a compiler invocation in the API, or browser-side
evaluation of user code.

## Authentication and authorization

The planned identity slice uses Spring Security, BCrypt/Argon2id password hashing,
short-lived access tokens and rotating, revocable refresh sessions (or an equivalent
secure same-site cookie session). Apply role checks to authoring/admin APIs, ownership
checks to submissions, CSRF protection for cookie-authenticated mutations, and rate
limits for login and execution submission. Secrets are injected at runtime and never
committed.

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
3. **Sandboxed execution:** queued job lifecycle, bounded SSE/polling, Maven/JUnit runner,
   public/hidden test separation, kill/cleanup tests, and security tests on the isolated
   worker runtime. No release until resource/network/filesystem isolation is verified.
4. **Engineering feedback:** scoring, evidence-backed skills, review/hints, and progression.
5. **Authoring and operations:** admin content workflows, observability, CI/security
   scanning, backups, and production deployment manifests.

## Observability and reliability

Propagate request and execution correlation IDs. Emit structured logs without source
code, credentials, or test contents. Instrument API latency, queue age, worker startup,
compile/test duration, timeout/resource-limit counts, and sanitized completion rates.
Expose health/readiness separately; use OpenTelemetry traces/metrics and Prometheus
scraping. Apply queue backpressure and idempotency keys to submission creation.
