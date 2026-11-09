#!/bin/bash
# Launch napari from a pixi environment defined in the napari-env GitHub repo.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/cwood1967/napari-env/main"
APP_DIR="$HOME/.napari-env"          # local copy of the manifest + lock (+ .pixi env)
TASK="napari"                        # pixi task defined in pyproject.toml

# Install pixi if missing.
export PATH="$HOME/.pixi/bin:$PATH"
if ! command -v pixi >/dev/null 2>&1; then
  echo "pixi not found - installing..."
  curl -fsSL https://pixi.sh/install.sh | sh
fi
if ! command -v pixi >/dev/null 2>&1; then
  echo "Failed to install pixi. Install it manually from https://pixi.sh, then re-run this file."
  read -n 1 -s -r -p "Press any key to exit..."
  exit 1
fi

# Fetch the latest manifest + lockfile; keep the existing copy if offline.
mkdir -p "$APP_DIR"
for f in pyproject.toml pixi.lock; do
  curl -fsSL "$REPO_RAW/$f" -o "$APP_DIR/$f.tmp" && mv "$APP_DIR/$f.tmp" "$APP_DIR/$f" \
    || { rm -f "$APP_DIR/$f.tmp"; echo "Could not update $f - using cached copy."; }
done
if [ ! -f "$APP_DIR/pixi.lock" ]; then
  echo "No environment files available (first run needs internet)."
  read -n 1 -s -r -p "Press any key to exit..."
  exit 1
fi

# --frozen: install exactly what's in pixi.lock, never re-solve on the user's machine.
pixi run --frozen --manifest-path "$APP_DIR/pyproject.toml" "$TASK"
