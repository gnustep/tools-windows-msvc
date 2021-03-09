
set PROJECT=libdispatch
set REPO=https://github.com/apple/swift-corelibs-libdispatch.git

call "%~dp0\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%"

echo.
echo ### Running cmake
set CMAKE_BUILD_TYPE=%BUILD_TYPE%
if not %CMAKE_BUILD_TYPE% == Debug set CMAKE_BUILD_TYPE=RelWithDebInfo
cmake .. ^
  -G Ninja ^
  -D CMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
  -D CMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -D BUILD_SHARED_LIBS=YES ^
  -D INSTALL_PRIVATE_HEADERS=YES ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: Move DLLs from bin to lib directory.
move "%INSTALL_PREFIX%\bin\BlocksRuntime.dll" "%INSTALL_PREFIX%\lib\"
move "%INSTALL_PREFIX%\bin\dispatch.dll" "%INSTALL_PREFIX%\lib\"
