#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-corebase
export GITHUB_REPO=gnustep/libs-corebase
export TAG=

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
  --disable-cfrunloop \
  `# specify environment since it doesn't use gnustep-config to get these` \
  CC="`gnustep-config --variable=CC`" \
  CPP="`gnustep-config --variable=CPP`" \
  CXX="`gnustep-config --variable=CXX`" \
  CFLAGS="$CFLAGS -I$UNIX_INSTALL_PREFIX/include" \
  CPPFLAGS="$CPPFLAGS -I$UNIX_INSTALL_PREFIX/include" \
  LDFLAGS="$LDFLAGS -L$UNIX_INSTALL_PREFIX/lib" \

echo
echo "### Building"
# define _UCRT_NOISY_NAN to work around https://developercommunity.visualstudio.com/t/NAN-is-no-longer-compile-time-constant-i/10688907
make -j`nproc` CFLAGS=-D_UCRT_NOISY_NAN

echo
echo "### Installing"
make install
