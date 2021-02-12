#!/bin/sh
set -e

export PROJECT=gnustep-make
export REPO=https://github.com/gnustep/tools-make.git

`dirname $0`/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo "### Running configure"
./configure \
  --host=$TARGET \
  --prefix="$UNIX_INSTALL_PREFIX" \
  --with-library-combo=ng-gnu-gnu \
  --with-runtime-abi=gnustep-2.0 \

echo
echo "### Cleaning"
make clean

echo
echo "### Installing"
make install
