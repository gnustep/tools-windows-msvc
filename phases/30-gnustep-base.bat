
call "%~dp0..\env\common.bat" prepare_project "gnustep-base" "https://github.com/gnustep/libs-base.git" || exit /b 1

pushd "%SRCROOT%\%PROJECT%"

call %BASH% '%UNIX_ROOT_DIR%/phases/30-gnustep-base.sh' || exit /b 1

popd
