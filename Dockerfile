# Azeroth Survivors: the wasm client built by scripts/web-build.sh, served by wenilla-host.
# The game data (MPQs) is NOT in this image: mount it at /data (see docker-compose.yml).

FROM rust:1.98.1-bookworm AS build
RUN apt-get update \
 && apt-get install -y --no-install-recommends brotli gzip unzip curl ca-certificates xz-utils \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
RUN bash scripts/web-setup.sh \
 && bash scripts/web-build.sh \
 && cargo build --release -p wenilla-host

FROM debian:bookworm-slim
RUN useradd --system --uid 10001 --no-create-home game
WORKDIR /app
COPY --from=build /src/target/release/wenilla-host /app/wenilla-host
COPY --from=build /src/web/dist /app/dist
USER game
EXPOSE 8090
ENTRYPOINT ["/app/wenilla-host", "--bind", "0.0.0.0:8090", "--www", "/app/dist", "--data", "/data"]
