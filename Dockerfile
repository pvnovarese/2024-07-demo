FROM cgr.dev/chainguard/maven:latest AS build

WORKDIR /home/build
COPY src pom.xml ./
RUN set -ex && \
    mvn install


FROM busybox:latest
COPY --from=build /home/build/target/hello-world-maven-0.1.0.jar /

#RUN set -ex && \
#    echo "-----BEGIN OPENSSH PRIVATE KEY-----" > /ssh_key && \
#    echo "aws_access_key_id=01234567890123456789" > /aws_access && \
#    date > /image_build_timestamp
#ENTRYPOINT /bin/false
