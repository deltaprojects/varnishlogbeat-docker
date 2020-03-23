FROM golang:1.11-stretch AS build
LABEL maintainer Delta Projects
ENV DEBIAN_FRONTEND noninteractive
ENV VER 6.4

RUN /bin/bash -c \
  'curl -s https://packagecloud.io/install/repositories/varnishcache/varnish${VER/./}/script.deb.sh | /bin/bash' \
  && apt-get install -y \
  libjemalloc1 \
  pkg-config \
  varnish \
  varnish-dev

RUN go get github.com/phenomenes/varnishlogbeat

FROM scratch
LABEL maintainer Delta Projects
COPY --from=build /go/bin/varnishlogbeat /
CMD ["/varnishlogbeat", "-c", "/etc/varnishlogbeat/varnishlogbeat.yml", "-e"]
