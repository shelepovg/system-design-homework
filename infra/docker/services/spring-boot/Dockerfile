# Универсальный образ для Spring Boot 3: User, Request Processing, Payment, Notification, Audit.
# Сборка JAR в репозитории сервиса (./mvnw -DskipTests package или ./gradlew bootJar),
# затем из каталога с артефактом:
#   docker build -f path/to/infra/docker/services/spring-boot/Dockerfile \
#     --build-arg JAR_FILE=target/user-service-0.0.1-SNAPSHOT.jar -t user-service:local .
#
# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jre-alpine AS runtime

RUN apk add --no-cache curl \
    && addgroup -S app && adduser -S app -G app

WORKDIR /app

ARG JAR_FILE=application.jar
COPY ${JAR_FILE} /app/application.jar

USER app

EXPOSE 8080

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/application.jar"]
