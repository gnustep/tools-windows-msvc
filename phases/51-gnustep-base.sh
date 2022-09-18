#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-base
export GITHUB_REPO=gnustep/libs-base
export TAG=

# load environment and prepare project
../scripts/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Running configure"
./configure \
  --host=$TARGET \
  --disable-tls \
  $GNUSTEP_BASE_OPTIONS

echo
echo "### Building"
make -j`nproc` messages=no

echo
echo "### Installing"
make install
