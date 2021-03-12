#!/bin/sh
set -e

export PROJECT=gnustep-make
export REPO=https://github.com/gnustep/tools-make.git

`dirname $0`/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Running configure"
CONFIGURE_OPTS=
if [ "$BUILD_TYPE" == "Debug" ]; then
  CONFIGURE_OPTS=--enable-debug-by-default
fi
./configure \
  --host=$TARGET \
  --prefix="$UNIX_INSTALL_PREFIX" \
  --with-library-combo=ng-gnu-gnu \
  --with-runtime-abi=gnustep-2.0 \
  $CONFIGURE_OPTS

echo
echo "### Cleaning"
make clean

echo
echo "### Installing"
make install
