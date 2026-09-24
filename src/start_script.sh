#!/usr/bin/env bash
set -u

TEMPLATE_DIR=/comfyui-wan
TEMPLATE_URL="${TEMPLATE_REPOSITORY_URL:-https://github.com/ilklatte/comfyui-wan.git}"
TEMPLATE_BRANCH="${TEMPLATE_REPOSITORY_BRANCH:-main}"
RUNTIME_DIR=/opt/comfyui-runtime

if [[ "$TEMPLATE_URL" == REPLACE_* ]]; then
    echo "FATAL: set TEMPLATE_REPOSITORY_URL to the public Git repository for this template." >&2
    exit 2
fi

sync_repo() {
    local dir="$1" url="$2" ref="$3"
    if [ -d "$dir/.git" ]; then
        git -C "$dir" fetch --depth=1 origin "$ref" && git -C "$dir" reset --hard FETCH_HEAD
    else
        rm -rf "$dir" && git clone --depth=1 --branch "$ref" "$url" "$dir"
    fi
}

ok=""
for attempt in 1 2 3 4 5; do
    if sync_repo "$TEMPLATE_DIR" "$TEMPLATE_URL" "$TEMPLATE_BRANCH"; then ok=1; break; fi
    echo "Template sync attempt $attempt failed; retrying in $((attempt * 5)) seconds."
    sleep $((attempt * 5))
done
if [ -z "$ok" ] && [ ! -d "$TEMPLATE_DIR/.git" ]; then
    echo "FATAL: template repository is unavailable and no cached copy exists." >&2
    exit 1
fi

# The repository value is only the build default; a pipeline may override it.
# Record the build's actual parent image in the runtime copy so the boot report
# never claims that a different Base reference was used.
if [ -n "${COMFYUI_BASE_IMAGE:-}" ] && [ -f "$TEMPLATE_DIR/pins.json" ]; then
    python3 - "$TEMPLATE_DIR/pins.json" "$COMFYUI_BASE_IMAGE" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
pins = json.loads(path.read_text())
pins["base_image"] = sys.argv[2]
path.write_text(json.dumps(pins, indent=2) + "\n")
PY
fi

if [ ! -x "$RUNTIME_DIR/src/start.sh" ]; then
    echo "FATAL: Base-owned runtime is missing at $RUNTIME_DIR/src/start.sh." >&2
    exit 1
fi

exec bash "$RUNTIME_DIR/src/start.sh" "$TEMPLATE_DIR"
