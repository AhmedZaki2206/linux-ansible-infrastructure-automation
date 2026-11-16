#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool vagrant
require_tool ssh-keygen
require_tool base64
enter_repo

key_path="${HOME}/.ssh/ansible_lab_ed25519"
if [[ ! -f "${key_path}" ]]; then
  install -d -m 700 "${HOME}/.ssh"
  ssh-keygen -t ed25519 -a 64 -f "${key_path}" -N '' -C 'ansible-lab-controller'
fi
public_key_b64=$(base64 -w 0 < "${key_path}.pub")

for host in "${LAB_HOSTS[@]}"; do
  echo "Bootstrapping ${host} through the Vagrant console channel..."
  vagrant ssh "${host}" -c "PUBLIC_KEY_B64='${public_key_b64}' sudo --preserve-env=PUBLIC_KEY_B64 bash -s" <<'BOOTSTRAP'
set -Eeuo pipefail
getent group ansible-admins >/dev/null || groupadd ansible-admins
id ansible >/dev/null 2>&1 || useradd --create-home --shell /bin/bash --groups ansible-admins ansible
usermod --append --groups ansible-admins ansible
install -d -o ansible -g ansible -m 700 /home/ansible/.ssh
printf '%s\n' "${PUBLIC_KEY_B64}" | base64 --decode > /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
printf '%s\n' 'ansible ALL=(root) NOPASSWD: ALL' > /etc/sudoers.d/90-ansible-bootstrap
chmod 440 /etc/sudoers.d/90-ansible-bootstrap
visudo -cf /etc/sudoers.d/90-ansible-bootstrap
BOOTSTRAP
done

./scripts/refresh-known-hosts.sh
ansible -i "${INVENTORY}" lab_servers -m ansible.builtin.ping

