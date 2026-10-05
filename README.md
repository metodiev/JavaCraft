# JavaCraft

JavaCraft is an engineering simulator for learning to build production Java systems:
**read → think → code → run → debug → test → submit → review → improve**.

The repository is being built in incremental, runnable slices. It currently provides
the product architecture, a React learning workspace, a Spring Boot API, learner
registration/login, PostgreSQL-backed learning progress, and a gVisor worker that is
enabled automatically on hosts where an isolated sandbox can run, for public tests on
every challenge. The catalog includes 467 tutorials and 40 challenges across Junior,
Mid, Senior, Lead, and Principal levels. The tutorial library spans the full production
Java stack: the JDK toolchain and JVM internals, Maven and Gradle build engineering,
the Spring ecosystem (Framework 6 and 7, Spring Boot 4), SQL and PostgreSQL,
JPA/Hibernate, Kafka and messaging, containers and Kubernetes, cloud delivery, security
engineering, concurrency, reactive programming, testing and observability,
domain-driven design, performance tuning, and engineering craft. Hidden-test grading
and submission scoring remain disabled.

## Run locally

Requirements for the default local platform: Docker with Compose.

**macOS and Linux (bash):**

```sh
./scripts/start.sh
```

**Windows (PowerShell):**

```powershell
.\scripts\start.ps1
```

On Windows you can also double-click `scripts\start.cmd` (and the matching `stop.cmd` /
`restart.cmd`). The wrappers use `pwsh` when it is installed and fall back to Windows
PowerShell 5.1, which ships with every supported Windows version. If you prefer to run
commands directly in a shell, the `.ps1` files work from PowerShell 5.1 and PowerShell 7+:

```powershell
.\scripts\stop.ps1
.\scripts\restart.ps1
```

If PowerShell refuses to run the scripts, start them with
`powershell -ExecutionPolicy Bypass -File .\scripts\start.ps1` (the `.cmd` wrappers already
do this).

Both script families behave identically:

- Frontend: <http://localhost:5173>
- Platform API: <http://localhost:8080/api/v1/catalog>
- Health: <http://localhost:8080/actuator/health>
- PostgreSQL is reachable only on the Compose network. To open a local SQL shell, run
  `docker compose exec db psql -U javacraft -d javacraft`.

Use the stop script to stop and remove the JavaCraft containers and network, or the restart
script to rebuild and start the platform again. Both scripts preserve the PostgreSQL data
volume.

`start` also enables challenge execution automatically whenever the Docker host can provide
the gVisor sandbox:

- **Colima (macOS):** the first start installs `runsc` inside the VM and registers it with
  the VM's Docker daemon; later starts re-apply the registration whenever it is missing
  (Colima rewrites the daemon configuration on every VM boot), and derive the worker's
  socket and group ID automatically.
- **Linux with Docker Engine:** the worker starts automatically once the host advertises
  the `runsc` runtime.
- **Docker Desktop (macOS and Windows) and other hosts without gVisor:** challenges stay
  off and the script prints the reason; the rest of the platform runs normally.

Set `ENABLE_EXECUTION_WORKER=false` to force the worker off, or
`ENABLE_EXECUTION_WORKER=true` to require it (the script fails if the sandbox is
unavailable). The execution worker is meant for single-user development; for public
deployments follow the dedicated-host setup below.

**Running challenges on Windows.** The gVisor sandbox needs a Linux Docker host, so Docker
Desktop on Windows runs the platform without challenge execution (the scripts say so, and
everything else works). To enable challenges, run JavaCraft from inside a WSL2 distribution
that provides a Linux Docker Engine: use the bash scripts there (`./scripts/start.sh`),
which detect gVisor automatically once the engine advertises `runsc`. Alternatively, point
the Windows scripts at a remote Linux Docker Engine over SSH or TCP by setting `DOCKER_HOST`
plus `EXECUTION_DOCKER_SOCKET` and `EXECUTION_DOCKER_GID` for that engine before starting:

```powershell
$env:DOCKER_HOST = "ssh://runner@build-host"
$env:EXECUTION_DOCKER_SOCKET = "/run/user/1001/docker.sock"
$env:EXECUTION_DOCKER_GID = "1001"
.\scripts\start.ps1
```

For a local development smoke test on macOS, Colima can provide the Linux Docker daemon.
`./scripts/start.sh` installs `runsc` inside the Colima VM automatically using the
[official gVisor installation instructions](https://gvisor.dev/docs/user_guide/install/),
registers the runtime with the VM's Docker daemon, and derives the worker's socket and
group ID from the VM. Set `EXECUTION_DOCKER_SOCKET` and `EXECUTION_DOCKER_GID` explicitly
only to override that detection, or install gVisor manually first when the automatic setup
cannot reach the internet.

This Colima setup is for single-user development and smoke testing only; do not expose it
to public submissions or use it as a shared production runner.

Set the socket path and its group ID for the dedicated runner daemon, then start:

```sh
DOCKER_HOST=unix:///run/user/1001/docker.sock \
EXECUTION_DOCKER_SOCKET=/run/user/1001/docker.sock \
EXECUTION_DOCKER_GID=1001 \
ENABLE_EXECUTION_WORKER=true \
./scripts/start.sh
```

The worker verifies that Docker advertises `runsc`, checks the applied container limits,
and runs a filesystem/network isolation probe before publishing its heartbeat. Requests
return `503` until those checks pass; it never falls back to `runc`. The challenge editor
runs the public tests of every challenge. Challenge content (starter, requirements and
`PublicTests.java`) lives in `backend/src/main/resources/challenge-content/<slug>/` and is
loaded by a repeatable Flyway migration; `scripts/verify-challenges.sh` checks locally that
each reference solution passes and each starter fails. Hidden-test execution, grading, and
the Submit action remain disabled.

This repository is not yet ready to expose publicly as-is. Before a public deployment,
replace the development database credentials, require HTTPS and secure cookies, restrict
CORS, configure ingress and abuse controls, and review the deployment security settings.

## Repository map

```text
.
├── backend/                 Spring Boot platform API
├── backend/src/main/resources/db/migration/
│                            Normalized PostgreSQL schema (Flyway)
├── docs/
│   ├── architecture.md      System boundaries and deployment decisions
│   └── openapi.yaml         Versioned REST API contract
├── frontend/                React, TypeScript, Vite, Monaco
├── execution/sandbox/       Restricted Java 21 public-test image
├── scripts/                 start/stop/restart for bash (.sh) and Windows (.ps1/.cmd)
└── docker-compose.yml       Local services and gVisor execution profile
```

## Build sequence

1. Platform foundation: architecture, data/API contracts, content API, and workspace shell.
2. Identity and durable learning: registration/login, database-backed catalog, and learner
   tutorial/skill progress.
3. Isolated execution: asynchronous public-test jobs on gVisor. Hidden-test
   grading remains a separate security gate and is not enabled by this slice.
4. Learning and feedback: scoring, skill graph, achievements, and guided code review.
5. Operations and authoring: admin workflows, observability, CI, and deployment hardening.

See [docs/architecture.md](docs/architecture.md) and [docs/openapi.yaml](docs/openapi.yaml)
for the foundation design and initial API surface.
