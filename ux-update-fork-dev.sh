#!/bin/bash
set -e

FORKSOURCE="gml-raptor"

echo "-"
echo "- Fetching latest from $FORKSOURCE..."
echo "-"
git fetch upstream

echo "-"
echo "- Merging $FORKSOURCE/dev into current branch..."
echo "-"
git merge --no-edit upstream/dev

echo "-"
echo "- Merge completed. Look for conflicts and resolve them before you continue!"
echo "-"

if [ -z "$1" ]; then
  read -p "Press Enter to continue..."
fi