# chromium (optimized for Codespaces)

This repository provides a ready-to-run Codespaces `.devcontainer` that launches Chromium inside a container
and streams the desktop via KasmVNC (or x11vnc fallback) for fast browser access.

## Features
- Default resolution: **1024x576** (faster)
- Attempts to use **KasmVNC** if available; falls back to x11vnc + websockify otherwise
- Automatically sets CPU-affecting env vars (`OMP_NUM_THREADS`) to detected CPU count
- Chromium started with flags that favor GPU acceleration if available, and higher renderer limits to use more CPU
- `devcontainer.json` requests `--cpus=8` and `--memory=12g` via runArgs and sets `"machine": "standard-8"`

## Usage
1. Open this repository in GitHub Codespaces.
2. Rebuild the container if needed (`Codespaces: Rebuild Container`).
3. When the container finishes startup, forward port **6901** and open it in your browser.
4. You should see the Chromium desktop (new tab).

## Notes
- Codespaces **may not** provide a real GPU. For true hardware acceleration, run this container on a GPU-enabled VM (AWS/GCP/Azure) and ensure drivers are installed.
- You can increase CPU/RAM by selecting a larger Codespaces machine or editing `devcontainer.json` runArgs.
