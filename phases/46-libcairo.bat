@echo off
setlocal

set PROJECT=libjpeg
set GITHUB_REPO=native-toolkit/libcairo
set TAG=1.15.2

:: get the latest release tag from GitHub
cd %~dp0
for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-github-release-tag.sh %GITHUB_REPO%'`) do (
  set TAG=%%i
)

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
cmake .. %CMAKE_OPTIONS% ^
  -D ENABLE_STATIC=OFF -D INST_ID=vc ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1
