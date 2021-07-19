#!/bin/sh
set -e
cd `dirname $0`

export PROJECT=gnustep-make
export GITHUB_REPO=gnustep/tools-make
export TAG=

# load environment and prepare project
../scripts/common.bat prepare_project

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
echo "### Installing"
make install
