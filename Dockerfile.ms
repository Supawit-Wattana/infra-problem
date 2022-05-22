FROM clojure:openjdk-8-lein-slim-buster AS BUILD

ARG APP_DIR
# ENV APP_DIR=$APP_DIR

WORKDIR /app

COPY /$APP_DIR /app/$APP_DIR

COPY /common-utils /app/common-utils
 
RUN cd /app/common-utils && lein install
RUN cd /app/$APP_DIR && lein uberjar

FROM openjdk:8-jre-slim

ARG APP_DIR

WORKDIR /app

COPY --from=BUILD /app/$APP_DIR/target/uberjar/*-standalone.jar ./app.jar

CMD ["java", "-XX:+UseContainerSupport", "-jar", "app.jar"]