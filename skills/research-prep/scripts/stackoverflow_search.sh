#!/bin/bash
# Stack Overflow search using API (no auth needed for read-only)
# Returns top questions/answers by votes

set -e

QUERY="$1"
LIMIT="${2:-10}"
TAG="${3:-}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [limit] [tag]"
    echo "Example: $0 'kubernetes gateway' 5 kubernetes"
    exit 1
fi

# URL encode
ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)

# Build API URL
API_URL="https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=votes&site=stackoverflow&q=$ENCODED_QUERY&pagesize=$LIMIT"

if [ -n "$TAG" ]; then
    ENCODED_TAG=$(echo "$TAG" | jq -sRr @uri)
    API_URL="${API_URL}&tagged=$ENCODED_TAG"
fi

# Fetch and parse
curl -s "$API_URL" | \
    jq -r '.items[] | "Title: \(.title)\nURL: \(.link)\nScore: \(.score) | Answers: \(.answer_count)\nTags: \(.tags | join(", "))\n---"'
