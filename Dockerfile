FROM golang:1.14-stretch AS build
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

FROM gcr.io/distroless/base
LABEL maintainer Delta Projects
COPY --from=build /go/bin/varnishlogbeat /
COPY --from=build /go/src/github.com/phenomenes/varnishlogbeat/varnishlogbeat.template* /etc/varnishlogbeat/
COPY --from=build /go/src/github.com/phenomenes/varnishlogbeat/varnishlogbeat*yml /etc/varnishlogbeat/
COPY --from=build /usr/lib/libvarnishapi.so* /usr/lib/
COPY --from=build /lib/x86_64-linux-gnu/libpcre.so.* /lib/x86_64-linux-gnu/
CMD ["/varnishlogbeat", "-path.config", "/etc/varnishlogbeat", "-c", "/etc/varnishlogbeat/varnishlogbeat.yml", "-e"]
