#!/bin/bash

FORKSOURCE="gml-raptor"

UPSTREAM_URL="https://github.com/coldrockgames/$FORKSOURCE.git"

echo "Creating upstream to $UPSTREAM_URL..."
git remote remove upstream 2>/dev/null
git remote add upstream "$UPSTREAM_URL"

echo "-"
echo "- Repository is now configured to receive updates from the $FORKSOURCE repository."
echo "-"
