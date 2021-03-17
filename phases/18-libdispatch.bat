
set PROJECT=libdispatch
set REPO=https://github.com/apple/swift-corelibs-libdispatch.git
set TAG=

call "%~dp0\common.bat" prepare_project || exit /b 1

if "%ARCH%" == "x86" (
  echo Skipping libdispatch for x86
  echo Blocked on issue: https://bugs.swift.org/browse/SR-14314
  exit /b 0
)

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%"

echo.
echo ### Running cmake
:: CXX and linker flags below are to produce PDBs for release builds
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=YES ^
  -D INSTALL_PRIVATE_HEADERS=YES ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/Zi" ^
  -D CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="/INCREMENTAL:NO /DEBUG /OPT:REF /OPT:ICF" ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: Install PDB files
xcopy /Y /F BlocksRuntime.pdb "%INSTALL_PREFIX%\lib\"
xcopy /Y /F dispatch.pdb "%INSTALL_PREFIX%\lib\"

:: Move DLLs from bin to lib directory.
move /Y "%INSTALL_PREFIX%\bin\BlocksRuntime.dll" "%INSTALL_PREFIX%\lib\"
move /Y "%INSTALL_PREFIX%\bin\dispatch.dll" "%INSTALL_PREFIX%\lib\"
