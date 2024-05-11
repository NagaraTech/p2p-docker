# ===============================================================================
# Stage 1: Build Rust application
FROM rust:bookworm AS rust-builder
RUN apt-get update && apt-get install -y protobuf-compiler build-essential pkg-config libpq-dev openssl && apt clean
WORKDIR /app
COPY ./chronos .
RUN cargo build -p Zchronod

# ===============================================================================
# Stage 2: Build Go application
FROM golang:bookworm AS go-builder
WORKDIR /app
COPY ./znet .
RUN go build

# ===============================================================================
# Stage 3: Final Image
FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends openssl postgresql postgresql-contrib \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the compiled binaries from the previous stages
COPY --from=rust-builder /app/target/debug/Zchronod .
COPY --from=go-builder /app/znet .

COPY config-tempelete.yaml .

# Expose p2p and ws ports for your applications
EXPOSE 23333
EXPOSE 33333

USER postgres
RUN /etc/init.d/postgresql start \
    && psql -c "ALTER USER postgres WITH PASSWORD 'hetu';" \
    && createdb -O postgres vlc_inner_db

USER root

COPY start_services.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_services.sh
CMD ["/usr/local/bin/start_services.sh"]
