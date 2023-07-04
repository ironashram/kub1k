#!/usr/bin/env bash
[[ "$DEBUG" ]] && set -x

set -e

terraform_init() {
  declare desc="run terraform init in environment"
  local ENVIRONMENT="$1"; shift
  local TERRAFORM_GLOBAL_OPTIONS="$@"

  terraform "$TERRAFORM_GLOBAL_OPTIONS" init
}

main() {
  declare desc="main function"
  local ENVIRONMENT="$1"; shift
  local TERRAFORM_GLOBAL_OPTIONS="$@"

  terraform_init "$ENVIRONMENT" "$TERRAFORM_GLOBAL_OPTIONS"
  terraform "$TERRAFORM_GLOBAL_OPTIONS" workspace select "$ENVIRONMENT" || terraform "$TERRAFORM_GLOBAL_OPTIONS" workspace new "$ENVIRONMENT"
  exit 0
}

main "$@"
