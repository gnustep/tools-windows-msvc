#!/bin/sh
#
# Gets the latest tag of the form "vX.Y[.Z]" from a given GitLab repository.
#

GITLAB_REPO=$1
TAG_PREFIX=$2

if [ -z "$GITLAB_REPO" ]; then
  echo "Usage: $0 <GitLab namespace>/<GitLab repository>"
  exit 1
fi

GITLAB_API_URL=${GITLAB_API_URL:-https://gitlab.com/api/v4}
GITLAB_PROJECT=`printf %s "$GITLAB_REPO" | sed 's|/|%2F|g'`

# try releases first (preferred), then fall back to tags
# per_page=100 is required for some repositories with a lot of tags

gitlab_releases=`curl \
  --silent --show-error --fail-with-body \
  "$GITLAB_API_URL/projects/$GITLAB_PROJECT/releases?per_page=100"`

if [ $? -eq 0 ]; then
  latest_release=`echo "$gitlab_releases" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | egrep "^${TAG_PREFIX:-[a-z_-]+}[0-9]+[\._-][0-9]+([\._-][0-9]+)?$" \
    | head -n 1`
  if [ -n "$latest_release" ]; then
    echo "$latest_release"
    exit 0
  fi
else
  echo "$gitlab_releases" >&2
fi

gitlab_tags=`curl \
  --silent --show-error --fail-with-body \
  "$GITLAB_API_URL/projects/$GITLAB_PROJECT/repository/tags?per_page=100"`

if [ $? -eq 0 ]; then
  echo "$gitlab_tags" \
    | grep '"name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | egrep "^${TAG_PREFIX:-[a-z_-]+}[0-9]+[\._-][0-9]+([\._-][0-9]+)?$" \
    | head -n 1
else
  echo "$gitlab_tags" >&2
fi
