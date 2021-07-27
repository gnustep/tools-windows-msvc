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
# manually specifly flags for libxml2 below because they don't have pkg-config info
./configure \
  --host=$TARGET \
  --disable-tls \
  XML_CFLAGS="-I$UNIX_INSTALL_PREFIX/include -DLIBXML_STATIC" \
  XML_LIBS="-L$UNIX_INSTALL_PREFIX/lib -lxml2" \

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
