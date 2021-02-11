#!/bin/sh
set -e

PROJECT=gnustep-base
REPO=https://github.com/gnustep/libs-base.git

`dirname $0`/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Running configure"
./configure --host=$TARGET --disable-iconv --disable-tls --disable-icu --disable-xml

echo
echo "### Cleaning"
make clean

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
