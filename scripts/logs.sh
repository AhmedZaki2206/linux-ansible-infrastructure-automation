#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ansible
enter_repo
host="${1:-ops01}"
ansible -i "${INVENTORY}" "${host}" -b -m ansible.builtin.command \
  -a 'journalctl --no-pager --lines=50 -u ssh -u ansible-lab-health.service'

