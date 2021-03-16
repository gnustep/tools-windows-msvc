
set PROJECT=libxml2
set REPO=https://github.com/GNOME/libxml2.git
set TAG=v2.9.10

call "%~dp0\common.bat" prepare_project || exit /b 1

cd "%SRCROOT%\%PROJECT%\win32" || exit /b 1

echo.
echo ### Running configure
set CONFIGURE_OPTS=
if "%BUILD_TYPE%" == "Debug" (
  set "CONFIGURE_OPTS=cruntime=/MDd debug=yes"
)
cscript configure.js ^
  compiler=msvc ^
  icu=yes xml_debug=no ^
  %CONFIGURE_OPTS% ^
  "prefix=%INSTALL_PREFIX%" ^
  "include=%INSTALL_PREFIX%\include" ^
  "lib=%INSTALL_PREFIX%\lib" ^
  "sodir=%INSTALL_PREFIX%\lib" ^
  || exit /b 1

echo.
echo ### Building
:: we only build the static library
nmake /f Makefile.msvc libxmla || exit /b 1

echo.
echo ### Installing
:: rename libxml2_a.lib to xml2.lib to allow linking using -lxml2
:: (the wildcard suffix is required to suppress the "file or directory" prompt)
xcopy /Y /F "bin.msvc\libxml2_a.lib" "%INSTALL_PREFIX%\lib\xml2.lib*" || exit /b 1
xcopy /Y /F "%SRCROOT%\%PROJECT%\include\libxml\*.h" "%INSTALL_PREFIX%\include\libxml\" || exit /b 1
