#!/usr/bin/env bash

[[ "$DEBUG" ]] && set -x

set -e

terraform_init() {
  tofu "$@" init
}

main() {
  terraform_init "$@"
  exit 0
}

main "$@"
