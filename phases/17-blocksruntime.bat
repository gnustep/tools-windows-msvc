@echo off
setlocal

set PROJECT=blocksruntime
set GITHUB_REPO=hmelder/swift-corelibs-blocksruntime
set TAG=blocks-rt-win32

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
:: CXX and linker flags below are to produce PDBs for release builds.
cmake .. %CMAKE_OPTIONS% ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/Zi" ^
  -D CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="/INCREMENTAL:NO /DEBUG /OPT:REF /OPT:ICF" ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: install PDB file
xcopy /Y /F BlocksRuntime.pdb "%INSTALL_PREFIX%\bin\" || exit /b 1
