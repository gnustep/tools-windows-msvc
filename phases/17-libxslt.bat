@echo off
setlocal

set PROJECT=libxslt
set GITHUB_REPO=GNOME/libxslt

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

SET UM_INCLUDE_DIR="%WindowsSdkDir%include\%WindowsSdkVersion%um"

echo.
echo ### Running cmake
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=NO ^
  -D LIBXSLT_WITH_PYTHON=NO ^
  -D LIBXSLT_WITH_TESTS=NO ^
  -D LIBXSLT_WITH_PROGRAMS=NO ^
  -D CMAKE_STATIC_LIBRARY_PREFIX= ^
  -D ICU_INCLUDE_DIR=%UM_INCLUDE_DIR% ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: remove installed documentation
rmdir /S /Q "%INSTALL_PREFIX%\share\doc\libxslt"
