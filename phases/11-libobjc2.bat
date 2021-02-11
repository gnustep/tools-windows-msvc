
set PROJECT=libobjc2
set REPO=https://github.com/gnustep/libobjc2.git

call "%~dp0\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%"
if not exist %BUILD_DIR% (mkdir %BUILD_DIR%)
cd "%BUILD_DIR%"

echo ### Running cmake
cmake .. -G Ninja -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl || exit /b 1

echo.
echo ### Building
set CCC_OVERRIDE_OPTIONS=x-TC x-TP x/TC x/TP
ninja || exit /b 1
set CCC_OVERRIDE_OPTIONS=

echo.
echo ### Installing
ninja install || exit /b 1
