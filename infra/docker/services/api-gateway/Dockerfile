# Spring Cloud Gateway — та же схема упаковки, что и у backend-микросервисов (Spring Boot + JAR).
# Соберите gateway.jar в проекте API Gateway и:
#   docker build -f infra/docker/services/api-gateway/Dockerfile \
#     --build-arg JAR_FILE=build/libs/api-gateway-0.0.1-SNAPSHOT.jar -t api-gateway:local .
#
# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jre-alpine AS runtime

RUN apk add --no-cache curl \
    && addgroup -S app && adduser -S app -G app

WORKDIR /app

ARG JAR_FILE=gateway.jar
COPY ${JAR_FILE} /app/gateway.jar

USER app

EXPOSE 8080

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/gateway.jar"]
