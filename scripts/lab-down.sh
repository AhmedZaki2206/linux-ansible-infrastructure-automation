#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"
require_tool vagrant
enter_repo
vagrant destroy --force

