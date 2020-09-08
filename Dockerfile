FROM maven:3.6.3-openjdk-14 as build

LABEL stage=build

ARG MAVEN_USERNAME=jfosse
ARG MAVEN_PASSWORD=password

COPY . /tmp/

RUN mvn -f /tmp/pom.xml --settings /tmp/.mvn/settings.xml -Dmaven.repo.local=/tmp/.m2/repository clean verify



FROM openjdk:14-jdk-alpine

COPY --from=build /tmp/target/demo-ci-maven*.jar /opt/app/demo-ci-maven.jar
COPY src/main/resources/application.properties /opt/app/application.properties
COPY src/main/scripts/entrypoint.sh /opt/app/entrypoint.sh

RUN chmod +x /opt/app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "/opt/app/entrypoint.sh"]
