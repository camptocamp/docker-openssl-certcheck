FROM debian:stretch-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
 && apt-get -y install openssl socat \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY check_certs.sh /

VOLUME /certs

EXPOSE 9100

ENTRYPOINT socat -T 1 -d -d tcp-l:9100,reuseaddr,fork system:"/check_certs.sh /certs"
