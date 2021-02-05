@echo off

call "%~dp0..\env\common.bat" prepare_project "gnustep-base" "https://github.com/gnustep/libs-base.git"

pushd "%SRCROOT%\%PROJECT%"

echo ### Running configure
call "%GITBASH%" -c '. "%UNIX_INSTALL_PREFIX%/share/GNUstep/Makefiles/GNUstep.sh"; ./configure --host=%ARCH%-pc-windows' || exit /b 1

echo.
echo ### Building
call "%GITBASH%" -c 'make -j12' || exit /b 1

echo.
echo ### Installing
call "%GITBASH%" -c 'make install' || exit /b 1

popd
