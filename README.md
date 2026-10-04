# JavaCraft

JavaCraft is an engineering simulator for learning to build production Java systems:
**read → think → code → run → debug → test → submit → review → improve**.

The repository is being built in incremental, runnable slices. It currently provides
the product architecture, a React learning workspace, a Spring Boot API, learner
registration/login, and PostgreSQL-backed learning progress. Skill proficiency is
not awarded for reading tutorials. Code execution remains disabled until the isolated
worker and its security controls are implemented and tested.

## Run locally

Requirements: Docker with Compose.

```sh
./scripts/start.sh
```

- Frontend: <http://localhost:5173>
- Platform API: <http://localhost:8080/api/v1/catalog>
- Health: <http://localhost:8080/actuator/health>
- PostgreSQL is reachable only on the Compose network. To open a local SQL shell, run
  `docker compose exec db psql -U javacraft -d javacraft`.

Use `./scripts/stop.sh` to stop and remove the JavaCraft containers and network, or
`./scripts/restart.sh` to rebuild and start the platform again. Both scripts preserve
the PostgreSQL data volume.

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
2. Identity and durable learning: registration/login, database-backed catalog, and learner
   tutorial/skill progress.
3. Isolated execution: asynchronous jobs, public/hidden tests, bounded output, and
   hardened sandbox workers. This is a security gate, not an in-process implementation.
4. Learning and feedback: scoring, skill graph, achievements, and guided code review.
5. Operations and authoring: admin workflows, observability, CI, and deployment hardening.

See [docs/architecture.md](docs/architecture.md) and [docs/openapi.yaml](docs/openapi.yaml)
for the foundation design and initial API surface.
