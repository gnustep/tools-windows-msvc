#!/bin/sh
set -eo pipefail
shopt -s inherit_errexit

cd `dirname $0`

export PROJECT=libffi
export GITHUB_REPO=libffi/libffi
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
MSVCC="$PWD/msvcc.sh -g"
if [ "$ARCH" == "x86" ]; then
  MSVCC="$MSVCC -m32"
  TARGET=i686-pc-cygwin # cygwin suffix required for building DLL
elif [ "$ARCH" == "x64" ]; then
  MSVCC="$MSVCC -m64"
  TARGET=x86_64-pc-cygwin
else
  echo Unknown ARCH: $ARCH && exit 1
fi
if [ "$BUILD_TYPE" == "Debug" ]; then
  MSVCC="$MSVCC -DUSE_DEBUG_RTL"
fi
rm -rf $TARGET
./configure \
  --build=$TARGET --host=$TARGET \
  --prefix="$UNIX_INSTALL_PREFIX" \
  --disable-docs \
  CC="$MSVCC" CXX="$MSVCC" LD=link \
  CPP="cl -nologo -EP" CXXCPP="cl -nologo -EP" \
  CPPFLAGS="-DFFI_BUILDING_DLL" LDFLAGS="" \

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
