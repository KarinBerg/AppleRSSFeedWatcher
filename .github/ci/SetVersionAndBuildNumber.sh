#!/bin/bash

# This script sets the version and build number of the app.
echo "TARGET_BUILD_DIR: ${TARGET_BUILD_DIR}"

# Get the latest git version tag 
LATEST_TAG=$(git tag --list 'v*' --sort=-version:refname | head -n 1)
echo "LATEST_TAG: $LATEST_TAG"
VERSION=${LATEST_TAG#v}
echo "$VERSION"
echo "VERSION: $VERSION"

# Get the total number of commits reachable from the current HEAD.
COMMIT_COUNT=$(git rev-list --count HEAD)
echo "COMMIT_COUNT: $COMMIT_COUNT"

# Set the user visible version (MARKETING_VERSION) to VERSION and build number to COMMIT_COUNT
cat > "$XCCONFIG_DIR/Versioning.xcconfig" <<EOF
MARKETING_VERSION = $VERSION
CURRENT_PROJECT_VERSION = $COMMIT_COUNT
EOF
