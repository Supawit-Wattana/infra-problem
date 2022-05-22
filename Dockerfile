FROM openjdk:8-jre-slim

ARG APP_DIR

WORKDIR /app

COPY /build/$APP_DIR.jar ./app.jar

CMD ["java", "-jar", "app.jar"]