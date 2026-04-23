#!/bin/bash

# publish_reports.sh
# Usage: bash publish_reports.sh [folder or file ...]
# Example: bash publish_reports.sh results/
#          bash publish_reports.sh results/M5_run1
#          bash publish_reports.sh  (defaults to results/)

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TARGET="${@:-results/}"

echo "==> Staging: $TARGET"
git add $TARGET

# Check if there's anything to commit
if git diff --cached --quiet; then
  echo "Nothing new to publish. No changes detected."
  exit 0
fi

echo "==> Committing with timestamp: $TIMESTAMP"
git commit -m "Publish test results [$TIMESTAMP]"

echo "==> Pushing to GitHub..."
git push origin main

echo ""
echo "Done! Results published to GitHub at $TIMESTAMP"
