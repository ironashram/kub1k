#!/bin/bash
set -euo pipefail

: "${RUNNER_VERSION:?}"
: "${RUNNER_OWNER:?}"
: "${RUNNER_REPOS:?}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted}"

PAT="$(cat /etc/github-runner/pat)"
BASE=/var/lib/github-runner
TARBALL="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${TARBALL}"

export RUNNER_ALLOW_RUNASROOT=1
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

mkdir -p "$BASE"
[ -f "$BASE/$TARBALL" ] || curl -fsSL -o "$BASE/$TARBALL" "$URL"

mint_token() {
  curl -fsSL -X POST \
    -H "Authorization: Bearer $PAT" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${RUNNER_OWNER}/$1/actions/runners/registration-token" \
    | sed -n 's/.*"token": *"\([^"]*\)".*/\1/p'
}

for repo in $RUNNER_REPOS; do
  dir="$BASE/$repo"
  [ -f "$dir/.runner" ] && continue
  mkdir -p "$dir"
  tar -xzf "$BASE/$TARBALL" -C "$dir"
  # Neutralize config.sh's libicu precheck (Flatcar has no libicu; runner uses invariant mode).
  sed -i 's#.*grep libicu.*#    true#' "$dir/config.sh"
  token="$(mint_token "$repo")"
  "$dir/config.sh" --unattended --replace \
    --url "https://github.com/${RUNNER_OWNER}/${repo}" \
    --token "$token" \
    --name "$(hostname)-${repo}" \
    --labels "${RUNNER_LABELS},${repo}" \
    --work _work
done

touch "$BASE/.configured"
