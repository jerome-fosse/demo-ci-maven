#!/bin/sh
exec java ${JAVA_OPTS} -noverify -XX:+AlwaysPreTouch -Djava.security.egd=file:/dev/./urandom -cp /opt/app/application.properties/:/opt/app/demo-ci-maven.jar "com.example.demo.DemoApplication"  "$@"