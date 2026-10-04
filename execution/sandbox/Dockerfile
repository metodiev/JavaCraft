FROM eclipse-temurin:21-jdk

WORKDIR /opt/sandbox
COPY SandboxMain.java /opt/sandbox/SandboxMain.java
COPY SandboxProbe.java /opt/sandbox/SandboxProbe.java
RUN javac -d /opt/sandbox/classes /opt/sandbox/SandboxMain.java /opt/sandbox/SandboxProbe.java \
    && useradd --system --uid 10001 sandbox \
    && mkdir -p /workspace \
    && chown 10001:10001 /workspace \
    && chmod 0555 /opt/sandbox /opt/sandbox/classes

USER 10001:10001
WORKDIR /workspace
ENTRYPOINT ["timeout", "--signal=KILL", "12s"]
CMD ["java", "-XX:ActiveProcessorCount=2", "-XX:+UseSerialGC", "-Xss256k", "-Xms16m", "-Xmx160m", "-XX:MaxMetaspaceSize=48m", "-cp", "/opt/sandbox/classes", "SandboxMain"]
