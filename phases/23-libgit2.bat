@echo off
setlocal

set PROJECT=libgit2
set GITHUB_REPO=libgit2/libgit2
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
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=YES ^
  -D INSTALL_PRIVATE_HEADERS=YES ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/Zi" ^
  -D CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="/INCREMENTAL:NO /DEBUG /OPT:REF /OPT:ICF" ^
  -D BUILD_TESTS=OFF ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: install PDB file
xcopy /Y /F git2.pdb "%INSTALL_PREFIX%\bin\" || exit /b 1
