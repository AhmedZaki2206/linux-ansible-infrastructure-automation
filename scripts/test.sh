#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ansible
require_tool curl
require_tool ssh
enter_repo
ansible -i "${INVENTORY}" lab_servers -m ansible.builtin.ping
for ip in 192.168.56.11 192.168.56.12 192.168.56.13; do
  ssh -o BatchMode=yes -o ConnectTimeout=5 -i "${HOME}/.ssh/ansible_lab_ed25519" "ansible@${ip}" true
done
curl --fail --silent --show-error --max-time 5 http://192.168.56.11/healthz
ansible -i "${INVENTORY}" lab_servers -b -m ansible.builtin.command -a /usr/local/sbin/ansible-lab-health
echo "Connectivity, SSH, HTTP, and health checks passed."

