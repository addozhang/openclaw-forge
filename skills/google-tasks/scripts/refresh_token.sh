#!/bin/bash
# Refresh Google OAuth token using refresh_token

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TOKEN_FILE="$SKILL_DIR/token.json"
CREDENTIALS_FILE="$SKILL_DIR/credentials.json"

# Check if files exist
if [ ! -f "$TOKEN_FILE" ]; then
    echo "Error: token.json not found"
    exit 1
fi

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Error: credentials.json not found"
    exit 1
fi

# Extract tokens
REFRESH_TOKEN=$(jq -r '.refresh_token // empty' "$TOKEN_FILE")
CLIENT_ID=$(jq -r '.installed.client_id // empty' "$CREDENTIALS_FILE")
CLIENT_SECRET=$(jq -r '.installed.client_secret // empty' "$CREDENTIALS_FILE")

if [ -z "$REFRESH_TOKEN" ] || [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    echo "Error: Missing required credentials"
    exit 1
fi

# Refresh the token
RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "refresh_token=$REFRESH_TOKEN" \
    -d "grant_type=refresh_token")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error_description // .error')
    echo "Error refreshing token: $ERROR_MSG"
    exit 1
fi

# Extract new access token
NEW_ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')
EXPIRES_IN=$(echo "$RESPONSE" | jq -r '.expires_in')

if [ -z "$NEW_ACCESS_TOKEN" ] || [ "$NEW_ACCESS_TOKEN" = "null" ]; then
    echo "Error: Failed to get new access token"
    exit 1
fi

# Calculate expiry timestamp (both formats for compatibility)
EXPIRY_SECONDS=$(date -u -d "+${EXPIRES_IN} seconds" +%s 2>/dev/null || echo $(($(date +%s) + EXPIRES_IN)))
EXPIRY_MS=$((EXPIRY_SECONDS * 1000))

# Update token.json with new access token and expiry
TMP_FILE=$(mktemp)
jq --arg access_token "$NEW_ACCESS_TOKEN" \
   --arg expiry "$EXPIRY_SECONDS" \
   --arg expiry_date "$EXPIRY_MS" \
   '.access_token = $access_token | .expiry = ($expiry | tonumber) | .expiry_date = ($expiry_date | tonumber)' \
   "$TOKEN_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$TOKEN_FILE"

echo "Token refreshed successfully (expires in ${EXPIRES_IN}s)"
