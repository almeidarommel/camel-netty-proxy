FROM openjdk:11 AS build
WORKDIR /build
COPY mvnw pom.xml ./
COPY .mvn ./.mvn/
USER 1001
RUN ./mvnw -e -U -B -q -Dmaven.test.failure.ignore=true -Dsurefire.failIfTimeout=false dependency:go-offline
COPY src src
RUN ./mvnw -e -B -q -Dmaven.test.failure.ignore=true -Dsurefire.failIfTimeout=false package -Dtarget=camel-netty-proxy
RUN ./mvnw -e -B -q -Dmaven.test.failure.ignore=true -Dsurefire.failIfTimeout=false package dependency:copy-dependencies

FROM openjdk:11-jre
WORKDIR /app
VOLUME /tmp
EXPOSE 8080
ARG TARGET=/build/target
COPY --from=build ${TARGET}/dependency lib
COPY --from=build ${TARGET}/camel-netty-proxy.jar .
ENTRYPOINT ["java", "-cp", "camel-netty-proxy.jar:lib/*", "com.github.zregvart.cnp.ProxyApp"]

