
set PROJECT=libobjc2
set REPO=https://github.com/gnustep/libobjc2.git

call "%~dp0\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%"

echo.
echo ### Running cmake
:: GNUSTEP_CONFIG is set to empty string to prevent CMake from finding it in
:: install root.
set CMAKE_BUILD_TYPE=%BUILD_TYPE%
if not %CMAKE_BUILD_TYPE% == Debug set CMAKE_BUILD_TYPE=RelWithDebInfo
cmake .. ^
  -G Ninja ^
  -D CMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
  -D CMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  -D GNUSTEP_CONFIG= ^
  || exit /b 1

echo.
echo ### Building
set CCC_OVERRIDE_OPTIONS=x-TC x-TP x/TC x/TP
ninja || exit /b 1
set CCC_OVERRIDE_OPTIONS=

echo.
echo ### Installing
ninja install || exit /b 1
