# JavaCraft

JavaCraft is an engineering simulator for learning to build production Java systems:
**read → think → code → run → debug → test → submit → review → improve**.

The repository is being built in incremental, runnable slices. The initial foundation
provides the product architecture and contracts, a React learning-workspace shell, and
a Spring Boot content API. User authentication, persisted progress, and sandboxed code
execution are deliberately not represented as complete features yet.
The workspace dashboard and learning-progress figures are sample content, not a signed-in
learner account or persisted assessment results.

## Run locally

Requirements: Docker with Compose.

```sh
docker compose up --build
```

- Frontend: <http://localhost:5173>
- Platform API: <http://localhost:8080/api/v1/catalog>
- Health: <http://localhost:8080/actuator/health>
- PostgreSQL is reachable only on the Compose network. To open a local SQL shell, run
  `docker compose exec db psql -U javacraft -d javacraft`.

The editor is an interface preview. **Run Tests is not enabled as a code runner** until
the isolated execution service and its security controls are implemented. The platform
API never executes submitted code.

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
└── docker-compose.yml       Local development services
```

## Build sequence

1. Platform foundation: architecture, data/API contracts, content API, and workspace shell.
2. Identity and persistence: registration/login, authorization, database-backed catalog,
   progress, and submission history.
3. Isolated execution: asynchronous jobs, public/hidden tests, bounded output, and
   hardened sandbox workers. This is a security gate, not an in-process implementation.
4. Learning and feedback: scoring, skill graph, achievements, and guided code review.
5. Operations and authoring: admin workflows, observability, CI, and deployment hardening.

See [docs/architecture.md](docs/architecture.md) and [docs/openapi.yaml](docs/openapi.yaml)
for the foundation design and initial API surface.
