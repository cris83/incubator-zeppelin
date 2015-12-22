#!/bin/bash
set -e
#source .zci.env
# -------------------------------------------------------------------------
# * NOTE 
#
#   - Argument 1 : ZCI Build ID
#   - Argument 2 : ZCI Build Item
#                  ( Default : spark_standalone, spark_mesos, spark_yarn )
#   - Argument 3 : your repository url
#   - Argument 4 : your branch
#
# -------------------------------------------------------------------------
BUILD_ITEM=$1
BUILD_ID=$2
REPO_URL=$3
BRANCH=$4

echo "# Build ID    : $BUILD_ID"
echo "# Build Item  : $BUILD_ITEM"
echo "# PR Repo-URL : $REPO_URL"
echo "# PR Branch   : $BRANCH"


# -------------------------------------------------------------------------
# Run Build
# -------------------------------------------------------------------------

# Backend
#make run type=backend item=$BUILD_ITEM name=$BUILD_ID

# Zeppelin
#make run type=zeppelin item=$BUILD_ITEM name=$BUILD_ID REPO=$REPO_URL BRANCH=$BRANCH


echo "Done"
# -------------------------------------------------------------------------
# End of File
# -------------------------------------------------------------------------
