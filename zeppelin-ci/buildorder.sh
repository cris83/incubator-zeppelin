#!/bin/bash
set -e
# ---------------------------------------------------------------------
# * Note  
#   - Argument 1 : ZCI Build ID
#   - Argument 2 : your repository url
#   - Argument 3 : your branch
# ---------------------------------------------------------------------

BUILD_ID=$1
REPO_URL=$2
BRANCH=$3

echo "> Build ID    : $BUILD_ID"
echo "> PR Repo-URL : $REPO_URL"
echo "> PR Branch   : $BRANCH"

echo "Done"

# ---------------------------------------------------------------------
# End of File
# ---------------------------------------------------------------------
