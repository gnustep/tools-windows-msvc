#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-base
export GITHUB_REPO=keysight-eggplant/libs-base
#export TAG=keysight-eggplant-msvc-port-changes
#export TAG=keysight-eggplant-msvc
export TAG=msvc-configure-changes

# load environment and prepare project
../scripts/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Running configure"
./configure \
  --host=$TARGET \
  --disable-tls \
  --disable-xml \
  --disable-icu \
  --enable-zeroconf \
  --with-zeroconf-api=mdns \
  $GNUSTEP_BASE_OPTIONS

echo
echo "### Building"
make -j`nproc` messages=no

echo
echo "### Installing"
make install
