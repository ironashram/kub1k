#!/usr/bin/env bash
set -euo pipefail

TERRAFORM_OPTIONS="$1"

# Debug output
echo "Running terraform plan..."

# Capture plan output and check for errors
if ! PLAN=$(terraform $TERRAFORM_OPTIONS show -no-color terraform.tfplan); then
    echo "Error: Failed to get terraform plan output"
    exit 1
fi

# Debug output
echo "Getting PR details..."

# Get PR details with error checking
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

# Create JSON payload with proper escaping
PAYLOAD=$(jq -n \
    --arg body "$(printf '```\n%s\n```' "$PLAN")" \
    '{"body": $body}')

# Debug output
echo "Posting comment to PR #$PR_NUMBER..."

# Post comment with error checking
if ! curl -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$PAYLOAD" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/$PR_NUMBER/comments"; then
    echo "Error: Failed to post comment"
    exit 1
fi

echo "Comment posted successfully"
