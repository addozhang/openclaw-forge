#!/bin/bash
# Web search using DuckDuckGo HTML interface (no API key needed)
# Simple curl-based search with basic parsing

set -e

QUERY="$1"
LIMIT="${2:-10}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [limit]"
    exit 1
fi

# URL encode the query
ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)

# Search DuckDuckGo
curl -s "https://html.duckduckgo.com/html/?q=$ENCODED_QUERY" | \
    grep -oP '<a class="result__url" href="\K[^"]+' | \
    head -n "$LIMIT" | \
    while read -r url; do
        # Decode URL
        decoded_url=$(echo "$url" | python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read().strip()))")
        echo "$decoded_url"
    done
