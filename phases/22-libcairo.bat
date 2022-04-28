@echo off
setlocal

set PROJECT=cairo
set GITHUB_REPO=gcasa/cairo
set TAG=

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

pwd
echo
echo "### Running configure"
./configure \
  --host=$TARGET \

echo
echo "### Building"
make -j`nproc`

echo
echo "### Installing"
make instal
