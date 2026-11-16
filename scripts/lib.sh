#!/usr/bin/env bash
set -Eeuo pipefail

readonly LAB_HOSTS=(web01 app01 ops01)
readonly INVENTORY="${INVENTORY:-inventory/lab/hosts.yml}"

repo_root() { cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd; }
require_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: '$1' is required. See docs/STEP_BY_STEP_GUIDE.md." >&2
    exit 1
  }
}
enter_repo() { cd "$(repo_root)"; }

