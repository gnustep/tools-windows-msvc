@echo off
setlocal

set PROJECT=libpng
set GITHUB_REPO=glennrp/libpng

:: get the latest release tag from GitHub (DISABLED UNTIL v1.7.0 with WoA support has been released)
::cd %~dp0
::for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-github-release-tag.sh %GITHUB_REPO%'`) do (
::  set TAG=%%i
::)
set TAG=master

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
cmake .. %CMAKE_OPTIONS% ^
  -D PNG_STATIC=OFF ^
  -D PNG_EXECUTABLES=OFF ^
  -D PNG_TESTS=OFF ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1
