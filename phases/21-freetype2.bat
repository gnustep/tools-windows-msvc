@echo off
setlocal

set PROJECT=freetype2
set GITHUB_REPO=aseprite/freetype2
set TAG=

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
:: GNUSTEP_CONFIG is set to empty string to prevent CMake from finding it in install root.
cmake .. %CMAKE_OPTIONS% ^
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

:: move DLL to bin and install PDB files
if not exist "%INSTALL_PREFIX%\bin\" mkdir "%INSTALL_PREFIX%\bin\" || exit /b 1
if exist "%INSTALL_PREFIX%\lib\freetype.dll" move /Y "%INSTALL_PREFIX%\lib\freetype.dll" "%INSTALL_PREFIX%\bin\" || exit /b 1
