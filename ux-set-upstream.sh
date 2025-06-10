#!/bin/bash
set -e

FORKSOURCE="gml-raptor"
UPSTREAM_REMOTE="upstream"
UPSTREAM_URL="https://github.com/coldrockgames/$FORKSOURCE.git"

echo "Creating upstream to $UPSTREAM_URL..."
git remote remove "$UPSTREAM_REMOTE" 2>/dev/null
git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"

echo "-"
echo "- Repository is now configured to receive updates from the $FORKSOURCE repository."
echo "-"
