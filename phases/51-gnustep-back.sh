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
echo "### Running configure -- headless backend"

./configure \
    --enable-graphics=headless \
    --enable-server=headless \
    --with-name=headless \
    --without-freetype \
    --host=$TARGET \
    CFLAGS="-Wno-int-conversion"

echo
echo "### Building -- headless backend"
make -j`nproc`

echo
echo "### Installing -- headless backend"
make install
make distclean

echo
echo "### Running configure -- cairo backend"

./configure \
    --with-name=cairo \
    --host=$TARGET \
    CFLAGS="-Wno-int-conversion"

echo
echo "### Building -- cairo backend"
make -j`nproc`

echo
echo "### Installing -- cairo backend"
make install
