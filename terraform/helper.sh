#!/usr/bin/env bash
# shellcheck disable=SC2124

[[ "$DEBUG" ]] && set -x

set -e

terraform_init() {
  local ENVIRONMENT="$1"; shift
  local TERRAFORM_GLOBAL_OPTIONS="$@"

  terraform "$TERRAFORM_GLOBAL_OPTIONS" init
}

main() {
  local ENVIRONMENT="$1"; shift
  local TERRAFORM_GLOBAL_OPTIONS="$@"

  terraform_init "$ENVIRONMENT" "$TERRAFORM_GLOBAL_OPTIONS"
  terraform "$TERRAFORM_GLOBAL_OPTIONS" workspace select "$ENVIRONMENT" || terraform "$TERRAFORM_GLOBAL_OPTIONS" workspace new "$ENVIRONMENT"
  exit 0
}

main "$@"
