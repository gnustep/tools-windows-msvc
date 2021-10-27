@echo off
setlocal

set PROJECT=zlib-ng
set GITHUB_REPO=zlib-ng/zlib-ng
set TAG=

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
:: zlib-ng requires using cl (clang-cl produces build errors)
cmake .. %CMAKE_OPTIONS% ^
  -D CMAKE_C_COMPILER=cl ^
  -D CMAKE_CXX_COMPILER=cl ^
  -D BUILD_SHARED_LIBS=ON ^
  -D ZLIB_COMPAT=ON ^
  -D ZLIB_ENABLE_TESTS=OFF ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1
