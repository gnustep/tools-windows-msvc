@echo off
setlocal

set PROJECT=libxml2
set GITHUB_REPO=GNOME/libxml2

:: get the latest release tag from GitHub
cd %~dp0
for /f "usebackq delims=" %%i in (`call %BASH% '../scripts/get-latest-github-release-tag.sh %GITHUB_REPO%'`) do (
  set TAG=%%i
)

:: load environment and prepare project
call "%~dp0\..\scripts\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=NO ^
  -D LIBXML2_WITH_LZMA=NO ^
  -D LIBXML2_WITH_PYTHON=NO ^
  -D LIBXML2_WITH_ZLIB=NO ^
  -D LIBXML2_WITH_TESTS=NO ^
  -D LIBXML2_WITH_PROGRAMS=NO ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
:: rename {libxml2sd.lib,libxml.lib} to xml2.lib to allow linking using -lxml2
:: (the wildcard suffix is required to suppress the "file or directory" prompt)
:: 
:: The "d" suffix is only present when building in debug mode.
if "%BUILD_TYPE%" == "Release" (
  xcopy /Y /F "libxml2s.lib" "%INSTALL_PREFIX%\lib\xml2.lib*" || exit /b 1
) else (
  xcopy /Y /F "libxml2sd.lib" "%INSTALL_PREFIX%\lib\xml2.lib*" || exit /b 1
)
xcopy /Y /F "libxml\xmlversion.h" "%INSTALL_PREFIX%\include\libxml\" || exit /b 1
xcopy /Y /F "libxml2-config.cmake" "%INSTALL_PREFIX%\share\cmake\Modules\" || exit /b 1
xcopy /Y /F "libxml2-config-version.cmake" "%INSTALL_PREFIX%\share\cmake\Modules\" || exit /b 1
xcopy /Y /F "%SRCROOT%\%PROJECT%\include\libxml\*.h" "%INSTALL_PREFIX%\include\libxml\" || exit /b 1

:: write pkgconfig file
call "%~dp0\..\scripts\common.bat" write_pkgconfig libxml-2.0 %TAG% -DLIBXML_STATIC -lxml2 -liconv -lws2_32 || exit /b 1
