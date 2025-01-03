FROM alpine:latest

WORKDIR /

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache git openjdk17 curl docker openrc openssh-client

RUN rc-update add docker boot

COPY *.sh /
COPY BlankProject/ /BlankProject/

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
