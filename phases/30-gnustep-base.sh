#!/bin/sh
set -e

export PROJECT=gnustep-base
export REPO=https://github.com/gnustep/libs-base.git

`dirname $0`/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Running configure"
# ICU flags are specified manually as our ICU does not have pkg-config info
./configure \
  --host=$TARGET \
  --disable-tls --disable-xml
  ICU_CFLAGS="-I$UNIX_INSTALL_PREFIX/include" \
  ICU_LIBS="-L$UNIX_INSTALL_PREFIX/lib -licuin -licuuc -licudt" \

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
