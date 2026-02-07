#!/bin/bash
# Common functions for Google Tasks scripts

# Check if token is expired and refresh if needed
ensure_valid_token() {
    local token_file="$1"
    local script_dir="$2"
    
    # Function to check if token is expired
    check_token_expiry() {
        local token_file="$1"
        
        # Try expiry field first (seconds), then expiry_date (milliseconds)
        local expiry
        if jq -e '.expiry' "$token_file" > /dev/null 2>&1; then
            expiry=$(jq -r '.expiry' "$token_file")
        elif jq -e '.expiry_date' "$token_file" > /dev/null 2>&1; then
            # Convert milliseconds to seconds
            expiry=$(jq -r '.expiry_date / 1000 | floor' "$token_file")
        else
            # No expiry field, assume expired
            return 1
        fi
        
        local current_time=$(date +%s)
        
        # Add 60 second buffer (refresh if expiring within 1 minute)
        if [ "$expiry" -lt $((current_time + 60)) ]; then
            return 1  # Token expired or about to expire
        fi
        
        return 0  # Token is valid
    }
    
    # Check token expiry and refresh if needed
    if ! check_token_expiry "$token_file"; then
        echo "🔄 Token expired or expiring soon, refreshing..." >&2
        
        if ! "$script_dir/refresh_token.sh" >&2; then
            echo "Error: Failed to refresh token. Please re-authenticate." >&2
            return 1
        fi
        
        echo "" >&2
    fi
    
    return 0
}

# Get access token with auto-refresh
get_access_token() {
    local token_file="$1"
    local script_dir="$2"
    
    # Ensure token is valid
    if ! ensure_valid_token "$token_file" "$script_dir"; then
        return 1
    fi
    
    # Extract and return access token
    jq -r '.access_token // empty' "$token_file"
}
