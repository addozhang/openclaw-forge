#!/bin/bash
# GitHub search wrapper for research prep
# Searches repos, code, issues, and discussions

set -e

function usage() {
    cat << EOF
Usage: $0 <command> <query> [options]

Commands:
  repos       Search repositories
  code        Search code
  issues      Search issues
  discussions Search discussions
  readme      Get repository README

Examples:
  $0 repos "kubernetes gateway" --limit 10
  $0 code "Gateway API" --repo kubernetes/kubernetes
  $0 issues "bug" --repo istio/istio --state closed
  $0 readme kubernetes/gateway-api
EOF
    exit 1
}

COMMAND=$1
QUERY=$2
shift 2 || usage

case "$COMMAND" in
    repos)
        gh search repos "$QUERY" \
            --limit 10 \
            --sort stars \
            --json fullName,description,url,stargazersCount,updatedAt \
            "$@"
        ;;
    
    code)
        gh search code "$QUERY" \
            --limit 20 \
            --json repository,path,url \
            "$@"
        ;;
    
    issues)
        REPO=""
        while [[ $# -gt 0 ]]; do
            case $1 in
                --repo)
                    REPO="$2"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        
        if [ -z "$REPO" ]; then
            echo "Error: --repo required for issues search"
            exit 1
        fi
        
        gh search issues "$QUERY" \
            --repo "$REPO" \
            --limit 20 \
            --json title,url,state,createdAt,closedAt,comments \
            "$@"
        ;;
    
    discussions)
        REPO=""
        while [[ $# -gt 0 ]]; do
            case $1 in
                --repo)
                    REPO="$2"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        
        if [ -z "$REPO" ]; then
            echo "Error: --repo required for discussions search"
            exit 1
        fi
        
        # Note: gh CLI doesn't have native discussion search yet
        # Use API directly
        gh api "repos/$REPO/discussions" \
            --jq '.[] | select(.title | contains("'"$QUERY"'")) | {title, url, createdAt, comments}'
        ;;
    
    readme)
        # QUERY is actually the repo name here
        gh api "repos/$QUERY/readme" \
            --jq '.content' | base64 -d
        ;;
    
    *)
        echo "Unknown command: $COMMAND"
        usage
        ;;
esac
