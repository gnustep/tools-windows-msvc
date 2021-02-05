@echo off

call "%~dp0..\env\common.bat" prepare_project "gnustep-make" "https://github.com/gnustep/tools-make.git"

pushd "%SRCROOT%\%PROJECT%"

echo ### Running configure
call "%GITBASH%" -c './configure --prefix="%UNIX_INSTALL_PREFIX%" --with-library-combo=ng-gnu-gnu --with-runtime-abi=gnustep-2.0 --host=%ARCH%-pc-windows LDFLAGS="-fuse-ld=lld"' || exit /b 1

echo.
echo ### Installing
call "%GITBASH%" -c 'make install' || exit /b 1

popd
