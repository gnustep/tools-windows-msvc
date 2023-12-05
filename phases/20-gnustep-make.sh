#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-make
export GITHUB_REPO=gnustep/tools-make
export TAG=

# load environment and prepare project
../scripts/common.bat prepare_project

# set CFLAGS to enable optimizations and always generate debug info,
# which is required because Autoconf doesn't recognize Clang to support
# GNU C on Windows and therefore doesn't set CFLAGS to "-g -O2"
if [[ ! -v OPTFLAG && "$BUILD_TYPE" == "Release" ]]; then
  OPTFLAG=-O2
fi
CFLAGS="-g -gcodeview $OPTFLAG"

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
  CFLAGS="$CFLAGS" \
  $CONFIGURE_OPTS

echo
echo "### Installing"
make install
