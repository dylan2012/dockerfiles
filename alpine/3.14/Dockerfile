FROM alpine:3.14
MAINTAINER Dylan
ENV TERM=linux
RUN /bin/sh -c set -x && apk upgrade --update --no-cache && apk add --update --no-cache bash curl ca-certificates openssl curl tar iproute2 && rm -rf /var/cache/apk/*