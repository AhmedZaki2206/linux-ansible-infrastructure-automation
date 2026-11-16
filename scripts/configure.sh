#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ansible-playbook
enter_repo
ansible-playbook -i "${INVENTORY}" site.yml "$@"

