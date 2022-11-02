#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=systempreferences
export GITHUB_REPO=gnustep/apps-systempreferences
export TAG=
# windows-msvc-fixes-additional

# load environment and prepare project
../scripts/common.bat prepare_project

cd "$SRCROOT/$PROJECT"

echo
echo "### Loading GNUstep environment"
. "$UNIX_INSTALL_PREFIX/share/GNUstep/Makefiles/GNUstep.sh"

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make GNUSTEP_INSTALLATION_DOMAIN=LOCAL debug=yes install
make GNUSTEP_INSTALLATION_DOMAIN=LOCAL debug=no install
