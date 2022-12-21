#!/bin/sh
#
# Gets the latest tag of the form "vX.Y[.Z]" from a given GitHub repository.
#

set -e

GITHUB_REPO=$1
TAG_PREFIX=$2

if [ -z $GITHUB_REPO ]; then
  echo "Usage: $0 <GitHub user>/<GitHub repository>"
  exit 1
fi

# get the tags JSON from the GitHub API and parse it manually
curl --silent --show-error --fail-with-body https://api.github.com/repos/$GITHUB_REPO/tags \
  | grep '"name":' \
  | sed -E 's/.*"([^"]+)".*/\1/' \
  | egrep "^${TAG_PREFIX:-[a-z_-]+}[0-9]+[\._-][0-9]+([\._-][0-9]+)?\$" \
  | head -n 1
