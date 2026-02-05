@echo off
setlocal

set PROJECT=libtiff
set GITLAB_REPO=libtiff/libtiff

:: get the latest release tag from GitLab
cd %~dp0
for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-gitlab-release-tag.sh %GITLAB_REPO%'`) do (
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
  -D tiff-tools=OFF ^
  -D tiff-tests=OFF ^
  -D tiff-contrib=OFF ^
  -D tiff-docs=OFF ^
  -D cxx=OFF ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: rename tiffd.lib to tiff.lib to allow linking using -ltiff
cd "%INSTALL_PREFIX%\lib"
if exist tiffd.lib move /y tiffd.lib tiff.lib
