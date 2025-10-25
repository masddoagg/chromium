FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV DECODE_THREADS=8

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl xvfb fluxbox chromium-browser supervisor net-tools procps \
    build-essential ca-certificates sudo python3 python3-pip jq \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install KasmVNC (try release; fallback to skip if unavailable)
RUN set -eux; \
    KASM_DEB=$(mktemp); \
    wget -O "$KASM_DEB" "https://github.com/kasmtech/KasmVNC/releases/latest/download/kasmvncserver_1.3.0_amd64.deb" || true; \
    if [ -f "$KASM_DEB" ]; then dpkg -i "$KASM_DEB" || apt-get -f install -y; rm -f "$KASM_DEB"; fi

# Create non-root vscode user (Codespaces default)
RUN useradd -m -s /bin/bash vscode || true
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

WORKDIR /workspace
EXPOSE 6901
