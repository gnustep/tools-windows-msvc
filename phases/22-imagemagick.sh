#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=imagemagick
export GITHUB_REPO=ImageMagick/ImageMagick
export TAG=`../scripts/get-latest-github-release-tag.sh $GITHUB_REPO`

# load environment and prepare project
../scripts/common.bat prepare_project

cd "$SRCROOT/$PROJECT" || exit /b 1

if [ ! -f configure ]; then
  echo
  echo "### Running autogen"
  ./autogen.sh
fi

echo
echo "### Running configure"

rm -rf $TARGET
./configure \
    --build=$TARGET \
    --host=$TARGET \
    --prefix="$UNIX_INSTALL_PREFIX" \
    LD=link

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
# make install throws errors for DLL builds, so we install manually instead
cd $TARGET
install -D -t "$UNIX_INSTALL_PREFIX"/lib/pkgconfig/ *.pc
install -D -t "$UNIX_INSTALL_PREFIX"/include/ include/*.h
install -D -t "$UNIX_INSTALL_PREFIX"/bin/ .libs/libffi-*.dll
install -D -t "$UNIX_INSTALL_PREFIX"/bin/ .libs/libffi-*.pdb
install .libs/libffi-*.lib "$UNIX_INSTALL_PREFIX"/lib/ffi.lib
