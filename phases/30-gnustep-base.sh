#!/bin/sh
set -e

export PROJECT=gnustep-base
export REPO=https://github.com/gnustep/libs-base.git
export TAG=win-locks

`dirname $0`/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Running configure"
# manually specifly flags for ICU and libxml2 below because they don't have pkg-config info
./configure \
  --host=$TARGET \
  --disable-tls \
  ICU_CFLAGS="-I$UNIX_INSTALL_PREFIX/include" \
  ICU_LIBS="-L$UNIX_INSTALL_PREFIX/lib -licuin -licuuc -licudt" \
  XML_CFLAGS="-I$UNIX_INSTALL_PREFIX/include" \
  XML_LIBS="-L$UNIX_INSTALL_PREFIX/lib -lxml2" \

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
