#!/usr/bin/env bash
set -Eeuo pipefail
key_source=/run/controller-key/ansible_lab_ed25519.pub
[[ -f "${key_source}" ]] || { echo "Missing mounted controller public key: ${key_source}" >&2; exit 1; }
install -o ansible -g ansible -m 0600 "${key_source}" /home/ansible/.ssh/authorized_keys
ssh-keygen -A
exec /usr/sbin/sshd -D -e

