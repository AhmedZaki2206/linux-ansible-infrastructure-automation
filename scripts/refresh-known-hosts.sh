#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ssh-keygen
require_tool ssh-keyscan
install -d -m 700 "${HOME}/.ssh"
touch "${HOME}/.ssh/known_hosts"
chmod 600 "${HOME}/.ssh/known_hosts"
for ip in 192.168.56.11 192.168.56.12 192.168.56.13; do
  ssh-keygen -R "${ip}" >/dev/null 2>&1 || true
  ssh-keyscan -H -t ed25519 "${ip}" >> "${HOME}/.ssh/known_hosts" 2>/dev/null
done

