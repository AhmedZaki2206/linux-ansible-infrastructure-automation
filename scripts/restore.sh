#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ansible
enter_repo
host="${1:-ops01}"
archive="${2:-}"
if [[ -z "${archive}" ]]; then
  echo "Usage: $0 <host> <remote-archive.tar.gz>" >&2
  echo "Restore is staged under /tmp and never overwrites live configuration." >&2
  exit 2
fi
destination="/tmp/ansible-lab-restore-$(date +%s)"
ansible -i "${INVENTORY}" "${host}" -b -m ansible.builtin.command \
  -a "/usr/local/sbin/ansible-lab-restore ${archive} ${destination}"

