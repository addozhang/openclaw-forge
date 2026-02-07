#!/bin/bash
# Fetch Google Tasks using credentials.json and token.json
# Auto-refresh token if expired

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TOKEN_FILE="$SKILL_DIR/token.json"

# Load common functions
source "$SCRIPT_DIR/common.sh"

# Check if token exists
if [ ! -f "$TOKEN_FILE" ]; then
    echo "Error: token.json not found. Please authenticate first."
    exit 1
fi

# Get access token (with auto-refresh)
ACCESS_TOKEN=$(get_access_token "$TOKEN_FILE" "$SCRIPT_DIR")

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: Failed to get valid access token"
    exit 1
fi

# Fetch task lists
echo "📋 Your Google Tasks:"
echo

LISTS=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://tasks.googleapis.com/tasks/v1/users/@me/lists")

# Check for auth error (might still happen if refresh failed)
if echo "$LISTS" | jq -e '.error' > /dev/null 2>&1; then
    ERROR_CODE=$(echo "$LISTS" | jq -r '.error.code')
    ERROR_MSG=$(echo "$LISTS" | jq -r '.error.message')
    
    # If it's an auth error, try refreshing once more
    if [ "$ERROR_CODE" = "401" ]; then
        echo "🔄 Authentication failed, attempting token refresh..." >&2
        
        if "$SCRIPT_DIR/refresh_token.sh" >&2; then
            # Retry with new token
            ACCESS_TOKEN=$(jq -r '.access_token // empty' "$TOKEN_FILE")
            LISTS=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
                "https://tasks.googleapis.com/tasks/v1/users/@me/lists")
            
            # Check again
            if echo "$LISTS" | jq -e '.error' > /dev/null 2>&1; then
                ERROR_MSG=$(echo "$LISTS" | jq -r '.error.message')
                echo "Error: $ERROR_MSG"
                echo "Please delete token.json and re-authenticate"
                exit 1
            fi
        else
            echo "Error: $ERROR_MSG"
            echo "Token refresh failed. Please delete token.json and re-authenticate"
            exit 1
        fi
    else
        echo "Error: $ERROR_MSG"
        exit 1
    fi
fi

# Process each list
echo "$LISTS" | jq -c '.items[]' | while read -r list_json; do
    LIST_ID=$(echo "$list_json" | jq -r '.id')
    LIST_TITLE=$(echo "$list_json" | jq -r '.title // "(unnamed)"')
    
    echo
    echo "📌 $LIST_TITLE"
    echo "──────────────────────────────────────────────────"
    
    # Fetch tasks for this list
    TASKS=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
        "https://tasks.googleapis.com/tasks/v1/lists/$LIST_ID/tasks?showCompleted=false")
    
    # Count tasks
    TASK_COUNT=$(echo "$TASKS" | jq '.items | length')
    
    if [ "$TASK_COUNT" = "0" ] || [ "$TASK_COUNT" = "null" ]; then
        echo "  (no tasks)"
    else
        # Process each task
        INDEX=1
        echo "$TASKS" | jq -c '.items[]' | while read -r task_json; do
            TITLE=$(echo "$task_json" | jq -r '.title // "(no title)"')
            DUE=$(echo "$task_json" | jq -r '.due // empty' | cut -d'T' -f1)
            NOTES=$(echo "$task_json" | jq -r '.notes // empty')
            
            LINE="  $INDEX. ⬜ $TITLE"
            [ -n "$DUE" ] && LINE="$LINE (due: $DUE)"
            echo "$LINE"
            
            [ -n "$NOTES" ] && echo "     Note: $NOTES"
            
            INDEX=$((INDEX + 1))
        done
    fi
done

echo
