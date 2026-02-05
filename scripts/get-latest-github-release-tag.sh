#!/bin/sh
#
# Gets the latest tag of the form "vX.Y[.Z]" from a given GitHub repository.
#

GITHUB_REPO=$1
TAG_PREFIX=$2

if [ -z "$GITHUB_REPO" ]; then
  echo "Usage: $0 <GitHub user>/<GitHub repository>"
  exit 1
fi

if [ -z "$TAG_PREFIX" ]; then
  TAG_PREFIX="([a-z_-]+)?"
fi

# use GitHub token authentication on CI to prevent rate limit errors
if [ -n "$GITHUB_TOKEN" ]; then
  GITHUB_AUTHORIZATION_HEADER="Authorization: Bearer $GITHUB_TOKEN"
fi

# try releases first (preferred), then fall back to tags
# per_page=100 is required for some repositories with a lot of beta tags
github_releases=`curl \
  --silent --show-error --fail-with-body \
  --header "$GITHUB_AUTHORIZATION_HEADER" \
  https://api.github.com/repos/$GITHUB_REPO/releases?per_page=100`

if [ $? -eq 0 ]; then
  latest_release=`echo "$github_releases" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | egrep "^${TAG_PREFIX}[0-9]+[\\._-][0-9]+([\\._-][0-9]+)?\$" \
    | head -n 1`
  if [ -n "$latest_release" ]; then
    echo "$latest_release"
    exit 0
  fi
else
  echo "$github_releases" >&2
fi

github_tags=`curl \
  --silent --show-error --fail-with-body \
  --header "$GITHUB_AUTHORIZATION_HEADER" \
  https://api.github.com/repos/$GITHUB_REPO/tags?per_page=100`

if [ $? -eq 0 ]; then
  echo "$github_tags" \
    | grep '"name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | egrep "^${TAG_PREFIX}[0-9]+[\\._-][0-9]+([\\._-][0-9]+)?\$" \
    | head -n 1
else
  echo "$github_tags" >&2
fi
