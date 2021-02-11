#!/bin/sh
set -e

PROJECT=libffi
REPO=https://github.com/libffi/libffi.git

`dirname $0`/common.bat prepare_project

exit 0

cd "$SRCROOT/$PROJECT"

echo
echo "### Running autogen"
./autogen.sh

echo
echo "### Running configure"
./configure \
  --prefix="$INSTALL_PREFIX" \
  CC="$PWD/msvcc.sh -clang-cl" \
  CXX="$PWD/msvcc.sh -clang-cl" \
  LD=link \
  CPP="clang-cl -EP" 

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make install
