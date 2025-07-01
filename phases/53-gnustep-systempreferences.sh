#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=gnustep-systempreferences
export GITHUB_REPO=gnustep/apps-systempreferences
export TAG=

# load environment and prepare project
../scripts/common.bat prepare_project
source ../scripts/bash-env.sh

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
