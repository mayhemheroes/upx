# Build Stage:

FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y gcc make git g++ curl autoconf automake gettext zlib1g-dev

## Add Source Code
ADD . /upx


WORKDIR ~/
## Build Step
RUN curl https://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz --output ~/ucl-1.03.tar.gz
RUN tar -xvzf ~/ucl-1.03.tar.gz
RUN cd ucl-1.03 && ./configure CC="gcc -std=gnu89" && make CC="gcc -std=gnu89" && make install
ENV UPX_UCLDIR ~/ucl-1.03

WORKDIR /upx
RUN git submodule update --init --recursive
RUN rm -rf ./tests
RUN make all

# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
RUN apt-get update && apt-get install -y zlib1g-dev
RUN mkdir /testsuite
RUN cp /bin/cat /testsuite/cat

COPY --from=builder /upx/src/upx.out /upx
