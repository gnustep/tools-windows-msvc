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

# use GitHub token authentication on CI to prevent rate limit errors
if [ -n "$GITHUB_TOKEN" ]; then
  GITHUB_AUTHORIZATION_HEADER="Authorization: Bearer $GITHUB_TOKEN"
fi

# get the tags JSON from the GitHub API and parse it manually,
# or output it to stderr if the server returns an error
github_tags=`curl \
  --silent --show-error --fail-with-body \
  --header "$GITHUB_AUTHORIZATION_HEADER" \
  https://api.github.com/repos/$GITHUB_REPO/tags`

if [ $? -eq 0 ]; then
  echo "$github_tags" \
    | grep '"name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | egrep "^${TAG_PREFIX:-[a-z_-]+}[0-9]+[\._-][0-9]+([\._-][0-9]+)?\$" \
    | head -n 1
else
  echo "$github_tags" >&2
fi
