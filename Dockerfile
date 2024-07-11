FROM docker.io/redhat/ubi9-minimal:latest AS build

USER root
COPY src pom.xml /
# use date to force a unique build every time
RUN set -ex && \
    microdnf install -y maven && \
    mvn package

FROM docker.io/redhat/ubi9-minimal:latest
COPY --from=build /target/hello-world-maven-0.1.0.jar /

RUN set -ex && \
    echo "-----BEGIN OPENSSH PRIVATE KEY-----" > /ssh_key && \
    echo "aws_access_key_id=01234567890123456789" > /aws_access && \
    date > /image_build_timestamp
ENTRYPOINT /bin/false
