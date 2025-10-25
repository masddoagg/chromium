#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Chromium (optimized) + KasmVNC startup script - resolution 1024x576 (fast)"

# Determine CPU count and set helpful env vars
CPU_COUNT=$(nproc --all || echo 4)
export OMP_NUM_THREADS=$CPU_COUNT
export DECODE_THREADS=$CPU_COUNT

echo "Detected CPUs: $CPU_COUNT"
echo "Setting OMP_NUM_THREADS and DECODE_THREADS to $CPU_COUNT"

# Kill leftovers
pkill -f Xvfb || true
pkill -f kasmvncserver || true
pkill -f chromium || true

# Start Xvfb with lower color depth for speed
Xvfb :1 -screen 0 1024x576x16 +extension RANDR &
sleep 0.8

# Start lightweight window manager
fluxbox &

sleep 0.5

# Start KasmVNC if available; otherwise fallback to x11vnc/websockify (best effort)
if command -v kasmvncserver >/dev/null 2>&1; then
  echo "Starting KasmVNC..."
  kasmvncserver --port 6901 --no-ssl --display :1 --depth 16 --geometry 1024x576 --quality 85 &
else
  echo "KasmVNC not found — installing/starting x11vnc + websockify fallback..."
  apt-get update && apt-get install -y --no-install-recommends x11vnc websockify python3-websocket
  x11vnc -display :1 -noxdamage -ncache 10 -ncache_cr -forever -shared -rfbport 5900 &
  (python3 -m websockify 6901 localhost:5900 &) || true
fi

sleep 1.5

# Chromium flags tuned for max CPU usage & to enable GPU paths if available
# Use renderer-process-limit proportionally to CPU count to allow more renderers
RENDERER_LIMIT=$(( CPU_COUNT * 2 ))
CHROME_FLAGS=(
  "--no-sandbox"
  "--disable-dev-shm-usage"
  "--disable-extensions"
  "--disable-background-timer-throttling"
  "--enable-accelerated-2d-canvas"
  "--enable-gpu-rasterization"
  "--enable-zero-copy"
  "--ignore-gpu-blocklist"
  "--use-gl=egl"
  "--enable-features=VaapiVideoDecoder,UseAngle"
  "--disable-software-rasterizer"
  "--renderer-process-limit=${RENDERER_LIMIT}"
  "--disable-breakpad"
  "--disable-gpu-sandbox"
  "--window-size=1024,576"
  "--user-data-dir=/tmp/chrome-user-data"
)

echo "Launching Chromium with renderer limit $RENDERER_LIMIT..."
# Launch as vscode user if running as root environment
if id -u vscode >/dev/null 2>&1; then
  sudo -u vscode env DISPLAY=:1 "${CHROME_BIN:-/usr/bin/chromium-browser}" "${CHROME_FLAGS[@]}" "about:blank" &>/tmp/chrome.log &
else
  "${CHROME_BIN:-/usr/bin/chromium-browser}" "${CHROME_FLAGS[@]}" "about:blank" &>/tmp/chrome.log &
fi

echo ""
echo "✅ Startup complete — KasmVNC should be available on port 6901 (forward that port in Codespaces)."
echo "Tip: If you can select a bigger Codespaces machine (more vCPUs / RAM) that will greatly improve performance."
sleep infinity
