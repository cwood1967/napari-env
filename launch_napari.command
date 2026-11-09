#!/bin/bash
set -euo pipefail

TOOL_NAME="napari-env"                                    # or "napari" for Option B
TOOL_SOURCE="git+https://github.com/cwood1967/napari-env" # or "napari[all]" + --with-requirements for Option B

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found - installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
if ! command -v uv >/dev/null 2>&1; then
  echo "Failed to install uv. Install it manually from https://astral.sh/uv, then re-run this file."
  read -n 1 -s -r -p "Press any key to exit..."
  exit 1
fi

if ! uv tool list | grep -qi "^${TOOL_NAME} "; then
  echo "Installing ${TOOL_NAME}..."
  uv tool install "${TOOL_SOURCE}"
else
  echo "Checking for updates..."
  uv tool upgrade "$TOOL_NAME" || true
fi

uv tool run "${TOOL_NAME}"
