#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool ansible-playbook
require_tool tee
enter_repo
mkdir -p .generated
log=.generated/idempotency-second-run.log
ansible-playbook -i "${INVENTORY}" site.yml | tee "${log}"
if grep -E 'changed=[1-9][0-9]*' "${log}" >/dev/null; then
  echo "FAILED: the second run reported unexpected changes." >&2
  exit 1
fi
echo "PASSED: the verification run reported changed=0 for every host."

