@echo off
setlocal

set PROJECT=curl
set GITHUB_REPO=curl/curl

:: get the latest release tag from GitHub
cd %~dp0
for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-github-release-tag.sh %GITHUB_REPO%'`) do (
  set TAG=%%i
)

set MAKE_OPTS=
if "%BUILD_TYPE%" == "Debug" (
  MAKE_OPTS="debug=yes"
) else (
  MAKE_OPTS="debug=no"
)

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

:: Overwrite CC and CXX to MSVC
set CC=cl.exe
set CXX=cl.exe

cd "%SRCROOT%\%PROJECT%" || exit \b 1

:: Generates the tool_hugehelp.c file
call "buildconf.bat" || exit \b 1

cd "winbuild" || exit /b 1

echo.
echo ### Building

nmake /f Makefile.vc mode=static %MAKE_OPTS% || exit /b 1

echo.
echo ### Installing
set CURL_BUILD_DIR=..\builds\libcurl-vc-%ARCH%-release-static-ipv6-sspi-schannel
xcopy /Y /F "%CURL_BUILD_DIR%\lib\libcurl_a.lib" "%INSTALL_PREFIX%\lib\curl.lib*" || exit /b 1
xcopy /Y /F "%CURL_BUILD_DIR%\include\curl\*.h" "%INSTALL_PREFIX%\include\curl\" || exit /b 1

:: write pkgconfig file
call "%~dp0\..\scripts\common.bat" write_pkgconfig libcurl %TAG% -DLIBCURL_STATIC -lcurl || exit /b 1

:: Unset modifications
set CC=
set CXX=
