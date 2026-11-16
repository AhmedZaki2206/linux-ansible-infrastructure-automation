#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool vagrant
require_tool VBoxManage
enter_repo
vagrant up
vagrant status

