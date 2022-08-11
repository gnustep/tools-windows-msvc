@echo off
setlocal

set PROJECT=libcurl
set GITHUB_REPO=curl/curl

:: get the latest release tag from GitHub
cd %~dp0
for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-github-release-tag.sh %GITHUB_REPO% curl-'`) do (
  set TAG=%%i
)

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

cd "%SRCROOT%\%PROJECT%" || exit \b 1

:: generate build config
call "buildconf.bat" || exit \b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=YES ^
  -D CURL_USE_SCHANNEL=YES ^
  -D BUILD_CURL_EXE=NO ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: install PDB file
xcopy /Y /F lib\libcurl*.pdb "%INSTALL_PREFIX%\bin\" || exit /b 1

:: rename libcurl-d_imp.lib to curl.lib to allow linking using -lcurl
move /y "%INSTALL_PREFIX%\lib\libcurl*.lib" "%INSTALL_PREFIX%\lib\curl.lib" || exit /b 1
