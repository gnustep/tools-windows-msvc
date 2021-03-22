#!/bin/sh
set -e

export PROJECT=gnustep-corebase
# FIXME: should be switched to the official repo once this has been merged
export REPO=https://github.com/triplef/libs-corebase.git
export TAG=windows-msvc

`dirname $0`/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Running configure"
./configure \
  --host=$TARGET \
  `# specify environment since it doesn't use gnustep-config to get these` \
  CC="`gnustep-config --variable=CC`" \
  CPP="`gnustep-config --variable=CPP`" \
  CXX="`gnustep-config --variable=CXX`" \
  CFLAGS="$CFLAGS -I$UNIX_INSTALL_PREFIX/include" \
  CPPFLAGS="$CPPFLAGS -I$UNIX_INSTALL_PREFIX/include" \
  LDFLAGS="$LDFLAGS -L$UNIX_INSTALL_PREFIX/lib" \
  `# manually specifly flags for ICU because we don't have pkg-config info` \
  ICU_CFLAGS="-I$UNIX_INSTALL_PREFIX/include" \
  ICU_LIBS="-L$UNIX_INSTALL_PREFIX/lib -licuin -licuuc -licudt" \

echo
echo "### Building"
make #-j`nproc`

echo
echo "### Installing"
make install
