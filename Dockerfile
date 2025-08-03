FROM alpine:latest as libgmpris-fetcher
RUN apk add --no-cache wget
ENV LIBGMPRIS_VERSION="2.2.1-12"
ENV LIBGMPRIS="libgmpris_${LIBGMPRIS_VERSION}_amd64.deb"
RUN wget -O /tmp/libgmpris.deb "https://www.sonarnerd.net/src/noble/${LIBGMPRIS}"
################################################################################
FROM alpine:latest as hqplayerd-fetcher
RUN apk add --no-cache wget
ENV HQPLAYERD_VERSION="5.14.0-40"
ENV HQPLAYERD="hqplayerd_${HQPLAYERD_VERSION}_amd64.deb"
RUN wget -O /tmp/hqplayerd.deb "https://www.signalyst.eu/bins/hqplayerd/noble/${HQPLAYERD}"
################################################################################
FROM alpine:latest as libgupnp-fetcher
RUN apk add --no-cache wget
ENV LIBGUPNP_VERSION=1.6.6-2
ENV LIBGUPNP="libgupnp-1.6-0_${LIBGUPNP_VERSION}_amd64.deb"
RUN wget -O /tmp/libgupnp.deb "https://www.sonarnerd.net/src/noble/${LIBGUPNP}"
################################################################################
FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
    gnupg2 \
    libnuma-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd render
RUN mkdir -p /etc/udev/rules.d
RUN mkdir -p /etc/sudoers.d/

COPY --from=libgmpris-fetcher /tmp/libgmpris.deb /tmp/libgmpris.deb
COPY --from=hqplayerd-fetcher /tmp/hqplayerd.deb /tmp/hqplayerd.deb
COPY --from=libgupnp-fetcher /tmp/libgupnp.deb /tmp/libgupnp.deb
RUN apt-get update && apt-get install --no-install-recommends -y \
    /tmp/libgmpris.deb \
    /tmp/hqplayerd.deb \
    /tmp/libgupnp.deb \
    && rm /tmp/hqplayerd.deb \
    && rm /tmp/libgmpris.deb \
    && rm /tmp/libgupnp.deb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove \
    && apt-get clean

# run
RUN hqplayerd -s hqplayer hqplayer
ENV HOME="/mnt/user/appdata/hqplayerd/home"
ENTRYPOINT ["/usr/bin/hqplayerd"]
