@echo off
setlocal

set PROJECT=libxml2
set GITHUB_REPO=GNOME/libxml2

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
-D BUILD_SHARED_LIBS=NO ^
-D LIBXML2_WITH_LZMA=NO ^
-D LIBXML2_WITH_PYTHON=NO ^
-D LIBXML2_WITH_ZLIB=NO ^
-D LIBXML2_WITH_TESTS=NO ^
-D LIBXML2_WITH_PROGRAMS=NO ^
|| exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
:: libxml2-export.cmake is generated while installing libxml2
ninja install
