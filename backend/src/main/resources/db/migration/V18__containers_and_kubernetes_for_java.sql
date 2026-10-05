-- V18 — Containers and Kubernetes for Java services.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('dockerfiles-for-java-apps', 'Dockerfiles for Java Applications', 'Build small and predictable Java images with multi-stage Dockerfiles that run as a non-root user.', 'Junior', 24, true, 1),
    ('docker-layer-caching-for-java', 'Docker Layer Caching for Java Builds', 'Order Docker build steps so dependency layers stay cached and rebuilds stay fast.', 'Junior', 22, true, 1),
    ('jib-and-buildpack-strategies', 'Jib and Buildpack Strategies', 'Build Java container images without a Dockerfile and understand the trade-offs of each tool.', 'Junior', 26, true, 1),
    ('docker-compose-for-development', 'Docker Compose for Development', 'Run local dependencies such as databases and brokers with healthchecks and realistic versions.', 'Junior', 24, true, 1),
    ('kubernetes-deployments-and-services', 'Kubernetes Deployments and Services', 'Model rollouts with Deployments and expose stable network entry points with Services.', 'Mid', 30, true, 1),
    ('kubernetes-configmaps-and-secrets', 'Kubernetes ConfigMaps and Secrets', 'Inject configuration and credentials safely and decide when immutable configuration beats in-place edits.', 'Mid', 28, true, 1),
    ('kubernetes-probes-and-health', 'Kubernetes Probes and Health Checks', 'Wire liveness, readiness, and startup probes to Spring Boot health groups without causing outages.', 'Mid', 32, true, 1),
    ('kubernetes-resource-limits-jvm', 'Kubernetes Resource Limits and the JVM', 'Size requests and limits so the JVM uses container memory correctly and throttling stays visible.', 'Mid', 34, true, 1),
    ('kubernetes-hpa-scaling', 'Kubernetes Horizontal Pod Autoscaling', 'Scale Java services automatically while accounting for warmup time and cluster provisioning latency.', 'Mid', 30, true, 1),
    ('kubernetes-jobs-and-cronjobs', 'Kubernetes Jobs and CronJobs', 'Run batch and scheduled workloads with correct retry, overlap, and idempotency behavior.', 'Mid', 28, true, 1),
    ('helm-basics-for-java-services', 'Helm Basics for Java Services', 'Package Java service manifests as Helm charts and upgrade or roll back releases safely.', 'Senior', 38, true, 1),
    ('kubernetes-operators-overview', 'Kubernetes Operators Overview', 'Extend Kubernetes with custom resources and understand when a controller beats a deployment script.', 'Senior', 36, true, 1),
    ('service-mesh-essentials', 'Service Mesh Essentials', 'Understand what a service mesh provides, what it costs, and how traffic policy changes behavior.', 'Senior', 38, true, 1),
    ('container-image-security', 'Container Image Security', 'Reduce image attack surface and enforce scanning, signing, and admission policy in delivery.', 'Mid', 32, true, 1),
    ('container-registries-and-supply-chain', 'Container Registries and Supply Chain', 'Choose a registry, pin images by digest, and attach a software bill of materials to every release.', 'Mid', 30, true, 1),
    ('graceful-shutdown-in-containers', 'Graceful Shutdown in Containers', 'Handle SIGTERM, drain in-flight requests, and close resources in the right order on termination.', 'Mid', 34, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('dockerfiles-for-java-apps', 1, 'Separate build from runtime stages', $body$A multi-stage Dockerfile compiles the application in a stage that carries a full JDK and the build tooling, then copies only the finished artifact into a smaller runtime stage. The shipped image contains no compiler, no source tree, and no local build cache, which reduces both size and attack surface. Pin the builder image by an explicit version so builds do not shift underneath you when a tag moves. The same idea applies to any step that produces a file: keep it in the builder, copy the output. Rule of thumb: build with a JDK, run with a JRE, and never ship the toolchain by accident.$body$, $code$FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
COPY . .
RUN ./mvnw -q -B -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/target/app.jar app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]$code$),
    ('dockerfiles-for-java-apps', 2, 'Choose a slim runtime base image', $body$The runtime base is a trade-off between image size, supply-chain surface, and compatibility. A full distribution image is large but includes common libraries and a shell for debugging; slim variants strip much of that; distroless and Alpine images go further but can surprise you with musl libc, missing timezone data, or absent TLS roots. For most Spring Boot services a pinned slim JRE is the pragmatic default, and distroless is worth it once your team can debug without a shell. Whatever you choose, verify the pieces your application actually touches. Rule: the smaller the base, the more deliberately you must test native dependencies and certificates.$body$, $code$FROM eclipse-temurin:21-jre-jammy
RUN useradd --system --uid 1001 appuser
USER 1001
WORKDIR /app
COPY --chown=1001:0 target/app.jar /app/app.jar
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]$code$),
    ('dockerfiles-for-java-apps', 3, 'Set the user and entrypoint', $body$Containers often run as root by default, which means a process escape or a misconfiguration starts with more privilege than the workload needs. Create or select an unprivileged account and set USER inside the image, including ownership of the files the application writes, because ownership is baked in at build time. Use a numeric UID so Kubernetes can verify the identity without resolving names across images. The entrypoint should be the exec form, a JSON array, so the JVM is the process that receives signals directly. Rule: if the service does not need a privileged port, it does not need root.$body$, $code$FROM eclipse-temurin:21-jre
RUN groupadd --system --gid 1001 app \
 && useradd --system --uid 1001 --gid app app
WORKDIR /app
COPY --chown=1001:1001 target/app.jar /app/app.jar
USER 1001
ENTRYPOINT ["java", "-jar", "/app/app.jar"]$code$),
    ('docker-layer-caching-for-java', 1, 'Order steps from stable to volatile', $body$Docker reuses a cached layer only when the instruction and its inputs are unchanged, and a cache miss invalidates every later layer. In a Java build the dependency set changes far less often than source code, so copy the build descriptor first, resolve dependencies, then copy sources. A one-line code change then rebuilds only the compile and package layers instead of downloading the world again. This single ordering decision often shortens feedback loops more than any other Dockerfile change. Rule: put the most stable inputs near the top and the files you edit near the bottom.$body$, $code$FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
COPY mvnw pom.xml ./
RUN ./mvnw -q -B dependency:go-offline
COPY src ./src
RUN ./mvnw -q -B -DskipTests package$code$),
    ('docker-layer-caching-for-java', 2, 'Keep the build context small', $body$Everything in the build context is sent to the builder, so a large context slows every build and one unrelated file can invalidate a layer. A .dockerignore that excludes target output, version control metadata, logs, and local configuration keeps the context small and reviews honest. Also avoid commands whose inputs move on their own, such as resolving floating tags or downloading latest version snapshots during the build, because they make caching unpredictable and releases unreproducible. Determinism and cache friendliness come from the same discipline. Rule: if a file does not affect the running application, keep it out of the context.$body$, $code$# .dockerignore
target/
.git/
*.log
.env
.idea/$code$),
    ('docker-layer-caching-for-java', 3, 'Cache dependencies without baking them in', $body$BuildKit cache mounts keep an external cache directory between builds, so Maven or Gradle can reuse downloaded artifacts while the image layer stays clean. The mount exists only for the duration of the RUN step, so repository state never lands in a shipped layer, which keeps the image small and free of stale metadata. This speeds up laptops and CI runners that persist the cache, but a cold machine still downloads everything, so never let correctness depend on the cache. Combine the mount with explicit dependency versions. Rule: mount caches for speed, pin dependencies for correctness.$body$, $code$# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
COPY . .
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -q -B -DskipTests package$code$),
    ('jib-and-buildpack-strategies', 1, 'Build images without a Dockerfile', $body$Jib builds an image from Java project metadata, so there is no Docker daemon to reach and no Dockerfile to maintain, and the application is split into layers by how often each changes. Buildpacks take a similar position from the other side: a builder detects the project type and produces an image with sensible defaults. Both remove hand-written Docker steps and the accompanying copy mistakes, including the classic error of forgetting a jar in the final stage. The trade-off is control over arbitrary native setup and unusual filesystem layout. Rule: choose these tools when the service is a plain JVM application, not a custom build.$body$, $code$./mvnw -q -B compile jib:build \
  -Dimage=registry.example.com/acme/orders:1.4.0
./mvnw -q -B compile jib:dockerBuild \
  -Dimage=acme/orders:local
./mvnw -q -B spring-boot:build-image \
  -Dspring-boot.build-image.imageName=acme/orders:local$code$),
    ('jib-and-buildpack-strategies', 2, 'Get reproducibility from the tooling', $body$A reproducible image means that identical inputs produce an identical digest. Jib and buildpacks order layers deterministically and avoid embedding a build timestamp by default, so the same sources and dependencies give the same artifact. That property is what makes image promotion honest: the digest you tested on staging is the digest you deploy to production, with no rebuild in between. A hand-written Dockerfile can reach the same state, but you must remove variables such as embedded build dates, unpinned base images, and unstable file ordering. Rule: if the digest changes without a source change, the build is not reproducible.$body$, $code$plugins {
    id 'com.google.cloud.tools.jib' version '3.4.4'
}

jib {
    to { image = 'registry.example.com/acme/orders' }
    container { jvmFlags = ['-XX:MaxRAMPercentage=75.0'] }
}$code$),
    ('jib-and-buildpack-strategies', 3, 'Pick tooling by team constraints', $body$The right image build path is the one the team can operate repeatably. A Dockerfile is explicit and familiar, and it can express unusual steps such as native packages, code generation, or multi-binary images. Jib is quick to adopt for JVM services and needs no daemon, which matters on restricted CI runners. Buildpacks give a curated base with patched dependencies but hide part of the base image lifecycle from you. Mixing approaches across services raises operational inconsistency and doubles the knowledge needed for incident response. Rule: one default build path per organization, with written reasons for each deviation.$body$, $code$# Same project, two supported build paths.
./gradlew jib --image=registry.example.com/acme/orders:1.4.0
./gradlew bootBuildImage --imageName=acme/orders:1.4.0
# Confirm the pushed digest for the release record.
docker buildx imagetools inspect \
  registry.example.com/acme/orders:1.4.0$code$),
    ('docker-compose-for-development', 1, 'Declare local dependencies as services', $body$Compose describes the containers a developer needs, such as a database and a message broker, in one versioned file. Starting the stack becomes a single command, and the file documents image versions, ports, volumes, and environment variables instead of leaving them in a wiki page that slowly drifts. Keep the application itself out of the file when developers run it from an IDE; include it when they want to test the packaged artifact and the real entrypoint. Either way, dependencies and their versions are now reviewable. Rule: dependencies belong in Compose, application configuration belongs in the environment.$body$, $code$services:
  postgres:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: javacraft
      POSTGRES_PASSWORD: local$code$),
    ('docker-compose-for-development', 2, 'Gate startup on healthchecks', $body$depends_on controls the order in which containers are created, not whether a dependency is ready to accept connections. Without a healthcheck an application can start against a database that is still initializing and fail on the first query, which produces a flaky setup that wastes hours. Define a healthcheck for each dependency and use the long form of depends_on with the service_healthy condition, so Compose waits for a passing check before starting the next service. This removes the sleep scripts that otherwise creep into local scripts and CI. Rule: wait for health, not merely for a process to exist.$body$, $code$services:
  api:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
  postgres:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 10$code$),
    ('docker-compose-for-development', 3, 'Use profiles and keep parity honest', $body$Not every developer needs every dependency. Compose profiles let you tag optional services, such as a broker or a tracing backend, and start them only with an explicit flag, which keeps the default stack fast without deleting the configuration. The harder discipline is parity: keep image versions and configuration keys close to what production runs, because the most expensive local bug is the one that only happens against an old database or broker version. Perfect parity is not achievable, but version drift is a choice. Rule: the same image versions locally and in staging, only credentials differ.$body$, $code$services:
  rabbitmq:
    image: rabbitmq:3.13-management
    profiles: ["events"]

# docker compose --profile events up -d$code$),
    ('kubernetes-deployments-and-services', 1, 'Declare desired state with Deployments', $body$A Deployment declares how many replicas of a Pod template should run and how an upgrade should proceed. The controller creates ReplicaSets and adjusts them during a rollout, so you almost never manage Pods directly. The default strategy allows a quarter of replicas to be unavailable at a time, which is fine for fast-starting services but risky for JVMs that need tens of seconds to become ready; those services usually prefer a surge of new Pods and zero unavailability. Keep the previous ReplicaSet available so a rollback is one command. Rule: if you are editing Pods by hand, a controller is missing.$body$, $code$spec:
  replicas: 3
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
        - name: orders
          image: registry.example.com/acme/orders:1.4.0$code$),
    ('kubernetes-deployments-and-services', 2, 'Understand how rollouts actually progress', $body$When a Pod template changes, the Deployment controller creates a new ReplicaSet and scales it up while scaling the old one down within the surge and unavailability budget. A new Pod counts as available only after its readiness probe passes, so a broken readiness check stalls a rollout rather than failing it loudly, and the release sits half-applied. kubectl rollout status blocks until the rollout completes or times out, and kubectl rollout undo returns to the previous revision. Keep enough revision history to step back past the most recent bad release. Rule: readiness gates rollouts while liveness only restarts containers.$body$, $code$kubectl rollout status deployment/orders --timeout=180s
kubectl describe deployment orders | sed -n '/Events/,$p'
kubectl rollout history deployment/orders
kubectl get replicasets -l app=orders
kubectl rollout undo deployment/orders$code$),
    ('kubernetes-deployments-and-services', 3, 'Expose Pods through Services and endpoints', $body$Pod addresses change whenever a Pod is replaced, so clients should connect to a Service: a stable virtual address that selects Pods by label. ClusterIP serves in-cluster traffic, NodePort opens a fixed port on every node, and LoadBalancer asks the platform for an external address, each adding a layer of exposure you should justify. Endpoints are populated only from Pods that pass their readiness probe, which is how probe behavior becomes routing behavior. The most common reason a Service has no endpoints is a selector that does not match the Pod labels. Rule: when a Service returns nothing, compare labels before suspecting the network.$body$, $code$apiVersion: v1
kind: Service
metadata:
  name: orders
spec:
  selector:
    app: orders
  ports:
    - port: 80
      targetPort: 8080$code$),
    ('kubernetes-configmaps-and-secrets', 1, 'Inject configuration as data', $body$A ConfigMap holds non-sensitive settings as key-value data that Pods consume either as environment variables or as mounted files. Mounting gives you a directory of files, which suits Spring configuration, logging setup, and feature flags that are easier to read and diff; environment variables are simpler but are fixed for the lifetime of the Pod. Keeping configuration in manifests rather than in the image lets one built artifact run in several environments, which is what makes promotion meaningful. Review configuration changes with the same care as code. Rule: build once and configure at deploy time.$body$, $code$apiVersion: v1
kind: ConfigMap
metadata:
  name: orders-config
data:
  application.yaml: |
    server:
      port: 8080$code$),
    ('kubernetes-configmaps-and-secrets', 2, 'Handle Secrets and rotation expectations', $body$Secrets store credentials in a separate object from ordinary configuration, but they are only base64-encoded in the API and are not encrypted unless the cluster is configured to encrypt them at rest, so access control and encryption settings matter as much as the object type. Environment variables are the least flexible form, because they cannot change while the Pod runs. Mounted Secret volumes are refreshed by the kubelet, yet the application must re-read the file to notice, and many clients cache credentials at startup. Rule: decide per credential whether it can reload, or whether rotation triggers a rollout.$body$, $code$env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: orders-db
        key: password$code$),
    ('kubernetes-configmaps-and-secrets', 3, 'Make configuration immutable where possible', $body$Marking a ConfigMap or Secret immutable prevents edits that would leave running Pods with values that no longer match the manifest, and it lets the API server stop watching the object, which reduces load in large clusters. The practical pattern is versioned names, such as orders-config-v7, referenced by the Deployment, so a configuration change creates a new object and naturally triggers a rollout. Objects are deleted once nothing references them. The cost is more objects to track, which a chart or pipeline handles well. Rule: change configuration by deploying a new version, not by mutating a live one.$body$, $code$apiVersion: v1
kind: ConfigMap
metadata:
  name: orders-config-v7
immutable: true
data:
  LOG_LEVEL: info$code$),
    ('kubernetes-probes-and-health', 1, 'Match each probe to its question', $body$Liveness asks whether the process must be restarted, readiness asks whether this Pod should receive traffic, and startup asks whether a slow initialization has finished. Each probe answers a different question, and confusing them produces outages: a liveness probe that checks a database can restart every replica during a database incident and turn a degradation into an outage. Startup probes exist for slow JVMs because liveness checks are suppressed until startup succeeds, which removes the need for a guessed initial delay. Rule: liveness checks the process itself, readiness checks what the request path needs.$body$, $code$livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  periodSeconds: 10
startupProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  periodSeconds: 5
  failureThreshold: 30$code$),
    ('kubernetes-probes-and-health', 2, 'Wire Spring Boot health groups', $body$Spring Boot Actuator exposes distinct liveness and readiness groups when it detects that it runs on Kubernetes, served at /actuator/health/liveness and /actuator/health/readiness. The readiness group should include the checks that reflect the ability to serve traffic, such as a required database or a critical downstream, while the liveness group stays deliberately narrow so that transient dependency trouble does not restart Pods. You can add or exclude indicators per group in configuration. Verify the endpoint responses in a running Pod rather than assuming the groups are enabled. Rule: keep liveness boring and make readiness meaningful.$body$, $code$# application.yaml
management:
  endpoint:
    health:
      probes:
        enabled: true
      group:
        readiness:
          include: db,diskspace$code$),
    ('kubernetes-probes-and-health', 3, 'Avoid probe-triggered outages', $body$Aggressive probes are a common source of self-inflicted incidents. A timeout shorter than a garbage collection pause makes health endpoints fail under load, so Pods are restarted precisely when capacity is scarce, and a small failure threshold drains a service after a brief stall. Give probes a timeout that exceeds the pauses you actually observe, require several consecutive failures before acting, and keep health endpoints cheap by not calling heavy dependencies on every check. Measure before tuning, then revisit after a load test changes the profile. Rule: probe thresholds come from observed latency, never from intuition.$body$, $code$readinessProbe:
  httpGet: { path: /actuator/health/readiness, port: 8080 }
  timeoutSeconds: 3
  periodSeconds: 5
  failureThreshold: 3$code$),
    ('kubernetes-resource-limits-jvm', 1, 'Set requests and limits deliberately', $body$Requests tell the scheduler how much capacity a Pod needs, while limits cap what it may actually consume. CPU is compressible, so exceeding a CPU limit means throttling rather than termination. Memory is not compressible: a container that exceeds its memory limit is killed and reported as OOMKilled. Requests far below limits invite overcommit and noisy neighbors, while equal values give predictable scheduling at the cost of idle headroom. Derive both numbers from measured usage under representative load instead of copying them between services. Rule: measure first, then keep a CPU request honest and a CPU limit modest.$body$, $code$resources:
  requests:
    cpu: "500m"
    memory: "768Mi"
  limits:
    cpu: "2"
    memory: "1Gi"$code$),
    ('kubernetes-resource-limits-jvm', 2, 'Let the JVM read the container limit', $body$Modern JVMs read the container memory limit and size the heap from it, but the default maximum heap fraction is a quarter of that limit, which wastes the memory you paid for. Setting a percentage such as 75 leaves room for metaspace, thread stacks, code cache, and direct buffers, and it keeps the same image usable under different limits. Prefer a percentage over a fixed maximum heap so the image stays portable. Remember that the JVM also sizes some pools from the visible CPU count, so CPU limits influence thread counts, not just speed. Rule: express heap as a fraction of the limit and leave the remainder for non-heap memory.$body$, $code$env:
  - name: JAVA_TOOL_OPTIONS
    value: "-XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"
resources:
  limits:
    memory: "1Gi"$code$),
    ('kubernetes-resource-limits-jvm', 3, 'Debug throttling and OOM kills', $body$When a Java container is killed for memory, kubectl describe pod shows a last state with the OOMKilled reason and exit code 137, and heap dumps or application logs tell you whether the heap or the non-heap area grew. Throttling is quieter: cgroup throttling counters show that a CPU limit is too low for peak work, and latency rises without any restart. Both symptoms usually trace back to sizing decisions rather than application bugs, so check limits, heap settings, and traffic shape before optimizing code. Rule: establish whether the Pod was killed or throttled before you change anything.$body$, $code$kubectl describe pod orders-7d9f8c6b5-x2k4p | grep -A3 "Last State"
kubectl top pod orders-7d9f8c6b5-x2k4p --containers
kubectl get pod orders-7d9f8c6b5-x2k4p \
  -o jsonpath='{.status.containerStatuses[0].restartCount}'
kubectl logs orders-7d9f8c6b5-x2k4p --previous --tail=50$code$),
    ('kubernetes-hpa-scaling', 1, 'Horizontal Pod Autoscaler essentials', $body$The horizontal pod autoscaler compares observed metrics with a target and periodically adjusts the replica count of a scalable workload. CPU utilization is expressed as a percentage of the requested CPU, so missing or unrealistic requests make the calculation meaningless. The controller needs a metrics source, commonly the metrics server for resource metrics, and it can also consume custom or external metrics when resource signals are a poor proxy for load. Scaling is not instant: the control loop runs on an interval and changes propagate through the Deployment. Rule: define honest requests before configuring a utilization target.$body$, $code$apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: orders
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: orders
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource: { name: cpu, target: { type: Utilization, averageUtilization: 70 } }$code$),
    ('kubernetes-hpa-scaling', 2, 'Account for JVM warmup time', $body$A new Java Pod does not serve at steady-state speed the moment it becomes ready. Class loading, just-in-time compilation, and cache warmup take time, so scaling out during a latency spike adds capacity slowly while the load keeps landing on Pods that are already saturated. Mitigate with a realistic minimum replica count, warmup-aware readiness settings, and, for latency-sensitive services, a small standing pool rather than scaling from zero. You can also damp rapid fluctuation with scaling behavior rules. Rule: treat warmup time as part of provisioning whenever you size an autoscaler.$body$, $code$behavior:
  scaleUp:
    stabilizationWindowSeconds: 30
    policies:
      - type: Percent
        value: 100
        periodSeconds: 30$code$),
    ('kubernetes-hpa-scaling', 3, 'Balance scale-up latency against provisioning', $body$Replicas are one layer of capacity and nodes are another. If the cluster has no free room, new Pods stay Pending until a node autoscaler provisions machines, which can take minutes and can fail when quotas or instance limits are reached. That makes the maximum replica count a promise about capacity that must be backed by node headroom or a fast provisioning path. Pending Pods are the visible symptom, and their events usually name the missing resource, such as insufficient CPU. Rule: test the whole scale-out path, not just the autoscaler object.$body$, $code$kubectl get hpa orders -o wide
kubectl describe hpa orders | sed -n '/Events/,$p'
kubectl get pods -l app=orders --field-selector=status.phase=Pending
kubectl describe pod orders-5f7b9c8d4f-abcde | sed -n '/Events/,$p'
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu$code$),
    ('kubernetes-jobs-and-cronjobs', 1, 'Run finite work with Jobs', $body$A Job runs Pods until a required number of them complete successfully, retrying failures up to the backoff limit. Because completion is the goal, the restart policy is Never or OnFailure rather than Always, and a Job that repeatedly fails eventually stops retrying, which is easier to alert on than a crash loop that never ends. Use completions and parallelism for batch fan-out, an active deadline to bound a stuck run, and a time-to-live to let finished Jobs be cleaned up. Batch Pods usually need different resources than web Pods. Rule: if the work must end, model it as a Job.$body$, $code$apiVersion: batch/v1
kind: Job
metadata:
  name: invoice-run
spec:
  backoffLimit: 3
  activeDeadlineSeconds: 1800
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: runner
          image: registry.example.com/acme/orders:1.4.0$code$),
    ('kubernetes-jobs-and-cronjobs', 2, 'Schedule recurring work with CronJobs', $body$A CronJob creates Jobs on a schedule written in cron syntax, which suits nightly imports, reconciliation, and cleanup. Concurrency is the first thing to control, because the default policy permits overlapping runs and teams are usually surprised to learn that a slow job can meet its next invocation. Choose Forbid or Replace for work that must not overlap, bound each run with an active deadline, and consider a starting deadline so a missed schedule is skipped rather than executed late. Decide the behavior explicitly. Rule: settle overlap and lateness policy before the first production schedule.$body$, $code$apiVersion: batch/v1
kind: CronJob
metadata: { name: nightly-reconcile }
spec:
  schedule: "0 2 * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: reconcile
              image: registry.example.com/acme/orders:1.4.0$code$),
    ('kubernetes-jobs-and-cronjobs', 3, 'Make scheduled jobs idempotent', $body$A scheduled job can run more than once for the same period: a retried attempt after a partial failure, a catch-up run after a controller restart, or two runs that overlap despite a policy. Business logic should therefore be safe to repeat, which usually means a unique business key and an upsert, or a claim row that records which period was already processed. Prefer short transactions per item over one long transaction that holds locks while the job runs. Log a run identifier so a duplicate can be traced later. Rule: assume every scheduled job executes at least once, and design for it.$body$, $code$INSERT INTO processed_period (job_name, period_start)
VALUES (:job, :period)
ON CONFLICT (job_name, period_start) DO NOTHING
RETURNING period_start;
-- A returned row means this run owns the period;
-- no row means another run already claimed it.$code$),
    ('helm-basics-for-java-services', 1, 'Package manifests as versioned charts', $body$A Helm chart groups templates, default values, and metadata into a versioned artifact that can be installed, upgraded, and rolled back as one unit. For a Java service that means the Deployment, Service, configuration objects, and probe settings travel together, and every environment starts from the same package with different values layered on top. Chart version and application version are separate fields, so packaging can change without pretending the application did. Treat charts as code: review them, lint them, render them in CI, and publish them to a registry. Rule: one chart per service, one release per environment.$body$, $code$helm create orders
helm lint ./orders
helm template orders ./orders -f values-staging.yaml >/dev/null
helm upgrade --install orders ./orders -f values-staging.yaml
kubectl get deploy orders -o jsonpath='{.spec.replicas}'$code$),
    ('helm-basics-for-java-services', 2, 'Control environments through values', $body$Templates render from values, and values files let staging and production differ in replica count, resources, image tag, and feature flags without forking the chart. Precedence is predictable: chart defaults, then files passed on the command line, then individual overrides, and finally whatever the pipeline supplies. Keep environment values in version control so a change is reviewable, and never store secrets there in plain text. Use the required helper in templates so a missing critical value fails rendering instead of producing a manifest that quietly runs with an empty setting. Rule: defaults live in the chart, environment specifics live in values.$body$, $code$replicaCount: 3
image:
  repository: registry.example.com/acme/orders
  tag: "1.4.0"
resources:
  requests: { cpu: 500m, memory: 768Mi }
  limits: { memory: 1Gi }$code$),
    ('helm-basics-for-java-services', 3, 'Upgrade and roll back releases safely', $body$An upgrade renders new manifests, applies them, and records a revision; when the result is broken, a rollback restores the previous revision. Because Helm delegates to the Kubernetes API, a rollout that never becomes ready leaves the release in a failed state, and the atomic option can roll back automatically on timeout, which is worth enabling for progressive environments. The important caveat is that rollback restores manifests, not data: persistent volumes and custom resources may keep state from the failed release. Know which parts of the release are stateless. Rule: rehearse the rollback path before you need it under pressure.$body$, $code$helm history orders
helm upgrade orders ./orders -f values-prod.yaml --atomic --timeout 5m
helm status orders
helm get values orders
helm rollback orders 12$code$),
    ('kubernetes-operators-overview', 1, 'Extend the API with custom resources', $body$A custom resource definition adds a new kind to the Kubernetes API, and objects of that kind become ordinary API objects with validation, access control, and command-line support. For a Java team a custom resource can express a domain concept such as a tenant, a stream, or a pipeline, which turns platform operations into declarative configuration instead of a runbook. The definition stores data and enforces a schema; it does nothing on its own. Prefer a custom resource when the concept is genuinely new, not when a ConfigMap or an existing built-in resource already models it. Rule: a new API object needs an owner, a schema, and a lifecycle.$body$, $code$apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata: { name: tenants.platform.example.com }
spec:
  group: platform.example.com
  scope: Namespaced
  names: { kind: Tenant, plural: tenants, singular: tenant }
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema: { type: object }$code$),
    ('kubernetes-operators-overview', 2, 'Reconcile toward desired state', $body$An operator is a controller that watches custom resources and drives the cluster toward the state they describe. It reads the specification, observes the real objects, and makes the smallest change needed, then repeats forever. This loop tolerates restarts and partial failures because it is level-based rather than step-based: it does not matter how the cluster reached its current shape, only what it looks like now. Status conditions report progress back to the user, which is what makes the resource debuggable. Rule: write convergence logic, not a one-shot provisioning script.$body$, $code$void reconcile(Tenant tenant) {
    if (isReady(tenant)) {
        return; // already converged
    }
    ensureDeployment(tenant);
    ensureService(tenant);
    markReady(tenant);
}$code$),
    ('kubernetes-operators-overview', 3, 'Choose a controller over a script', $body$A deployment script runs once and must handle retries, drift, and partial failure by itself; a controller keeps running and repairs drift without being told. That property is the reason to accept the extra complexity of an operator, and it is also the reason not to adopt one casually: an operator is a service you must build, test, upgrade, and operate, and a bad release can damage every resource it manages. If the work is a fixed sequence of API calls, a chart hook or a pipeline job is the better tool. Rule: adopt an operator when continuous reconciliation is the requirement, not merely automation.$body$, $code$# A fixed sequence of API calls: a pipeline or chart hook is enough.
kubectl apply -f namespace.yaml
kubectl apply -f database.yaml

# Ongoing convergence and drift repair for user-created resources:
kubectl apply -f tenant-acme.yaml$code$),
    ('service-mesh-essentials', 1, 'Understand the sidecar model', $body$A service mesh puts cross-cutting traffic concerns into a data plane instead of into each application. In the sidecar model every Pod runs a proxy that intercepts inbound and outbound traffic, so the application still speaks plain HTTP while the mesh performs mutual TLS, retries, timeouts, and traffic shifting. The proxy is transparent to code but consumes CPU and memory per Pod and adds a network hop, which shows up as latency and cost multiplied by the fleet. That overhead is often justified when many services need uniform security and routing. Rule: count the per-Pod cost before enabling the sidecar everywhere.$body$, $code$# Label a namespace so the mesh injects sidecars automatically.
kubectl label namespace orders istio-injection=enabled
kubectl rollout restart deployment/orders -n orders
kubectl get pods -n orders
kubectl describe pod -n orders -l app=orders | grep -i istio$code$),
    ('service-mesh-essentials', 2, 'Know what the mesh provides', $body$The practical benefits are consistent mutual TLS between workloads, standardized retries and timeouts, fine-grained traffic routing for canaries, and uniform telemetry without changes to application code. These features matter because they are easy to implement incorrectly once per service and nearly impossible to audit across dozens of them. The mesh helps only when its configuration matches application semantics: retries must respect idempotency, and mesh timeouts must be narrower than the caller budget, or you will retry work that should have failed fast. Rule: tune mesh policy with the same service-level reasoning you apply to your own code.$body$, $code$apiVersion: networking.istio.io/v1
kind: VirtualService
metadata: { name: orders }
spec:
  hosts: [orders]
  http:
    - route:
        - destination: { host: orders, subset: v1 }
          weight: 90
        - destination: { host: orders, subset: v2 }
          weight: 10$code$),
    ('service-mesh-essentials', 3, 'Weigh operational cost and alternatives', $body$A mesh adds components to install, upgrade, and debug, and it becomes part of the critical path for every request, so when its control plane or data plane misbehaves the symptoms look like application bugs and the investigation spans two teams. Sidecar-less designs reduce per-Pod overhead by moving proxying to a shared layer, though they arrive with their own maturity and feature limits. A cheaper alternative for many teams is a well-configured ingress plus careful client libraries for retries and timeouts. Rule: adopt a mesh for fleet-wide policy consistency, not to obtain a single feature.$body$, $code$kubectl get pods -n istio-system
kubectl get peerauthentication -A
kubectl get telemetry -A
istioctl proxy-status
istioctl analyze -n orders$code$),
    ('container-image-security', 1, 'Start from a minimal base', $body$Every package in the base image is code you ship and must patch. Slim JRE images remove compilers and build tools; distroless images go further and remove the package manager and shell, leaving the runtime, certificates, and little else. Fewer components mean fewer known vulnerabilities and a smaller surface for anyone who reaches the container. The cost is diagnosability, because without a shell you need an ephemeral debug container, and you must confirm that timezone data, TLS roots, and any native libraries your service needs are present. Rule: ship the smallest image your team can still debug in an incident.$body$, $code$FROM gcr.io/distroless/java21-debian12:nonroot
COPY target/app.jar /app/app.jar
USER nonroot
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
# Runs with no shell or package manager in the image.$code$),
    ('container-image-security', 2, 'Scan and gate in continuous integration', $body$Scanning an image in the pipeline turns vulnerability data into a build signal instead of a periodic report nobody reads. Run a scanner against the built image, fail on fixable critical findings, and publish the full report as an artifact so the release record shows what was known at build time. Scanning the base image alone is insufficient because your own dependencies contribute findings, while scanning the final image catches both. Keep an explicit policy for findings with no available fix. Rule: the scan result belongs to the exact artifact that gets deployed.$body$, $code$trivy image --severity CRITICAL --exit-code 1 \
  --ignore-unfixed \
  -o report.json \
  registry.example.com/acme/orders:1.4.0
jq '.Results[].Vulnerabilities | length' report.json$code$),
    ('container-image-security', 3, 'Verify provenance at admission', $body$Signing an image lets a cluster-side policy verify that the artifact came from your pipeline before it is allowed to run. Admission controllers such as Kyverno or Gatekeeper can then reject unsigned images or images from unexpected registries, which blocks a common supply-chain path where a compromised credential pushes a rogue image that looks legitimate. The gate must have an audited break-glass path so a real incident response is not blocked by policy. Signing identity matters: verify the workflow and issuer, not only that a signature exists. Rule: verify provenance in the cluster, not only in the pipeline.$body$, $code$cosign sign --key cosign.key registry.example.com/acme/orders:1.4.0
cosign verify \
  --certificate-identity-regexp 'https://github.com/acme/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  registry.example.com/acme/orders:1.4.0$code$),
    ('container-registries-and-supply-chain', 1, 'Pick a registry with the right controls', $body$Managed registries differ in access control, replication, retention, and scanning integration, but the differences that hurt day to day are authentication and retention. Developers need one documented login path that works on laptops and in CI, because a registry nobody can pull from produces a queue of exceptions rather than a security win. Retention rules must never delete images referenced by running workloads, which means aligning cleanup with deployment history. Choose the registry your deployment platform and CI already trust rather than adding a second trust relationship. Rule: automate credentials, and write down the retention policy.$body$, $code$docker login registry.example.com \
  -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
docker tag acme/orders:local registry.example.com/acme/orders:1.4.0
docker push registry.example.com/acme/orders:1.4.0
skopeo list-tags docker://registry.example.com/acme/orders
docker logout registry.example.com$code$),
    ('container-registries-and-supply-chain', 2, 'Prefer immutable digests over tags', $body$A tag is a mutable pointer that anyone with push access can move, so a Deployment that references a tag can silently start different code after an unrelated push. A digest identifies exact content, which makes rollbacks, audits, and incident forensics unambiguous. Many registries support immutable tags to block overwrites, and a Deployment can reference an image by digest directly. Tags remain useful for humans, but the digest is what you deploy and what you record next to the version in the release notes. Rule: resolve the tag once, then deploy and record the digest.$body$, $code$# Resolve the tag once, then deploy the digest.
docker buildx imagetools inspect registry.example.com/acme/orders:1.4.0
kubectl set image deployment/orders \
  orders=registry.example.com/acme/orders@sha256:9f2c4a1b7e3d8c5f
kubectl rollout status deployment/orders$code$),
    ('container-registries-and-supply-chain', 3, 'Attach an SBOM to the release', $body$A software bill of materials lists the components inside an image, which is exactly what you need when a new vulnerability is announced and someone asks whether you are affected. Generate it in the pipeline from the final image, attach it to the artifact, and store it somewhere queryable rather than in a build log that expires. Keeping the bill of materials next to the digest means the question is answered by lookup, not by rebuilding the image and hoping the result matches. Rule: if you cannot list your components within minutes, incident response will take days.$body$, $code$syft registry.example.com/acme/orders:1.4.0 \
  -o spdx-json=orders-1.4.0.spdx.json
cosign attach sbom --sbom orders-1.4.0.spdx.json \
  registry.example.com/acme/orders:1.4.0
cosign verify-attestation --type spdxjson \
  registry.example.com/acme/orders:1.4.0$code$),
    ('graceful-shutdown-in-containers', 1, 'Handle SIGTERM in the application', $body$When Kubernetes deletes a Pod, the kubelet sends SIGTERM to the process and then waits for the termination grace period, thirty seconds by default, before sending SIGKILL. A Java process that ignores SIGTERM is killed mid-request, which shows up as connection resets and failed writes. Spring Boot supports graceful shutdown through the server shutdown property, which stops accepting new requests and lets active ones finish within a configurable timeout. Anything outside the web server, such as a message consumer or a scheduled task, needs its own drain logic. Rule: make the shutdown path an explicit feature rather than an accident.$body$, $code$server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 20s
# terminationGracePeriodSeconds must exceed this timeout.$code$),
    ('graceful-shutdown-in-containers', 2, 'Delay the signal with a preStop hook', $body$Removing a terminating Pod from Service endpoints and sending SIGTERM happen concurrently, so for a short window the Pod can still be listed as a routing destination while its process is already shutting down. Traffic that arrives in that window is refused or dropped. A small sleep in a preStop hook lets endpoint propagation finish before the application begins to close, which removes most of those errors for a trivial cost. Keep the sleep short and count it inside the grace period, because total shutdown time is the hook plus the graceful phase. Rule: sleep in preStop, drain in the application.$body$, $code$lifecycle:
  preStop:
    exec:
      command: ["sh", "-c", "sleep 8"]
terminationGracePeriodSeconds: 40$code$),
    ('graceful-shutdown-in-containers', 3, 'Order shutdown by dependency', $body$Closing resources in the wrong order turns a clean stop into a burst of errors. Stop intake first, let in-flight requests finish, then stop consumers, then release connection pools, and finally flush telemetry. Spring manages the web server, and shutdown hooks or lifecycle beans close the rest, but the sequence has to be intentional rather than whatever the container happens to stop in. An in-flight transaction that loses its pool mid-commit is worse than a shutdown that takes a few seconds longer. Verify the order with a load test that terminates Pods. Rule: stop the work before releasing what the work depends on.$body$, $code$@Component
class ShutdownSteps implements SmartLifecycle {
    public void stop(Runnable callback) {
        intake.stop();
        consumers.drain(Duration.ofSeconds(10));
        pools.closeIdleConnections();
        callback.run();
    }
}$code$)
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
    'dockerfiles-for-java-apps', 'docker-layer-caching-for-java',
    'jib-and-buildpack-strategies', 'docker-compose-for-development',
    'kubernetes-deployments-and-services', 'kubernetes-configmaps-and-secrets',
    'kubernetes-probes-and-health', 'kubernetes-resource-limits-jvm',
    'kubernetes-hpa-scaling', 'kubernetes-jobs-and-cronjobs',
    'helm-basics-for-java-services', 'kubernetes-operators-overview',
    'service-mesh-essentials', 'container-image-security',
    'container-registries-and-supply-chain', 'graceful-shutdown-in-containers'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
