#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-gui
export GITHUB_REPO=gnustep/libs-gui
export TAG=
# windows-msvc-fixes-additional

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

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
