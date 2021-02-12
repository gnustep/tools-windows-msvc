
set PROJECT=libdispatch
set REPO=https://github.com/apple/swift-corelibs-libdispatch.git

call "%~dp0\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%"
if not exist %BUILD_DIR% (mkdir %BUILD_DIR%)
cd "%BUILD_DIR%"

echo.
echo ### Running cmake
:: Note: build type must be Release or RelWithDebInfo so we link against the
:: release CRT DLLs just like all our other projects.
cmake .. ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DBUILD_SHARED_LIBS=YES ^
  -DINSTALL_PRIVATE_HEADERS=YES ^
  -DCMAKE_C_COMPILER=clang-cl ^
  -DCMAKE_CXX_COMPILER=clang-cl ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1
