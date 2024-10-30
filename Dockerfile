FROM ubuntu:22.04 AS builder
ARG TARGETOS TARGETARCH
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/bin:/usr/local/cargo/bin:$PATH 
WORKDIR /app
COPY ./rust-toolchain.toml .
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
        libc6-dev \
        curl \
        git \
        pkg-config \
        libssl-dev \
        llvm \
        libclang-dev \
        clang \
        make \
        cmake \
        unzip \
        # remove once tari deps will be cleaned out
        libsqlite3-dev \
        libprotobuf-dev \
        protobuf-compiler \
        libc++-dev \
        libc++abi-dev \
        libncurses5-dev \
        libncursesw5-dev \
        openssl \
        # remove once tari deps will be cleaned out
        ; \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path && \
    rustup --version; \
    cargo --version; \
    rustc --version;
SHELL ["/bin/bash", "-c"]
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/app/target \
    cargo build --release && \
    find ./target/release/ -maxdepth 1 -type f -executable -exec cp {} /usr/local/bin/ \;

FROM debian:unstable-slim
COPY --from=builder /usr/local/bin /usr/local/bin
RUN apt-get update && apt-get -y upgrade && apt-get install -y libssl-dev ca-certificates \
  && chmod -R a+x /usr/local/bin
CMD ["/usr/local/bin/randomxtest"]
