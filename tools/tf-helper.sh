#!/usr/bin/env bash
# shellcheck disable=SC2124

[[ "$DEBUG" ]] && set -x

set -e

terraform_init() {
  local TERRAFORM_GLOBAL_OPTIONS="$@"

  tofu "$TERRAFORM_GLOBAL_OPTIONS" init
}

main() {
  local TERRAFORM_GLOBAL_OPTIONS="$@"

  terraform_init "$TERRAFORM_GLOBAL_OPTIONS"
  exit 0
}

main "$@"
