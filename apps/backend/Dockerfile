# syntax=docker/dockerfile:1.7

FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /workspace

COPY pom.xml ./
RUN mvn dependency:resolve -DskipTests

COPY src src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-jammy

RUN apt-get update \
    && apt-get install --no-install-recommends -y curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /workspace/target/badbook-*.jar app.jar

RUN useradd --system --uid 10001 badbook \
    && chown -R badbook:badbook /app

USER badbook
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
  CMD curl --fail --silent http://localhost:8080/badbook/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
