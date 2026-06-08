#!/usr/bin/env bash
set -euo pipefail

TERRAFORM_OPTIONS="$1"

if ! PLAN=$(tofu $TERRAFORM_OPTIONS show -no-color terraform.tfplan); then
    echo "Error: Failed to get terraform plan output"
    exit 1
fi

# Truncate plan if it exceeds maximum length to avoid "argument too long" errors
MAX_LENGTH=60000
if [ ${#PLAN} -gt $MAX_LENGTH ]; then
    PLAN="${PLAN:0:$MAX_LENGTH}

... (output truncated due to size)"
fi

if ! PR_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH"); then
    echo "Error: Failed to get PR number"
    exit 1
fi

if ! REPO_OWNER=$(jq --raw-output .repository.owner.login "$GITHUB_EVENT_PATH"); then
    echo "Error: Failed to get repo owner"
    exit 1
fi

if ! REPO_NAME=$(jq --raw-output .repository.name "$GITHUB_EVENT_PATH"); then
    echo "Error: Failed to get repo name"
    exit 1
fi

# Hidden marker so successive plans on the same PR update this comment instead of stacking new ones
MARKER="<!-- terraform-plan -->"

# Create JSON payload with proper escaping
PAYLOAD=$(jq -n \
    --arg body "$(printf '%s\n```\n%s\n```' "$MARKER" "$PLAN")" \
    '{"body": $body}')

COMMENT_ID=$(curl -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/$PR_NUMBER/comments?per_page=100" \
    | jq -r --arg m "$MARKER" 'map(select(.body | startswith($m))) | .[0].id // empty')

if [ -n "$COMMENT_ID" ]; then
    URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/comments/$COMMENT_ID"
    METHOD=PATCH
else
    URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/$PR_NUMBER/comments"
    METHOD=POST
fi

if ! curl -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -X "$METHOD" \
    -d "$PAYLOAD" \
    "$URL" > /dev/null; then
    echo "Error: Failed to post comment" >&2
    exit 1
fi

echo "Comment posted successfully"
