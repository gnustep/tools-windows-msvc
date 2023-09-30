#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-back
export GITHUB_REPO=gnustep/libs-back
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
    --enable-graphics=headless \
    --enable-server=headless \
    --without-freetype \
    --host=$TARGET \
    CFLAGS="-Wno-int-conversion"

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install