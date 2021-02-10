
call "%~dp0..\env\common.bat" prepare_project "libobjc2" "https://github.com/gnustep/libobjc2.git" || exit /b 1

if not exist %BUILD_DIR% (mkdir %BUILD_DIR%)
pushd "%BUILD_DIR%"

echo ### Running cmake
cmake .. -G Ninja -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl || exit /b 1

echo.
echo ### Building
set CCC_OVERRIDE_OPTIONS=x-TC x-TP x/TC x/TP
ninja || exit /b 1
set CCC_OVERRIDE_OPTIONS=

echo.
echo ### Installing
ninja install || exit /b 1

popd
