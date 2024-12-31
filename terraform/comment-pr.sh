#!/usr/bin/env bash
set -euo pipefail

TERRAFORM_OPTIONS="$1"

read -r -d '' PLAN << EOF
$(terraform $TERRAFORM_OPTIONS show -no-color terraform.tfplan)
EOF

PR_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
REPO_OWNER=$(jq --raw-output .repository.owner.login "$GITHUB_EVENT_PATH")
REPO_NAME=$(jq --raw-output .repository.name "$GITHUB_EVENT_PATH")

# Create JSON payload with proper escaping
read -r -d '' PAYLOAD << EOF
{
  "body": "\`\`\`\n${PLAN}\n\`\`\`"
}
EOF

# Post comment
curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$PAYLOAD" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/$PR_NUMBER/comments"
