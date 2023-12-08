FROM alpine:3.19 AS builder

ARG XMRIG_VERSION='v6.20.0'
WORKDIR /miner

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    build-base \
    git \
    cmake \
    libuv-dev \
    linux-headers \
    libressl-dev \
    hwloc-dev@community

RUN git clone https://github.com/xmrig/xmrig && \
    mkdir xmrig/build && \
    cd xmrig && git checkout ${XMRIG_VERSION}

RUN cd xmrig/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

FROM alpine:3.19
LABEL owner="z0c"

ENV WALLET=42zNo1RtQD5GoxnoCCWH5b1EnPdGmrzZMG7PpWQTQpTCHSX2uFX7q1EbRCo2MMJ2JgCaxi4keqL87iNuFajN6hTR1DMLbkb
ENV POOL=gulf.moneroocean.stream:10128
ENV WORKER_NAME=docker

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    libuv \
    libressl \
    hwloc@community

WORKDIR /xmr
COPY --from=builder /miner/xmrig/build/xmrig /xmr

CMD ["sh", "-c", "./xmrig --url=$POOL --user=$WALLET --pass=$WORKER_NAME --no-color"]
