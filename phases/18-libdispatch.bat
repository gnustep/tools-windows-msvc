@echo off
setlocal

set PROJECT=libdispatch
set GITHUB_REPO=apple/swift-corelibs-libdispatch
set TAG=

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
:: CXX and linker flags below are to produce PDBs for release builds.
:: BlocksRuntime parameters provided to use blocks runtime from libobjc2 with libdispatch-own-blocksruntime.patch.
:: libdispatch only supports building with clang-cl frontend.
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=YES ^
  -D INSTALL_PRIVATE_HEADERS=YES ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/Zi" ^
  -D CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="/INCREMENTAL:NO /DEBUG /OPT:REF /OPT:ICF" ^
  -D BlocksRuntime_INCLUDE_DIR=%INSTALL_PREFIX%\include ^
  -D BlocksRuntime_LIBRARIES=%INSTALL_PREFIX%\lib\objc.lib ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: install PDB file
xcopy /Y /F dispatch.pdb "%INSTALL_PREFIX%\bin\" || exit /b 1
