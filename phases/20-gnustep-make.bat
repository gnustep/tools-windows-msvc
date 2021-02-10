
call "%~dp0..\env\common.bat" prepare_project "gnustep-make" "https://github.com/gnustep/tools-make.git" || exit /b 1

pushd "%SRCROOT%\%PROJECT%"

call %BASH% '%UNIX_ROOT_DIR%/phases/20-gnustep-make.sh' || exit /b 1

popd
