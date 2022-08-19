@echo off
setlocal

set PROJECT=libxslt
set GITHUB_REPO=GNOME/libxslt

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

set MODULE_PATH="%INSTALL_PREFIX%\lib\cmake"
set MODULE_PATH_ESCAPED=%MODULE_PATH:\=/%

echo.
echo ### Running cmake
cmake .. %CMAKE_OPTIONS% ^
-D BUILD_SHARED_LIBS=NO ^
-D LIBXSLT_WITH_TESTS=NO ^
-D LIBXSLT_WITH_PYTHON=NO ^
-D CMAKE_PREFIX_PATH=%MODULE_PATH_ESCAPED% ^
|| exit /b 1

echo.
echo ### Building
ninja || exit /b 1

::nmake /f Makefile.msvc libxslta libexslta || exit /b 1

echo.
echo ### Installing
if "%BUILD_TYPE%" == "Release" (
  xcopy /Y /F "libxslts.lib" "%INSTALL_PREFIX%\lib\xslt.lib*" || exit /b 1
  xcopy /Y /F "libexslts.lib" "%INSTALL_PREFIX%\lib\exslt.lib*" || exit /b 1
) else (
  xcopy /Y /F "libxsltsd.lib" "%INSTALL_PREFIX%\lib\xslt.lib*" || exit /b 1
  xcopy /Y /F "libexsltsd.lib" "%INSTALL_PREFIX%\lib\exslt.lib*" || exit /b 1
)
xcopy /Y /F /S "libxslt\*.h" "%INSTALL_PREFIX%\include\libxslt\" || exit /b 1
xcopy /Y /F /S "libexslt\*.h" "%INSTALL_PREFIX%\include\libexslt\" || exit /b 1
xcopy /Y /F /S "%SRCROOT%\%PROJECT%\libxslt\*.h" "%INSTALL_PREFIX%\include\libxslt\" || exit /b 1
xcopy /Y /F /S "%SRCROOT%\%PROJECT%\libexslt\*.h" "%INSTALL_PREFIX%\include\libexslt\" || exit /b 1

:: write pkgconfig file
call "%~dp0\..\scripts\common.bat" write_pkgconfig libxslt %TAG% -DLIBXSLT_STATIC -lxslt libxml-2.0 || exit /b 1
