
set PROJECT=libobjc2
set REPO=https://github.com/gnustep/libobjc2.git
set TAG=

call "%~dp0\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%"

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

:: Install PDB files
xcopy /Y /F objc.pdb "%INSTALL_PREFIX%\lib\"
