#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ansible
enter_repo
ansible -i "${INVENTORY}" lab_servers -m ansible.builtin.ping
ansible -i "${INVENTORY}" lab_servers -b -m ansible.builtin.shell \
  -a 'set -o pipefail; systemctl is-active ssh; systemctl is-active ansible-lab-health.timer; ufw status | head -1' \
  -e 'ansible_shell_executable=/bin/bash'
ansible -i "${INVENTORY}" web_servers -b -m ansible.builtin.command -a 'systemctl is-active nginx'

